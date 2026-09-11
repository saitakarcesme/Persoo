import SwiftUI
import PersooCore

@main struct PersooApp: App {
    @StateObject private var store = AppStore.shared
    @StateObject private var connection = Connection()
    var body: some Scene {
        WindowGroup {
            Group {
                if store.onboarded { MainView() }
                else { OnboardingView() }
            }.environmentObject(store).environmentObject(connection).preferredColorScheme(.dark)
                .tint(.white)
                .task { connection.discover(); await store.reload() }
                .alert("Persoo", isPresented: Binding(get: { store.error != nil }, set: { if !$0 { store.error = nil } })) {
                    Button("Tamam") { store.error = nil }
                } message: { Text(store.error ?? "") }
        }
    }
}
struct BrandMark: View {
    var body: some View {
        Image(systemName: "waveform")
            .font(.system(size: 48, weight: .light))
            .foregroundStyle(LinearGradient(colors: [.white, Color(white: 0.45)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 88, height: 88).accessibilityHidden(true)
    }
}
struct PrimaryButton: View {
    let title: String
    var disabled = false
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack { Text(title).fontWeight(.semibold); Spacer(); Image(systemName: "arrow.right") }
                .foregroundStyle(.black).padding(.horizontal, 18).frame(minHeight: 52).frame(maxWidth: .infinity)
        }.buttonStyle(.glassProminent).tint(.white).disabled(disabled)
    }
}
struct OnboardingView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var connection: Connection
    @State private var step = 0
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    HStack {
                        Text("persoo").font(.system(size: 24, weight: .semibold, design: .rounded)).tracking(-1)
                        Spacer()
                        Text("\(step + 1) / 4").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    }.padding(.top, 12)
                    HStack(spacing: 6) { ForEach(0..<4) { index in Capsule().fill(index <= step ? Color.white : Color.white.opacity(0.1)).frame(height: 3) } }
                    Group {
                        switch step {
                        case 0: connectionStep
                        case 1: nameStep
                        case 2: welcomeStep
                        default: areasStep
                        }
                    }
                }.padding(26)
            }.background(PersooBackdrop())
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 12) {
                        PrimaryButton(title: step == 3 ? "Persoo’yu aç" : "Devam et", disabled: cannotContinue) {
                            withAnimation(.snappy) { if step < 3 { step += 1 } else { store.onboarded = true } }
                        }
                        if step > 0 { Button("Geri") { withAnimation { step -= 1 } }.font(.subheadline).foregroundStyle(.secondary) }
                    }.padding(.horizontal, 26).padding(.vertical, 14).background(Color.black)
                }
        }
    }
    private var cannotContinue: Bool {
        switch step {
        case 0: connection.paired == nil || !connection.online || !connection.models.contains(where: { $0.id == store.model })
        case 1: store.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.name.count > 60
        case 3: store.areas.isEmpty
        default: false
        }
    }
    private var connectionStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            BrandMark().padding(.top, 18)
            Text("Kendi modelin.\nKendi alanın.").font(.system(size: 38, weight: .semibold)).tracking(-1.5)
            Text("Bilgisayarındaki modeli Persoo’ya bağla. Anlattıkların senin cihazlarında kalsın.").font(.body).foregroundStyle(.secondary).lineSpacing(4)
            ConnectionPanel()
            VStack(alignment: .leading, spacing: 14) {
                instruction("1", "Bilgisayarında Persoo Connect’i aç.")
                instruction("2", "Telefonunu aynı yerel ağa bağla.")
                instruction("3", "Bilgisayarını seç ve kodu onayla.")
            }.padding(.top, 4)
            Label("Hesap yok. Zorunlu bulut yok.", systemImage: "lock.shield").font(.caption).foregroundStyle(.secondary)
        }
    }
    private func instruction(_ number: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Text(number).font(.caption.weight(.semibold)).frame(width: 26, height: 26).background(.white.opacity(0.08), in: Circle())
            Text(text).font(.subheadline).foregroundStyle(.secondary)
        }
    }
    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 26) {
            BrandMark().padding(.top, 30)
            Text("Sana nasıl\nhitap edelim?").font(.system(size: 38, weight: .semibold)).tracking(-1.5)
            Text("Sadece ismin yeterli.").foregroundStyle(.secondary)
            TextField("İsmin", text: $store.name).font(.title2).textContentType(.givenName).autocorrectionDisabled()
                .padding(22).background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 22))
        }
    }
    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: 26) {
            BrandMark().padding(.top, 40)
            Text("Hoş geldin,\n\(store.name.trimmingCharacters(in: .whitespacesAndNewlines)).").font(.system(size: 40, weight: .semibold)).tracking(-1.5)
            Text("Hayatını düzenlemek için uzun formlar doldurman gerekmiyor. Sadece anlat.").font(.title3).foregroundStyle(.secondary).lineSpacing(6)
            Label("Anlat veya yaz", systemImage: "waveform")
            Label("Kayıtlarını kontrol et", systemImage: "checkmark.rectangle")
            Label("Kendi ritmini gör", systemImage: "chart.bar.xaxis")
        }
    }
    private var areasStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Persoo’da\nneler olsun?").font(.system(size: 38, weight: .semibold)).tracking(-1.5).padding(.top, 26)
            Text("Bir veya birkaç alan seç. Sonradan değiştirebilirsin.").foregroundStyle(.secondary)
            ForEach(LifeArea.allCases) { area in
                Button {
                    if store.areas.contains(area) { store.areas.remove(area) } else { store.areas.insert(area) }
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: area.symbol).frame(width: 26).foregroundStyle(area.tint)
                        Text(area.title).foregroundStyle(.white)
                        Spacer()
                        Image(systemName: store.areas.contains(area) ? "checkmark.circle.fill" : "circle").foregroundStyle(store.areas.contains(area) ? area.tint : .gray)
                    }.padding(20).background(area.tint.opacity(store.areas.contains(area) ? 0.14 : 0.055), in: RoundedRectangle(cornerRadius: 22))
                }.buttonStyle(.plain)
            }
        }
    }
}
struct ConnectionPanel: View {
    @EnvironmentObject private var connection: Connection
    @EnvironmentObject private var store: AppStore
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(connection.online ? "Bilgisayar bağlı" : "Bilgisayarın", systemImage: "laptopcomputer").font(.headline)
                Spacer()
                Button { connection.discover() } label: { Image(systemName: "arrow.clockwise").frame(width: 44, height: 44) }.accessibilityLabel("Bilgisayarları yeniden ara")
            }
            Text(connection.status).font(.subheadline).foregroundStyle(.secondary)
            if let code = connection.code {
                Text(code).font(.system(size: 36, weight: .medium, design: .monospaced)).tracking(7).foregroundStyle(.mint)
                Button("İptal et") { connection.disconnect() }
            }
            if connection.busy && connection.code == nil { ProgressView() }
            ForEach(connection.computers, id: \.name) { computer in
                Button { connection.connect(computer) } label: {
                    HStack { Image(systemName: "desktopcomputer"); Text(computer.name); Spacer(); Image(systemName: "arrow.up.right") }
                        .padding(.vertical, 10)
                }.disabled(connection.busy)
            }
            if connection.paired != nil {
                ForEach(connection.models) { model in
                    Button { store.model = model.id } label: {
                        HStack {
                            VStack(alignment: .leading) { Text(model.name); Text(model.provider).font(.caption).foregroundStyle(.secondary) }
                            Spacer(); Image(systemName: store.model == model.id ? "checkmark.circle.fill" : "circle")
                        }.padding(.vertical, 8)
                    }
                }
                Button("Modelleri yenile") {
                    Task { do { try await connection.refreshModels() } catch { connection.status = error.localizedDescription } }
                }.font(.subheadline)
            }
        }.contentSurface()
            .onChange(of: connection.models.map(\.id)) { _, ids in if ids.count == 1, let first = ids.first { store.model = first } }
    }
}
