import Foundation
import Testing
@testable import PersooCore

private func location() -> URL { FileManager.default.temporaryDirectory.appending(path: "persoo-tests/\(UUID())/inbox.json") }
@Test func survivesRestartAndDeduplicates() async throws {
    let url = location(), id = UUID()
    let store = try RecordStore(url: url)
    try await store.append(text: "Market 25 euro", id: id)
    try await store.append(text: "Duplicate", id: id)
    let reopened = try RecordStore(url: url)
    let events = await reopened.all()
    #expect(events.count == 1)
    #expect(events[0].text == "Market 25 euro")
    #expect(events[0].status == .pending)
}
@Test func rejectsUnselectedDomainWithoutChangingInbox() async throws {
    let store = try RecordStore(url: location())
    let event = try await store.append(text: "25 euro")
    let result = ModelResult(kind: "record", records: [.init(area: .finance, title: "Market", detail: "", amountMinor: 2500, currency: "EUR")])
    await #expect(throws: RecordError.self) { try await store.propose(id: event.id, result: result, enabled: [.notes]) }
    #expect(await store.all().first?.status == .pending)
}
@Test func reviewAcceptUndoAndLateRetry() async throws {
    let store = try RecordStore(url: location())
    let event = try await store.append(text: "Yarın spor")
    let result = ModelResult(kind: "record", records: [.init(area: .fitness, title: "Spor", detail: "Yarın")])
    try await store.propose(id: event.id, result: result, enabled: [.fitness])
    #expect(await store.all().first?.status == .review)
    try await store.accept(id: event.id)
    try await store.undo(id: event.id)
    try await store.propose(id: event.id, result: result, enabled: [.fitness])
    #expect(await store.all().first?.status == .undone)
}
@Test func rejectsMalformedMoneyAndQuestionMutation() async throws {
    let store = try RecordStore(url: location())
    let event = try await store.append(text: "Harcama")
    let record = RecordProposal(area: .finance, title: "Market", detail: "", amountMinor: 2, currency: nil)
    await #expect(throws: RecordError.self) { try await store.propose(id: event.id, result: .init(kind: "record", records: [record]), enabled: [.finance]) }
    await #expect(throws: RecordError.self) { try await store.propose(id: event.id, result: .init(kind: "answer", records: [record], answer: "2"), enabled: [.finance]) }
}
@Test func corruptFileIsNotSilentlyReplaced() throws {
    let url = location()
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try Data("broken".utf8).write(to: url)
    #expect(throws: (any Error).self) { try RecordStore(url: url) }
    #expect(try String(contentsOf: url, encoding: .utf8) == "broken")
}

@Test func moneyMustMatchExplicitSource() async throws {
    let store = try RecordStore(url: location())
    let event = try await store.append(text: "I spent 25 EUR on groceries.")
    let wrong = RecordProposal(area: .finance, title: "Groceries", detail: "25 EUR", amountMinor: 25, currency: "EUR")
    await #expect(throws: RecordError.self) { try await store.propose(id: event.id, result: .init(kind: "record", records: [wrong]), enabled: [.finance]) }
    #expect(await store.all().first?.status == .pending)
    var correct = wrong; correct.amountMinor = 2500
    try await store.propose(id: event.id, result: .init(kind: "record", records: [correct]), enabled: [.finance])
    #expect(await store.all().first?.status == .review)
}
@Test func decimalMoneyAndAmbiguity() {
    #expect(MoneyEvidence.extract(from: "12,50 euro").first?.amountMinor == 1250)
    #expect(MoneyEvidence.extract(from: "EUR 25").first?.amountMinor == 2500)
    #expect(MoneyEvidence.extract(from: "1.250,50 EUR").isEmpty)
    #expect(MoneyEvidence.extract(from: "25 repetitions").isEmpty)
}
