import SwiftUI
import Foundation

struct Pairing: Identifiable {
    let id: String
    let name: String
    let code: String
}
@MainActor final class Companion: NSObject, ObservableObject, NetServiceDelegate {
    @Published var status = "Bağlantı hazırlanıyor…"
    @Published var pairings: [Pairing] = []
    @Published var models: [String] = []
    @Published var ready = false
    private var process: Process?
    private var commands: FileHandle?
    private var service: NetService?
    func start() {
        guard process == nil else { return }
        let executable = URL(fileURLWithPath: CommandLine.arguments[0])
        let bundled = executable.deletingLastPathComponent().deletingLastPathComponent().appending(path: "Resources/bridge.py")
        let source = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().appending(path: "bridge.py")
        let script = FileManager.default.fileExists(atPath: bundled.path) ? bundled : source
        let p = Process(), input = Pipe(), output = Pipe(), errors = Pipe()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        p.arguments = [script.path]
        p.standardInput = input; p.standardOutput = output; p.standardError = errors
        commands = input.fileHandleForWriting
        do {
            try p.run(); process = p
            let handle = output.fileHandleForReading
            Task.detached { [weak self] in
                var buffer = Data()
                while true {
                    let chunk = handle.availableData
                    if chunk.isEmpty { break }
                    buffer.append(chunk)
                    while let end = buffer.firstIndex(of: 10) {
                        let line = Data(buffer[..<end]); buffer.removeSubrange(...end)
                        await self?.receive(line)
                    }
                }
                await self?.stopped()
            }
        } catch { status = "Başlatılamadı. Apple komut satırı araçları gerekli: \(error.localizedDescription)" }
    }
    func stopped() { ready = false; status = "Persoo Connect durdu." }
    func receive(_ data: Data) {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let event = obj["event"] as? String else { return }
        switch event {
        case "ready":
            guard let port = obj["port"] as? Int else { return }
            let net = NetService(domain: "local.", type: "_persoo._tcp.", name: Host.current().localizedName ?? "Persoo bilgisayarı", port: Int32(port))
            net.delegate = self
            net.setTXTRecord(NetService.data(fromTXTRecord: ["version": Data("1".utf8)]))
            net.publish(); service = net
            status = "iPhone’unda Persoo’yu aç. Bilgisayarın otomatik görünecek."
            ready = true; send(["action": "models"])
        case "pairing":
            if let nonce = obj["nonce"] as? String, let name = obj["name"] as? String, let code = obj["code"] as? String {
                pairings.append(Pairing(id: nonce, name: name, code: code))
                Task { try? await Task.sleep(for: .seconds(120)); pairings.removeAll { $0.id == nonce } }
                NSApp.activate(ignoringOtherApps: true)
            }
        case "models":
            models = (obj["models"] as? [[String: Any]] ?? []).compactMap { $0["name"] as? String }
        case "revoked": status = "Tüm telefonların bağlantısı kaldırıldı."
        case "error": status = obj["message"] as? String ?? "Bağlantı hatası."
        default: break
        }
    }
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        status = "Bilgisayar ağda duyurulamadı. Yerel ağ iznini kontrol et."; ready = false
    }
    func send(_ body: [String: Any]) {
        guard var data = try? JSONSerialization.data(withJSONObject: body) else { return }
        data.append(10); try? commands?.write(contentsOf: data)
    }
    func approve(_ pairing: Pairing, allowed: Bool) {
        send(["action": "approve", "nonce": pairing.id, "approved": allowed])
        pairings.removeAll { $0.id == pairing.id }
    }
    func stop() { service?.stop(); try? commands?.close(); process?.terminate() }
}
@main struct PersooConnectApp: App {
    @StateObject private var companion = Companion()
    var body: some Scene {
        WindowGroup("Persoo Connect") {
            VStack(alignment: .leading, spacing: 26) {
                HStack {
                    Image(systemName: "circle.hexagongrid.fill").font(.largeTitle).foregroundStyle(.mint)
                    VStack(alignment: .leading) { Text("Persoo Connect").font(.title.bold()); Text("Modelin burada. Hayatın yanında.").foregroundStyle(.secondary) }
                }
                Label(companion.status, systemImage: companion.ready ? "checkmark.circle.fill" : "antenna.radiowaves.left.and.right").foregroundStyle(companion.ready ? .mint : .secondary)
                ForEach(companion.pairings) { pairing in
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(pairing.name) bağlanmak istiyor").font(.headline)
                        Text(pairing.code).font(.system(size: 38, weight: .medium, design: .monospaced)).tracking(8)
                        Text("Telefondaki kodla aynıysa onayla.").foregroundStyle(.secondary)
                        HStack { Button("Reddet") { companion.approve(pairing, allowed: false) }; Button("Kod aynı · Bağla") { companion.approve(pairing, allowed: true) }.buttonStyle(.borderedProminent).tint(.mint) }
                    }.padding(20).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 24))
                }
                VStack(alignment: .leading, spacing: 12) {
                    HStack { Text("YEREL MODELLER").font(.caption).foregroundStyle(.secondary); Spacer(); Button("Yenile", systemImage: "arrow.clockwise") { companion.send(["action": "models"]) } }
                    if companion.models.isEmpty { Text("Ollama veya LM Studio sunucusunu aç. Hazır modeller burada görünecek.").foregroundStyle(.secondary) }
                    ForEach(companion.models, id: \.self) { Label($0, systemImage: "cpu") }
                }
                Spacer()
                HStack {
                    Text("Yalnızca eşleştirdiğin telefonlar erişebilir.").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Button("Bağlantıları kaldır") { companion.send(["action": "revokeAll"]) }.font(.caption)
                }
            }.padding(32).frame(minWidth: 550, minHeight: 440).background(Color.black).preferredColorScheme(.dark)
                .task { companion.start() }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in companion.stop() }
        }
    }
}
