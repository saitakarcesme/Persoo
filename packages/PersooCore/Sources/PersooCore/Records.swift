import Foundation

public enum LifeArea: String, Codable, CaseIterable, Identifiable, Sendable {
    case notes, finance, fitness, health, school, plans, travel
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .notes: "Kişisel notlar"
        case .finance: "Finans"
        case .fitness: "Spor"
        case .health: "Sağlık"
        case .school: "Okul"
        case .plans: "Planlarım"
        case .travel: "Gezi"
        }
    }
    public var symbol: String {
        switch self {
        case .notes: "note.text"
        case .finance: "creditcard"
        case .fitness: "figure.strengthtraining.traditional"
        case .health: "heart"
        case .school: "graduationcap"
        case .plans: "sparkles"
        case .travel: "airplane"
        }
    }
}

public struct RecordProposal: Codable, Equatable, Sendable, Identifiable {
    public var id: UUID
    public var area: LifeArea
    public var title: String
    public var detail: String
    public var amountMinor: Int?
    public var currency: String?
    public init(id: UUID = UUID(), area: LifeArea, title: String, detail: String, amountMinor: Int? = nil, currency: String? = nil) {
        self.id = id; self.area = area; self.title = title; self.detail = detail
        self.amountMinor = amountMinor; self.currency = currency
    }
    enum CodingKeys: String, CodingKey { case id, area, title, detail, amountMinor, currency }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        area = try c.decode(LifeArea.self, forKey: .area)
        title = try c.decode(String.self, forKey: .title)
        detail = try c.decode(String.self, forKey: .detail)
        amountMinor = try c.decodeIfPresent(Int.self, forKey: .amountMinor)
        currency = try c.decodeIfPresent(String.self, forKey: .currency)
    }
}
public enum InputStatus: String, Codable, Sendable { case pending, review, applied, undone }
public struct InputEvent: Codable, Sendable, Identifiable {
    public let id: UUID
    public let createdAt: Date
    public var text: String
    public var status: InputStatus
    public var proposals: [RecordProposal]
    public var answer: String?
    public init(id: UUID = UUID(), text: String, createdAt: Date = Date()) {
        self.id = id; self.text = text; self.createdAt = createdAt
        self.status = .pending; self.proposals = []
    }
}
public struct ModelResult: Codable, Sendable {
    public var kind: String
    public var records: [RecordProposal]
    public var answer: String?
    public init(kind: String, records: [RecordProposal], answer: String? = nil) {
        self.kind = kind; self.records = records; self.answer = answer
    }
}
public enum RecordError: Error { case emptyInput, tooLong, invalidResult, unknownInput, invalidTransition }

/// A durable inbox. Persist first, then publish the change to callers.
public actor RecordStore {
    private let url: URL
    private var events: [InputEvent]
    public init(url: URL) throws {
        self.url = url
        if FileManager.default.fileExists(atPath: url.path) {
            events = try JSONDecoder().decode([InputEvent].self, from: Data(contentsOf: url))
        } else { events = [] }
    }
    public func all() -> [InputEvent] { events.sorted { $0.createdAt > $1.createdAt } }
    private func persist(_ next: [InputEvent]) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(next).write(to: url, options: .atomic)
        events = next
    }
    @discardableResult public func append(text: String, id: UUID = UUID()) throws -> InputEvent {
        if let existing = events.first(where: { $0.id == id }) { return existing }
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { throw RecordError.emptyInput }
        guard cleaned.count <= 16_000 else { throw RecordError.tooLong }
        let event = InputEvent(id: id, text: cleaned)
        try persist(events + [event]); return event
    }
    public func propose(id: UUID, result: ModelResult, enabled: Set<LifeArea>) throws {
        guard let index = events.firstIndex(where: { $0.id == id }) else { throw RecordError.unknownInput }
        // A retry cannot overwrite reviewed, accepted or undone state.
        guard events[index].status == .pending else { return }
        guard ["record", "answer"].contains(result.kind), result.records.count <= 20 else { throw RecordError.invalidResult }
        if result.kind == "answer" {
            guard result.records.isEmpty, let answer = result.answer, !answer.isEmpty, answer.count <= 8000 else { throw RecordError.invalidResult }
        } else {
            guard !result.records.isEmpty, result.answer == nil else { throw RecordError.invalidResult }
        }
        for record in result.records {
            guard enabled.contains(record.area), !record.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  record.title.count <= 200, record.detail.count <= 4000 else { throw RecordError.invalidResult }
            if record.amountMinor != nil || record.currency != nil {
                guard record.area == .finance, let amount = record.amountMinor,
                      amount.magnitude <= 100_000_000_000, let currency = record.currency,
                      currency.count == 3, currency.unicodeScalars.allSatisfy({ (65...90).contains($0.value) }) else { throw RecordError.invalidResult }
            }
        }
        guard Set(result.records.map(\.id)).count == result.records.count else { throw RecordError.invalidResult }
        var next = events
        next[index].proposals = result.records; next[index].answer = result.answer
        next[index].status = result.kind == "answer" ? .applied : .review
        try persist(next)
    }
    public func accept(id: UUID) throws {
        guard let index = events.firstIndex(where: { $0.id == id }) else { throw RecordError.unknownInput }
        guard events[index].status == .review else { throw RecordError.invalidTransition }
        var next = events; next[index].status = .applied; try persist(next)
    }
    public func undo(id: UUID) throws {
        guard let index = events.firstIndex(where: { $0.id == id }) else { throw RecordError.unknownInput }
        guard events[index].status != .undone else { return }
        var next = events; next[index].status = .undone; try persist(next)
    }
}
