#!/usr/bin/env python3
"""Opt-in real inference smoke test. Uses synthetic data and existing local models."""
import argparse
import json
from pathlib import Path
import sys
import tempfile
import time
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'apps/connect'))
from bridge import Bridge, models

parser = argparse.ArgumentParser()
parser.add_argument('--model', required=True, help='Existing model id, e.g. Ollama:qwen3:1.7b')
args = parser.parse_args()
assert args.model in {m['id'] for m in models()}, 'Start the chosen local model server first.'
with tempfile.TemporaryDirectory() as directory:
    transport = Bridge(Path(directory))
    started = time.monotonic()
    response = transport.process({
        'model': args.model, 'areas': ['finance', 'fitness'], 'context': [],
        'text': 'Bu bir test kaydıdır: markete 25 euro harcadım. Yarın bacak antrenmanı yapacağım.'
    })
    assert response['kind'] == 'record', response
    assert any(r.get('area') == 'finance' and r.get('amountMinor') == 2500 and r.get('currency') == 'EUR' for r in response['records']), response
    assert any(r.get('area') == 'fitness' for r in response['records']), response
    print(json.dumps(response, ensure_ascii=False, indent=2))
    print(f'PASS: local compound extraction, {time.monotonic() - started:.2f}s')
