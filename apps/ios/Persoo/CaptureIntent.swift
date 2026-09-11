import AppIntents

struct CaptureIntent: AudioRecordingIntent {
    static var title: LocalizedStringResource = "Persoo ile kaydet"
    static var description = IntentDescription("Kaydı başlatır; tekrar çalıştırıldığında bitirip telefona kaydeder.")
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed
    @MainActor func perform() async throws -> some IntentResult & ProvidesDialog {
        let capture = SpeechCapture.shared
        if capture.recording {
            do { _ = try await capture.stop(); return .result(dialog: "Kaydın telefona eklendi.") }
            catch { return .result(dialog: "Sesin kaydedildi. Yazıya çevirmek için Persoo’yu aç.") }
        }
        try capture.start(requireLiveActivity: true)
        return .result(dialog: "Persoo dinliyor. Bitirmek için kısayolu tekrar çalıştır.")
    }
}
struct PersooShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: CaptureIntent(), phrases: ["\(.applicationName) ile kaydet"], shortTitle: "Persoo ile kaydet", systemImageName: "mic.fill")
    }
}
