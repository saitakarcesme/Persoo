import SwiftUI
import Charts
import PersooCore

struct MainView: View {
    @EnvironmentObject private var store: AppStore
    @State private var settings = false
    var body: some View {
        TabView {
            Tab("Anlat", systemImage: "waveform") {
                NavigationStack { HomeView().toolbar { profileButton } }
            }
            Tab("Hayatım", systemImage: "square.grid.2x2") {
                NavigationStack { LifeView().toolbar { profileButton } }
            }
            Tab("Planlar", systemImage: "sparkles") {
                NavigationStack { AreaDetail(area: .plans).toolbar { profileButton } }
            }
        }.sheet(isPresented: $settings) { NavigationStack { SettingsView() } }
    }
    @ToolbarContentBuilder private var profileButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { settings = true } label: { Image(systemName: "person.crop.circle").font(.title3) }.accessibilityLabel("Ayarlar")
        }
    }
}
struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var connection: Connection
    @StateObject private var capture = SpeechCapture.shared
    @State private var draft = ""
    @State private var typing = false
    @FocusState private var focused: Bool
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if store.events.isEmpty && capture.savedAudio.isEmpty {
                VStack(spacing: 20) {
                    BrandMark()
                    Text("Bugün neler oldu\(store.name.isEmpty ? "" : ", \(store.name)")?")
                        .font(.system(size: 31, weight: .medium)).tracking(-0.8).multilineTextAlignment(.center)
                    Text("Bir düşünce, küçük bir harcama,\nyarın için bir plan. Sadece anlat.")
                        .font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center).lineSpacing(5)
                    HStack(spacing: 10) {
                        ForEach(LifeArea.allCases.filter { store.areas.contains($0) }.prefix(4)) { area in
                            Image(systemName: area.symbol).foregroundStyle(area.tint).frame(width: 44, height: 44)
                                .background(area.tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 15)).accessibilityLabel(area.title)
                        }
                    }.padding(.top, 8)
                }.padding(28).padding(.bottom, 60)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        Text("Anlattıkların").font(.largeTitle.bold()).padding(.bottom, 6)
                        ForEach(capture.savedAudio, id: \.path) { url in
                            HStack {
                                Image(systemName: "waveform").foregroundStyle(.mint)
                                VStack(alignment: .leading) { Text("Ses kaydı güvende"); Text("Yazıya çevrilmeyi bekliyor").font(.caption).foregroundStyle(.secondary) }
                                Spacer()
                                Button("Çevir") { Task { do { _ = try await capture.transcribe(url) } catch { capture.error = error.localizedDescription } } }.disabled(capture.transcribing)
                            }.padding(20).background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 24))
                        }
                        ForEach(store.events.filter { $0.status != .undone }) { event in ReceiptView(event: event) }
                        if store.events.allSatisfy({ $0.status == .undone }) && capture.savedAudio.isEmpty {
                            Text("Kayıtlar geri alındı. Yeni bir şey anlatabilirsin.").foregroundStyle(.secondary)
                        }
                    }.padding(24)
                }.scrollDismissesKeyboard(.interactively)
            }
        }
        .toolbar { ToolbarItem(placement: .topBarLeading) { Text("persoo").font(.system(size: 25, weight: .semibold, design: .rounded)).tracking(-1).fixedSize() }.sharedBackgroundVisibility(.hidden) }
        .safeAreaInset(edge: .bottom, spacing: 0) { inputBar }
        .task { await store.reload(); capture.refreshAudio() }
        .alert("Ses kaydı", isPresented: Binding(get: { capture.error != nil }, set: { if !$0 { capture.error = nil } })) {
            Button("Tamam") { capture.error = nil }
        } message: { Text(capture.error ?? "") }
    }
    private var inputBar: some View {
        VStack(spacing: 12) {
            if capture.recording {
                HStack(spacing: 16) {
                    Image(systemName: "waveform").symbolEffect(.variableColor.iterative).foregroundStyle(.mint)
                    Text("Dinliyorum").fontWeight(.medium)
                    Spacer()
                    Text(capture.startedAt, style: .timer).monospacedDigit()
                    Button("İptal") { Task { await capture.cancel() } }.foregroundStyle(.secondary)
                }.padding(.horizontal, 20)
            } else if capture.transcribing {
                HStack { ProgressView(); Text("Cihazında yazıya çevriliyor…").font(.caption).foregroundStyle(.secondary) }
            }
            if typing {
                HStack(alignment: .bottom) {
                    TextField("Aklındakini yaz…", text: $draft, axis: .vertical).lineLimit(1...5).focused($focused).padding(.vertical, 12)
                    Button { submit() } label: { Image(systemName: "arrow.up").fontWeight(.semibold).frame(width: 44, height: 44).background(.mint, in: Circle()).foregroundStyle(.black) }
                        .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).accessibilityLabel("Kaydet")
                }.padding(12).glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28))
            }
            HStack(spacing: 0) {
                Button { toggleRecording() } label: {
                    HStack(spacing: 10) { Image(systemName: capture.recording ? "stop.fill" : "mic.fill"); Text(capture.recording ? "Bitir" : "Anlat").fontWeight(.medium) }
                        .frame(maxWidth: .infinity).frame(height: 58)
                }.disabled(capture.transcribing)
                Rectangle().fill(.white.opacity(0.15)).frame(width: 1, height: 22)
                Button {
                    withAnimation(.snappy) { typing.toggle() }; focused = typing
                } label: { Image(systemName: "keyboard").font(.title3).frame(width: 78, height: 58) }.disabled(capture.recording).accessibilityLabel("Klavye ile yaz")
            }.foregroundStyle(.white).glassEffect(.regular.interactive(), in: Capsule()).frame(maxWidth: 280)
            if !typing && !capture.recording {
                HStack(spacing: 5) {
                    Circle().fill(connection.online ? Color.mint : Color.gray).frame(width: 5, height: 5)
                    Text(connection.online ? "Kendi modeline bağlı" : "Çevrimdışı · kayıtların burada kalır").font(.caption2).foregroundStyle(.secondary)
                }
            }
        }.padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 16)
    }
    private func submit() {
        let text = draft
        Task {
            do {
                let event = try await store.save(text); draft = ""; focused = false; typing = false
                if connection.online { await store.process(event, connection: connection) }
            } catch { store.error = error.localizedDescription }
        }
    }
    private func toggleRecording() {
        Task {
            do {
                if capture.recording {
                    _ = try await capture.stop()
                    if connection.online, let latest = store.events.first { await store.process(latest, connection: connection) }
                } else if await capture.requestPermissions() {
                    focused = false; typing = false; try capture.start()
                } else { capture.error = "Mikrofon izni kapalı. Ayarlar’dan izin verebilir veya klavyeyle yazabilirsin." }
            } catch { capture.error = error.localizedDescription }
        }
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
                            Text(Double(minor) / 100, format: .currency(code: currency)).foregroundStyle(proposal.area.tint)
                        }
                    }
                }
            }
            HStack {
                if event.status == .review {
                    Button("Kayıtları onayla") { Task { await store.accept(event) } }.buttonStyle(.borderedProminent).tint(.mint)
                }
                if event.status == .pending {
                    Button(store.processing ? "İşleniyor…" : "Modelle işle") { Task { await store.process(event, connection: connection) } }.disabled(store.processing || !connection.online)
                }
                Spacer()
                Button(event.status == .applied ? "Geri al" : "Vazgeç") { Task { await store.undo(event) } }.foregroundStyle(.secondary)
            }.font(.subheadline)
        }.padding(22).background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 26))
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
struct LifeView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Hayatına\nküçük bir bakış.").font(.system(size: 34, weight: .semibold)).tracking(-1)
                Text("Seçtiğin alanlar, anlattıklarınla şekillenir.").foregroundStyle(.secondary)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 14)], spacing: 14) {
                    ForEach(LifeArea.allCases.filter { store.areas.contains($0) }) { area in
                        NavigationLink { AreaDetail(area: area) } label: {
                            VStack(alignment: .leading, spacing: 20) {
                                Image(systemName: area.symbol).font(.title2)
                                Spacer(minLength: 8)
                                Text(area.title).font(.headline)
                                Text("\(store.records.filter { $0.area == area }.count) kayıt").font(.subheadline).opacity(0.7)
                            }.frame(maxWidth: .infinity, minHeight: 140, alignment: .leading).padding(20).foregroundStyle(area.tint)
                                .background(area.tint.opacity(0.13), in: RoundedRectangle(cornerRadius: 28))
                        }.buttonStyle(.plain)
                    }
                }
            }.padding(24)
        }.background(Color.black).navigationTitle("Hayatım").navigationBarTitleDisplayMode(.inline)
    }
}
struct AreaDetail: View {
    let area: LifeArea
    @EnvironmentObject private var store: AppStore
    private var records: [RecordProposal] { store.records.filter { $0.area == area } }
    private var week: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            let count = store.events.filter { $0.status == .applied && calendar.isDate($0.createdAt, inSameDayAs: date) }.flatMap(\.proposals).filter { $0.area == area }.count
            return (date, count)
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: area.symbol).font(.system(size: 38)).foregroundStyle(area.tint).padding(.top, 20)
                Text(area.title).font(.largeTitle.bold())
                if records.isEmpty {
                    Text("İlk kaydınla başlar.").font(.title2)
                    Text("Ana sayfada bu alanla ilgili bir şey anlat. Onayladığın kayıtlar burada görünecek.").foregroundStyle(.secondary).lineSpacing(5)
                    if !store.areas.contains(area) { Button("Bu alanı etkinleştir") { store.areas.insert(area) }.buttonStyle(.borderedProminent) }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Son 7 gün · eklenen kayıtlar").font(.subheadline).foregroundStyle(.secondary)
                        Chart(week, id: \.date) { point in
                            BarMark(x: .value("Gün", point.date, unit: .day), y: .value("Kayıt", point.count)).foregroundStyle(area.tint).cornerRadius(5)
                        }.frame(height: 150)
                        Text("Grafik kayıt oluşturma gününü gösterir.").font(.caption2).foregroundStyle(.secondary)
                    }.padding(22).background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 26))
                    ForEach(records) { record in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(record.title).font(.headline)
                            Text(record.detail).foregroundStyle(.secondary)
                            if let minor = record.amountMinor, let currency = record.currency { Text(Double(minor) / 100, format: .currency(code: currency)).foregroundStyle(area.tint) }
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(22).background(area.tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 24))
                    }
                }
            }.padding(24)
        }.background(Color.black).navigationBarTitleDisplayMode(.inline)
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
