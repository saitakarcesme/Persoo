import SwiftUI
import PersooCore

@MainActor final class AppStore: ObservableObject {
    static let shared = AppStore()
    @Published var events: [InputEvent] = []
    @Published var error: String?
    @Published var processing = false
    @Published var name: String { didSet { UserDefaults.standard.set(name, forKey: "name") } }
    @Published var areas: Set<LifeArea> { didSet { UserDefaults.standard.set(areas.map(\.rawValue), forKey: "areas") } }
    @Published var model: String { didSet { UserDefaults.standard.set(model, forKey: "model") } }
    @Published var onboarded: Bool { didSet { UserDefaults.standard.set(onboarded, forKey: "onboarded") } }
    private var inbox: RecordStore?
    static var directory: URL { URL.applicationSupportDirectory.appending(path: "Persoo") }
    private init() {
        name = UserDefaults.standard.string(forKey: "name") ?? ""
        areas = Set((UserDefaults.standard.stringArray(forKey: "areas") ?? []).compactMap(LifeArea.init(rawValue:)))
        model = UserDefaults.standard.string(forKey: "model") ?? ""
        onboarded = UserDefaults.standard.bool(forKey: "onboarded")
        do {
            try FileManager.default.createDirectory(at: Self.directory, withIntermediateDirectories: true, attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication])
            inbox = try RecordStore(url: Self.directory.appending(path: "inbox.json"))
        } catch { self.error = "Kayıt dosyası açılamadı; üzerine yazılmadı. \(error.localizedDescription)" }
    }
    func reload() async { if let inbox { events = await inbox.all() } }
    @discardableResult func save(_ text: String) async throws -> InputEvent {
        guard let inbox else { throw ConnectionError.message("Kayıt deposu kullanılamıyor.") }
        let event = try await inbox.append(text: text)
        await reload(); return event
    }
    func process(_ event: InputEvent, connection: Connection) async {
        guard !processing, let inbox else { return }
        processing = true; defer { processing = false }
        do {
            let context = events.filter { $0.status == .applied }.prefix(40).flatMap(\.proposals)
            let contextData = try JSONEncoder().encode(context)
            let data = try await connection.request("/process", body: [
                "id": event.id.uuidString, "text": event.text, "model": model,
                "areas": areas.map(\.rawValue), "context": try JSONSerialization.jsonObject(with: contextData)
            ])
            let result = try JSONDecoder().decode(ModelResult.self, from: data)
            try await inbox.propose(id: event.id, result: result, enabled: areas)
            await reload()
        } catch { self.error = "Girdin kaydedildi. İşlenemedi: \(error.localizedDescription)" }
    }
    func accept(_ event: InputEvent) async { do { try await inbox?.accept(id: event.id); await reload() } catch { self.error = error.localizedDescription } }
    func undo(_ event: InputEvent) async { do { try await inbox?.undo(id: event.id); await reload() } catch { self.error = error.localizedDescription } }
    var records: [RecordProposal] { events.filter { $0.status == .applied }.flatMap(\.proposals) }
}

extension LifeArea {
    var tint: Color {
        switch self {
        case .notes: .init(red: 0.66, green: 0.58, blue: 1)
        case .finance: .init(red: 0.65, green: 0.9, blue: 0.35)
        case .fitness: .init(red: 1, green: 0.52, blue: 0.30)
        case .health: .init(red: 1, green: 0.43, blue: 0.58)
        case .school: .init(red: 0.39, green: 0.67, blue: 1)
        case .plans: .init(red: 1, green: 0.79, blue: 0.35)
        case .travel: .init(red: 0.33, green: 0.85, blue: 0.77)
        }
    }
}
