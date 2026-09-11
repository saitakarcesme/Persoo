import AVFoundation
import Speech
import ActivityKit
import SwiftUI

@MainActor final class SpeechCapture: NSObject, ObservableObject, AVAudioRecorderDelegate {
    static let shared = SpeechCapture()
    @Published var recording = false
    @Published var transcribing = false
    @Published var startedAt = Date()
    @Published var error: String?
    @Published var savedAudio: [URL] = []
    private var recorder: AVAudioRecorder?
    private var activity: Activity<RecordingAttributes>?
    private var recognition: SFSpeechRecognitionTask?
    private var timeout: Task<Void, Never>?
    private var interruption: NSObjectProtocol?
    override init() {
        super.init(); refreshAudio()
        interruption = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] notification in
            guard let value = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  value == AVAudioSession.InterruptionType.began.rawValue else { return }
            Task { @MainActor in if self?.recording == true { _ = try? await self?.stop() } }
        }
    }
    func refreshAudio() {
        savedAudio = ((try? FileManager.default.contentsOfDirectory(at: AppStore.directory, includingPropertiesForKeys: nil)) ?? []).filter { $0.pathExtension == "m4a" }.sorted { $0.lastPathComponent > $1.lastPathComponent }
    }
    func requestPermissions() async -> Bool {
        let microphone = await AVAudioApplication.requestRecordPermission()
        _ = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
        return microphone
    }
    func start(requireLiveActivity: Bool = false) throws {
        guard !recording, !transcribing else { throw ConnectionError.message("Bir ses işlemi zaten devam ediyor.") }
        guard AVAudioApplication.shared.recordPermission == .granted else {
            throw ConnectionError.message("Önce Persoo’yu açıp mikrofon iznini ver.")
        }
        guard !requireLiveActivity || ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw ConnectionError.message("Uygulamayı açmadan kayıt için Persoo Canlı Etkinliklerini etkinleştir.")
        }
        startedAt = Date()
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            do {
                activity = try Activity.request(attributes: RecordingAttributes(startedAt: startedAt), content: ActivityContent(state: .init(recording: true), staleDate: nil), pushType: nil)
            } catch { if requireLiveActivity { throw error } }
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            try FileManager.default.createDirectory(at: AppStore.directory, withIntermediateDirectories: true)
            let url = AppStore.directory.appending(path: "voice-\(Int(Date().timeIntervalSince1970))-\(UUID()).m4a")
            let next = try AVAudioRecorder(url: url, settings: [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 16000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue])
            next.delegate = self
            guard next.record() else { throw ConnectionError.message("Ses kaydı başlatılamadı.") }
            recorder = next; recording = true; error = nil
            timeout = Task { try? await Task.sleep(for: .seconds(120)); if !Task.isCancelled && recording { _ = try? await stop() } }
        } catch {
            let old = activity; activity = nil
            Task { await old?.end(nil, dismissalPolicy: .immediate) }
            try? AVAudioSession.sharedInstance().setActive(false)
            throw error
        }
    }
    @discardableResult func stop() async throws -> String {
        guard let recorder, recording else { throw ConnectionError.message("Aktif kayıt yok.") }
        let url = recorder.url
        recorder.stop(); self.recorder = nil; recording = false; timeout?.cancel(); timeout = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        await activity?.end(nil, dismissalPolicy: .immediate); activity = nil
        refreshAudio()
        do { return try await transcribe(url) }
        catch { self.error = "Ses telefona kaydedildi. Yazıya çevirme bekliyor: \(error.localizedDescription)"; throw error }
    }
    func cancel() async {
        let url = recorder?.url
        recorder?.stop(); recorder = nil; recording = false; timeout?.cancel(); timeout = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        await activity?.end(nil, dismissalPolicy: .immediate); activity = nil
        if let url { try? FileManager.default.removeItem(at: url) }
        refreshAudio()
    }
    func transcribe(_ url: URL) async throws -> String {
        guard !transcribing else { throw ConnectionError.message("Yazıya çevirme devam ediyor.") }
        guard SFSpeechRecognizer.authorizationStatus() == .authorized,
              let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "tr-TR")), recognizer.supportsOnDeviceRecognition else {
            throw ConnectionError.message("Bu cihazda Türkçe çevrimdışı dikte hazır değil. Ses kaydı korunuyor.")
        }
        transcribing = true; defer { transcribing = false; recognition = nil }
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = true; request.shouldReportPartialResults = false
        let text: String = try await withCheckedThrowingContinuation { continuation in
            let gate = RecognitionGate(continuation)
            recognition = recognizer.recognitionTask(with: request) { result, error in
                if let result, result.isFinal { gate.finish(.success(result.bestTranscription.formattedString)) }
                else if let error { gate.finish(.failure(error)) }
            }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(45))
                if gate.finish(.failure(ConnectionError.message("Yazıya çevirme zaman aşımına uğradı."))) { self.recognition?.cancel() }
            }
        }
        // Delete audio only after a successful durable inbox write.
        try await AppStore.shared.save(text)
        try? FileManager.default.removeItem(at: url); refreshAudio()
        return text
    }
}
final class RecognitionGate: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<String, Error>?
    init(_ continuation: CheckedContinuation<String, Error>) { self.continuation = continuation }
    @discardableResult func finish(_ result: Result<String, Error>) -> Bool {
        lock.lock(); let target = continuation; continuation = nil; lock.unlock()
        target?.resume(with: result); return target != nil
    }
}
