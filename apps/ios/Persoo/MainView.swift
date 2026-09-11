import SwiftUI
import Charts
import PersooCore

private enum MainSheet: String, Identifiable { case settings, history, compose; var id: String { rawValue } }
struct MainView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var connection: Connection
    @StateObject private var capture = SpeechCapture.shared
    @State private var sheet: MainSheet?
    var body: some View {
        TabView {
            Tab("Anlat", systemImage: "waveform") {
                NavigationStack { HomeView(showHistory: { sheet = .history }).toolbar { profileButton } }
            }
            Tab("Hayatım", systemImage: "square.grid.2x2") {
                NavigationStack { LifeView().toolbar { profileButton } }
            }
            Tab("Planlar", systemImage: "sparkles") {
                NavigationStack { AreaDetail(area: .plans).toolbar { profileButton } }
            }
        }
        .tint(.white)
        .tabViewBottomAccessory {
            HStack(spacing: 12) {
                Button { toggleRecording() } label: {
                    Image(systemName: capture.recording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 20, weight: .medium)).foregroundStyle(capture.recording ? Color.red : .primary)
                        .frame(width: 48, height: 48)
                }.buttonStyle(.plain).disabled(capture.transcribing).accessibilityLabel(capture.recording ? "Kaydı bitir" : "Sesli kayıt başlat")
                VStack(alignment: .leading, spacing: 2) {
                    Text(capture.recording ? "Seni dinliyorum" : capture.transcribing ? "Yazıya çevriliyor" : "Bir şey kaydet")
                        .font(.subheadline.weight(.medium))
                    if capture.recording { Text(capture.startedAt, style: .timer).font(.caption.monospacedDigit()).foregroundStyle(.secondary) }
                    else { Text("Sesinle veya yazarak").font(.caption).foregroundStyle(.secondary) }
                }.frame(maxWidth: .infinity, alignment: .leading)
                if capture.recording {
                    Button { Task { await capture.cancel() } } label: { Image(systemName: "xmark").frame(width: 48, height: 48) }.accessibilityLabel("Kaydı iptal et")
                } else {
                    Button { sheet = .compose } label: { Image(systemName: "keyboard").font(.title3).frame(width: 48, height: 48) }.accessibilityLabel("Klavye ile yaz")
                }
            }.padding(.horizontal, 8).padding(.vertical, 4)
        }
        .sheet(item: $sheet) { item in
            NavigationStack {
                switch item {
                case .settings: SettingsView()
                case .history: HistoryView()
                case .compose: ComposeView()
                }
            }.presentationDragIndicator(.visible).presentationCornerRadius(32)
        }
        .task { await store.reload(); capture.refreshAudio() }
        .alert("Ses kaydı", isPresented: Binding(get: { capture.error != nil }, set: { if !$0 { capture.error = nil } })) {
            Button("Tamam") { capture.error = nil }
        } message: { Text(capture.error ?? "") }
    }
    @ToolbarContentBuilder private var profileButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { sheet = .settings } label: { Image(systemName: "person.crop.circle").font(.title3).foregroundStyle(.primary) }.accessibilityLabel("Ayarlar")
        }
    }
    private func toggleRecording() {
        Task {
            do {
                if capture.recording {
                    _ = try await capture.stop()
                    if connection.online, let latest = store.events.first { await store.process(latest, connection: connection) }
                } else if await capture.requestPermissions() { try capture.start() }
                else { capture.error = "Mikrofon izni kapalı. Ayarlar’dan izin verebilir veya klavyeyle yazabilirsin." }
            } catch { capture.error = error.localizedDescription }
        }
    }
}
struct HomeView: View {
    let showHistory: () -> Void
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var connection: Connection
    @StateObject private var capture = SpeechCapture.shared
    @ScaledMetric(relativeTo: .largeTitle) private var heroSize = 44.0
    private var latest: InputEvent? { store.events.first { $0.status != .undone } }
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 28)
                    VStack(spacing: 16) {
                        Text(store.name.isEmpty ? "Sana ait bir alan" : "Merhaba, \(store.name)").font(.subheadline).foregroundStyle(.secondary)
                        Text("Aklında\nne var?").font(.system(size: heroSize, weight: .semibold)).tracking(-1.7).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                        Text("Bir düşünce. Bir plan. Bugünden bir an.")
                            .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 20)
                    }.padding(.vertical, 24)
                    Spacer(minLength: 36)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            SectionEyebrow(text: latest == nil ? "SENİN ALANIN" : "SON ETKİNLİK")
                            Spacer()
                            HStack(spacing: 5) {
                                Circle().fill(connection.online ? Color.green : Color.gray).frame(width: 5, height: 5)
                                Text(connection.online ? "Yerel bağlantı" : "Çevrimdışı").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                        if let latest {
                            Button(action: showHistory) {
                                HStack(spacing: 14) {
                                    Image(systemName: latest.status == .pending ? "tray.and.arrow.down" : "checkmark")
                                        .font(.system(size: 17, weight: .medium)).foregroundStyle(.primary)
                                        .frame(width: 42, height: 42).background(.white.opacity(0.07), in: Circle())
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(latest.status == .pending ? "İşlenmeyi bekliyor" : latest.status == .review ? "Kontrolünü bekliyor" : "Son kaydın")
                                            .font(.caption).foregroundStyle(.secondary)
                                        Text(latest.proposals.first?.title ?? latest.text).font(.subheadline.weight(.medium)).lineLimit(2).foregroundStyle(.primary)
                                    }
                                    Spacer(minLength: 0)
                                    Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
                                }.contentSurface()
                            }.buttonStyle(.plain)
                        } else {
                            HStack(spacing: 12) {
                                ForEach(LifeArea.allCases.filter { store.areas.contains($0) }.prefix(4)) { area in
                                    VStack(spacing: 9) {
                                        Image(systemName: area.symbol).font(.title3).foregroundStyle(area.tint)
                                        Text(area.title).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                                    }.frame(maxWidth: .infinity).padding(.vertical, 18)
                                }
                            }.contentSurface()
                        }
                        if !capture.savedAudio.isEmpty {
                            Button(action: showHistory) { Label("\(capture.savedAudio.count) ses kaydı yazıya çevrilmeyi bekliyor", systemImage: "waveform").font(.caption) }
                        }
                        Text("Anlattıkların cihazlarında kalır.").font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                    }.padding(.bottom, 24)
                }.padding(.horizontal, 24).frame(minHeight: geometry.size.height)
            }.background(PersooBackdrop())
        }
        .navigationTitle("persoo").navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarLeading) { Button(action: showHistory) { Image(systemName: "clock.arrow.circlepath") }.accessibilityLabel("Kayıt geçmişi") } }
    }
}
struct ComposeView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var connection: Connection
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var saving = false
    @FocusState private var focused: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Aklındakini bırak.").font(.title2.weight(.semibold)).padding(.top, 12)
            TextField("Bugün neler oldu?", text: $draft, axis: .vertical)
                .font(.title3).lineLimit(5...12).autocorrectionDisabled().focused($focused)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            Spacer(minLength: 0)
            Label(connection.online ? "Kendi modelin işleyecek" : "Bağlantı gelene kadar telefonda kalacak", systemImage: "lock")
                .font(.caption).foregroundStyle(.secondary)
        }.padding(24).background(PersooBackdrop())
            .navigationTitle("Yeni kayıt").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("İptal", systemImage: "xmark") { dismiss() }.labelStyle(.iconOnly) }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet", systemImage: "arrow.up") {
                        saving = true
                        Task {
                            do {
                                let event = try await store.save(draft); dismiss()
                                if connection.online { await store.process(event, connection: connection) }
                            } catch { store.error = error.localizedDescription; saving = false }
                        }
                    }.labelStyle(.iconOnly).buttonStyle(.glassProminent).tint(.white)
                        .disabled(saving || draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }.task { focused = true }
            .interactiveDismissDisabled(!draft.isEmpty)
    }
}
struct HistoryView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var capture = SpeechCapture.shared
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                ForEach(capture.savedAudio, id: \.path) { url in
                    HStack {
                        Image(systemName: "waveform").foregroundStyle(.orange)
                        VStack(alignment: .leading) { Text("Ses kaydı güvende"); Text("Yazıya çevrilmeyi bekliyor").font(.caption).foregroundStyle(.secondary) }
                        Spacer()
                        Button("Çevir") { Task { do { _ = try await capture.transcribe(url) } catch { capture.error = error.localizedDescription } } }.disabled(capture.transcribing)
                    }.contentSurface()
                }
                if store.events.allSatisfy({ $0.status == .undone }) && capture.savedAudio.isEmpty {
                    ContentUnavailableView("Henüz kayıt yok", systemImage: "tray", description: Text("Anlattıkların burada birikir."))
                }
                ForEach(store.events.filter { $0.status != .undone }) { event in ReceiptView(event: event) }
            }.padding(20)
        }.background(PersooBackdrop()).navigationTitle("Kayıtların").navigationBarTitleDisplayMode(.large)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Bitti", systemImage: "checkmark") { dismiss() }.labelStyle(.iconOnly) } }
    }
}
struct ReceiptView: View {
    let event: InputEvent
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var connection: Connection
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(status, systemImage: event.status == .pending ? "tray.and.arrow.down" : "checkmark.circle")
                    .font(.caption.weight(.medium)).foregroundStyle(event.status == .pending ? .secondary : Color.mint)
                Spacer(); Text(event.createdAt, style: .time).font(.caption).foregroundStyle(.secondary)
            }
            Text(event.text).font(.body).textSelection(.enabled)
            if let answer = event.answer { Text(answer).foregroundStyle(.mint).textSelection(.enabled) }
            ForEach(event.proposals) { proposal in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: proposal.area.symbol).foregroundStyle(proposal.area.tint).frame(width: 24)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(proposal.title).fontWeight(.medium)
                        if !proposal.detail.isEmpty { Text(proposal.detail).font(.subheadline).foregroundStyle(.secondary) }
                        if let minor = proposal.amountMinor, let currency = proposal.currency {
                            Text(Double(minor) / 100, format: .currency(code: currency)).font(.title2.weight(.semibold)).monospacedDigit().foregroundStyle(proposal.area.tint)
                        }
                    }
                }
            }
            HStack {
                if event.status == .review {
                    Button("Kayıtları onayla") { Task { await store.accept(event) } }.buttonStyle(.glassProminent).tint(.white)
                }
                if event.status == .pending {
                    Button(store.processing ? "İşleniyor…" : "Modelle işle") { Task { await store.process(event, connection: connection) } }.disabled(store.processing || !connection.online)
                }
                Spacer()
                Button(event.status == .applied ? "Geri al" : "Vazgeç") { Task { await store.undo(event) } }.foregroundStyle(.secondary)
            }.font(.subheadline)
        }.contentSurface(accent: event.proposals.first?.area.tint ?? .white)
    }
    private var status: String {
        switch event.status {
        case .pending: "Telefona kaydedildi"
        case .review: "\(event.proposals.count) kayıt önerisi · kontrol et"
        case .applied: event.answer != nil ? "Kayıtlarından yanıt" : "\(event.proposals.count) kayıt eklendi"
        case .undone: "Geri alındı"
        }
    }
}
struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var connection: Connection
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Form {
            Section("Sen") { TextField("İsmin", text: $store.name) }
            Section("Bilgisayar ve model") {
                ConnectionPanel()
                if connection.paired != nil { Button("Bu bilgisayarla eşleştirmeyi kaldır", role: .destructive) { connection.disconnect() } }
            }
            Section("Kullanım alanları") {
                ForEach(LifeArea.allCases) { area in
                    Toggle(isOn: Binding(get: { store.areas.contains(area) }, set: { enabled in
                        if enabled { store.areas.insert(area) } else if store.areas.count > 1 { store.areas.remove(area) }
                    })) { Label(area.title, systemImage: area.symbol).foregroundStyle(area.tint) }
                }
            }
            Section("Action Button") {
                Text("Önce ana sayfada bir kez mikrofon izni ver. Ardından iPhone Ayarlar → Eylem Düğmesi → Kestirme → Persoo ile kaydet seç.")
                Text("Kısayol kaydı başlatır; tekrar çalıştırıldığında bitirir. Kayıt en fazla 2 dakika sürer. Uygulamayı açmadan kullanım için Canlı Etkinlikler açık olmalı.").font(.caption).foregroundStyle(.secondary)
            }
            Section("Verilerin") {
                Label("Kayıtlar bu iPhone’da", systemImage: "iphone")
                Label("Model kendi bilgisayarında", systemImage: "desktopcomputer")
                Text("Bilgisayar bağlantısı yokken girdiler bekler. Ses tanıma yalnızca cihaz üzerinde çalışır; buluta aktarılmaz.").font(.caption).foregroundStyle(.secondary)
            }
        }.navigationTitle("Ayarlar").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Bitti") { dismiss() } } }
    }
}
