import Foundation
import Security
import CryptoKit
import UIKit

struct LocalModel: Codable, Identifiable { let id: String; let name: String; let provider: String }
struct PairedComputer: Codable {
    let name: String
    let serviceName: String
    let fingerprint: String
    let token: String
}
enum ConnectionError: LocalizedError {
    case message(String)
    var errorDescription: String? { if case let .message(value) = self { return value }; return nil }
}
final class PinnedTrust: NSObject, URLSessionDelegate, @unchecked Sendable {
    private let lock = NSLock()
    private var pinned: String?
    var fingerprint: String? { lock.lock(); defer { lock.unlock() }; return pinned }
    init(expected: String?) { pinned = expected }
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let trust = challenge.protectionSpace.serverTrust,
              let certificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate], let cert = certificates.first else {
            completionHandler(.cancelAuthenticationChallenge, nil); return
        }
        let digest = SHA256.hash(data: SecCertificateCopyData(cert) as Data).map { String(format: "%02x", $0) }.joined()
        lock.lock()
        let accepted = pinned == nil || pinned == digest
        if accepted { pinned = digest }
        lock.unlock()
        completionHandler(accepted ? .useCredential : .cancelAuthenticationChallenge, accepted ? URLCredential(trust: trust) : nil)
    }
}
enum SecurePair {
    static let service = "app.persoo.connection"
    static func load() -> PairedComputer? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecReturnData as String: true]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let data = item as? Data else { return nil }
        return try? JSONDecoder().decode(PairedComputer.self, from: data)
    }
    static func save(_ pair: PairedComputer) throws {
        let data = try JSONEncoder().encode(pair)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service]
        let attributes: [String: Any] = [kSecValueData as String: data, kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly]
        let result = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if result == errSecItemNotFound {
            guard SecItemAdd(query.merging(attributes) { _, new in new } as CFDictionary, nil) == errSecSuccess else { throw ConnectionError.message("Eşleştirme güvenli alana kaydedilemedi.") }
        } else if result != errSecSuccess { throw ConnectionError.message("Eşleştirme kaydedilemedi.") }
    }
    static func clear() { SecItemDelete([kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service] as CFDictionary) }
}
@MainActor final class Connection: NSObject, ObservableObject, NetServiceBrowserDelegate, NetServiceDelegate {
    @Published var computers: [NetService] = []
    @Published var status = "Bilgisayarında Persoo Connect’i aç."
    @Published var code: String?
    @Published var paired: PairedComputer? = SecurePair.load()
    @Published var models: [LocalModel] = []
    @Published var busy = false
    @Published var online = false
    private let browser = NetServiceBrowser()
    private var selected: NetService?
    private var base: URL?
    private var trust: PinnedTrust?
    private var session: URLSession?
    private var pairingTask: Task<Void, Never>?
    func discover() {
        browser.stop(); computers = []
        browser.delegate = self; browser.searchForServices(ofType: "_persoo._tcp.", inDomain: "local.")
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if !computers.contains(where: { $0.name == service.name }) { computers.append(service) }
        if service.name == paired?.serviceName, !busy { connect(service) }
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        computers.removeAll { $0.name == service.name }
        if service.name == selected?.name { online = false; status = "Bilgisayar çevrimdışı. Kayıtların telefonda güvende." }
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        status = "Yerel ağ iznini kontrol et ve tekrar dene."
    }
    func connect(_ service: NetService) {
        guard !busy else { return }
        selected?.stop(); selected = service; busy = true; online = false
        status = "Bilgisayara bağlanılıyor…"; service.delegate = self; service.resolve(withTimeout: 8)
    }
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        busy = false; status = "Bilgisayara ulaşılamadı. Aynı yerel ağda olduğundan emin ol."
    }
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let hostname = sender.hostName else { busy = false; return }
        var components = URLComponents(); components.scheme = "https"; components.host = hostname; components.port = sender.port
        base = components.url
        session?.invalidateAndCancel()
        let expected = paired?.serviceName == sender.name ? paired?.fingerprint : nil
        let delegate = PinnedTrust(expected: expected); trust = delegate
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 100; config.timeoutIntervalForResource = 110
        session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        pairingTask?.cancel()
        pairingTask = Task {
            do {
                if expected != nil { try await refreshModels(); busy = false; return }
                var bytes = [UInt8](repeating: 0, count: 32)
                guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else { throw ConnectionError.message("Güvenli eşleştirme başlatılamadı.") }
                let nonce = bytes.map { String(format: "%02x", $0) }.joined()
                _ = try await request("/pair", body: ["nonce": nonce, "name": UIDevice.current.name], authorized: false)
                guard let fingerprint = delegate.fingerprint else { throw ConnectionError.message("Bilgisayar doğrulanamadı.") }
                let digest = Array(SHA256.hash(data: Data((fingerprint + nonce).utf8)))
                let value = digest.prefix(4).reduce(UInt32(0)) { ($0 << 8) | UInt32($1) } % 1_000_000
                code = String(format: "%06u", value); status = "Kodlar aynıysa bilgisayarından onayla."
                for _ in 0..<60 {
                    try await Task.sleep(for: .seconds(2)); try Task.checkCancellation()
                    let data = try await request("/pair/status", body: ["nonce": nonce], authorized: false)
                    let reply = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if reply?["status"] as? String == "expired" { throw ConnectionError.message("Eşleştirme süresi doldu veya reddedildi.") }
                    if let token = reply?["token"] as? String {
                        let saved = PairedComputer(name: sender.name, serviceName: sender.name, fingerprint: fingerprint, token: token)
                        try SecurePair.save(saved); paired = saved; code = nil
                        try await refreshModels(); busy = false; return
                    }
                }
                throw ConnectionError.message("Eşleştirme süresi doldu. Tekrar dene.")
            } catch {
                if !Task.isCancelled { status = error.localizedDescription; code = nil; busy = false; online = false }
            }
        }
    }
    func refreshModels() async throws {
        struct Response: Decodable { let models: [LocalModel] }
        models = try JSONDecoder().decode(Response.self, from: await request("/models")).models
        online = true
        status = models.isEmpty ? "Bağlandı. Bilgisayarında yerel model sunucusunu aç, ardından yenile." : "Bağlandı. Modelini seçerek devam et."
    }
    func request(_ path: String, body: [String: Any]? = nil, authorized: Bool = true) async throws -> Data {
        guard let base, let session else { throw ConnectionError.message("Bilgisayar çevrimdışı. Girdin telefonda kaydedildi.") }
        var request = URLRequest(url: base.appending(path: path))
        if let body { request.httpMethod = "POST"; request.httpBody = try JSONSerialization.data(withJSONObject: body); request.setValue("application/json", forHTTPHeaderField: "Content-Type") }
        if authorized, let paired { request.setValue("Bearer \(paired.token)", forHTTPHeaderField: "Authorization") }
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw ConnectionError.message("Bağlantı veya model yanıtı alınamadı. Girdin korunuyor; bağlantıyı ve modeli kontrol et.")
        }
        return data
    }
    func disconnect() {
        pairingTask?.cancel(); selected?.stop(); session?.invalidateAndCancel(); session = nil; base = nil
        paired = nil; models = []; code = nil; busy = false; online = false; SecurePair.clear()
        status = "Bilgisayarında Persoo Connect’i aç."
    }
}
