import hashlib
import http.client
import json
from pathlib import Path
import ssl
import tempfile
import threading
import unittest
from unittest.mock import patch
import bridge

class BridgeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory()
        cls.state = bridge.Bridge(Path(cls.temp.name))
        cls.server = bridge.Server(('127.0.0.1', 0), bridge.Handler)
        cls.server.bridge = cls.state
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown(); cls.server.server_close(); cls.temp.cleanup()
    def call(self, path, body=None, token=None):
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
        context.check_hostname = False; context.verify_mode = ssl.CERT_NONE
        conn = http.client.HTTPSConnection('127.0.0.1', self.server.server_port, context=context, timeout=5)
        conn.connect()
        self.assertEqual(hashlib.sha256(conn.sock.getpeercert(binary_form=True)).hexdigest(), self.state.fingerprint)
        headers = {'Content-Type': 'application/json'}
        if token: headers['Authorization'] = 'Bearer ' + token
        conn.request('POST' if body is not None else 'GET', path, json.dumps(body) if body is not None else None, headers)
        response = conn.getresponse(); value = json.loads(response.read()); status = response.status; conn.close()
        return status, value
    def pair(self):
        nonce = __import__('secrets').token_hex(32)
        with patch.object(bridge, 'emit'):
            status, reply = self.call('/pair', {'nonce': nonce, 'name': 'Test iPhone'})
        self.assertEqual(status, 200)
        self.assertEqual(self.call('/pair/status', {'nonce': nonce})[1]['status'], 'pending')
        self.state.approve(nonce, True)
        return self.call('/pair/status', {'nonce': nonce})[1]['token']
    def test_unpaired_access_denied(self):
        self.assertEqual(self.call('/models')[0], 401)
        self.assertEqual(self.call('/process', {'text': 'private'})[0], 401)
    def test_pairing_requires_desktop_approval_and_persists_hash(self):
        token = self.pair()
        self.assertTrue(self.state.authorize(token))
        stored = self.state.tokens_file.read_text()
        self.assertNotIn(token, stored)
        self.assertEqual(self.state.tokens_file.stat().st_mode & 0o777, 0o600)
        with patch.object(bridge, 'models', return_value=[]):
            self.assertEqual(self.call('/models', token=token), (200, {'models': []}))
    def test_expired_and_rejected_pairings(self):
        nonce = 'a' * 64
        with patch.object(bridge, 'emit'): self.state.begin_pair(nonce, 'Test')
        self.state.approve(nonce, False)
        self.assertEqual(self.state.poll(nonce)['status'], 'expired')
        with patch.object(bridge, 'emit'): self.state.begin_pair(nonce, 'Test')
        self.state.pending[nonce]['expires'] = 0
        self.state.approve(nonce, True)
        self.assertEqual(self.state.poll(nonce)['status'], 'expired')
    def test_invalid_nonce(self):
        self.assertEqual(self.call('/pair', {'nonce': '123', 'name': 'Test'})[0], 422)
    def test_pair_code_binds_certificate_and_nonce(self):
        self.assertNotEqual(bridge.pairing_code('cert1', 'nonce'), bridge.pairing_code('cert2', 'nonce'))
        self.assertEqual(len(bridge.pairing_code('cert', 'nonce')), 6)
    def test_authenticated_processing_and_malformed_output(self):
        token = self.pair()
        model = {'id': 'Ollama:fixture', 'name': 'fixture', 'provider': 'Ollama'}
        body = {'text': 'Remember my book', 'model': model['id'], 'areas': ['notes'], 'context': []}
        answer = {'kind': 'record', 'records': [{'area': 'notes', 'title': 'Book', 'detail': 'Remember my book'}], 'answer': None}
        with patch.object(bridge, 'models', return_value=[model]), patch.object(bridge, 'request_json', return_value={'message': {'content': json.dumps(answer)}}):
            self.assertEqual(self.call('/process', body, token), (200, answer))
        with patch.object(bridge, 'models', return_value=[model]), patch.object(bridge, 'request_json', return_value={'message': {'content': 'not json'}}):
            self.assertEqual(self.call('/process', body, token)[0], 422)
    def test_unavailable_model_does_not_fallback(self):
        token = self.pair()
        with patch.object(bridge, 'models', return_value=[]), patch.object(bridge, 'request_json') as request:
            self.assertEqual(self.call('/process', {'text': 'Hi', 'areas': ['notes'], 'model': 'missing'}, token)[0], 422)
            request.assert_not_called()
    def test_busy_model_keeps_request_retryable(self):
        token = self.pair()
        self.state.inference.acquire()
        try: self.assertEqual(self.call('/process', {'text': 'Hi'}, token)[0], 429)
        finally: self.state.inference.release()

if __name__ == '__main__': unittest.main()
