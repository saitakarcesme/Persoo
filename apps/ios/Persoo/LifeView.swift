import SwiftUI
import Charts
import PersooCore

struct LifeView: View {
    @EnvironmentObject private var store: AppStore
    private var areas: [LifeArea] { LifeArea.allCases.filter { store.areas.contains($0) } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionEyebrow(text: "BİRİKTİRDİKLERİN")
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("\(store.records.count)").font(.system(.largeTitle, design: .rounded).weight(.semibold)).monospacedDigit()
                            Text("kayıt").font(.title3).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Label("\(areas.count) alan", systemImage: "square.grid.2x2")
                        .font(.caption).foregroundStyle(.secondary).padding(.bottom, 4)
                }.padding(.top, 8)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 14)], spacing: 14) {
                    ForEach(areas) { area in
                        NavigationLink { AreaDetail(area: area) } label: {
                            AreaTile(area: area, records: store.records.filter { $0.area == area })
                        }.buttonStyle(.plain)
                    }
                }
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lock.shield").font(.title3)
                    Text("Sen anlattıkça şekillenir.\nYalnızca onayladığın kayıtlar burada görünür.").font(.footnote).lineSpacing(4)
                }.foregroundStyle(.secondary)
            }.padding(24).padding(.bottom, 16)
        }.background(PersooBackdrop(accent: .blue)).navigationTitle("Hayatım").navigationBarTitleDisplayMode(.large)
    }
}
private struct AreaTile: View {
    let area: LifeArea
    let records: [RecordProposal]
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image(systemName: area.symbol).font(.title3).foregroundStyle(area.tint)
                Spacer()
                Image(systemName: "arrow.up.right").font(.caption.weight(.medium)).foregroundStyle(area.tint.opacity(0.65))
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(area.title).font(.headline).foregroundStyle(.white)
                Text("\(records.count)").font(.system(.largeTitle, design: .rounded).weight(.medium)).foregroundStyle(area.tint).monospacedDigit()
            }
            Text(records.first?.title ?? "İlk kaydınla başlar")
                .font(.caption).foregroundStyle(.white.opacity(0.55)).lineLimit(2).frame(minHeight: 30, alignment: .topLeading)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(20)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(colors: [area.tint.opacity(0.23), area.tint.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay { RoundedRectangle(cornerRadius: 28, style: .continuous).strokeBorder(area.tint.opacity(0.18), lineWidth: 0.5) }
            }
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
            VStack(alignment: .leading, spacing: 28) {
                if records.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        Image(systemName: area.symbol).font(.system(size: 40, weight: .light)).foregroundStyle(area.tint)
                        Text("Bir başlangıca\nyer aç.").font(.largeTitle.weight(.semibold)).tracking(-0.8)
                        Text("Bu alanla ilgili bir şey anlat. Onayladığın kayıtları burada bulacaksın.").foregroundStyle(.secondary).lineSpacing(4)
                        if !store.areas.contains(area) {
                            Button("Bu alanı etkinleştir") { store.areas.insert(area) }.buttonStyle(.glassProminent).tint(area.tint)
                        }
                    }.padding(.vertical, 32)
                } else {
                    VStack(alignment: .leading, spacing: 22) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                SectionEyebrow(text: "SON 7 GÜN")
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("\(week.reduce(0) { $0 + $1.count })").font(.system(size: 48, weight: .medium, design: .rounded)).monospacedDigit()
                                    Text("yeni kayıt").font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Image(systemName: area.symbol).font(.title).foregroundStyle(area.tint)
                        }
                        Chart(week, id: \.date) { point in
                            BarMark(x: .value("Gün", point.date, unit: .day), y: .value("Kayıt", point.count), width: .ratio(0.55))
                                .foregroundStyle(LinearGradient(colors: [area.tint, area.tint.opacity(0.35)], startPoint: .top, endPoint: .bottom)).cornerRadius(6)
                        }.chartYScale(domain: 0...max(3, (week.map(\.count).max() ?? 0)))
                            .chartXAxis { AxisMarks(values: .stride(by: .day)) { _ in AxisValueLabel(format: .dateTime.weekday(.narrow)) } }
                            .chartYAxis { AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { _ in AxisGridLine().foregroundStyle(.white.opacity(0.06)); AxisValueLabel() } }
                            .frame(height: 145)
                        Text("Kayıt oluşturma gününe göre").font(.caption2).foregroundStyle(.tertiary)
                    }.contentSurface(accent: area.tint)
                    VStack(alignment: .leading, spacing: 0) {
                        SectionEyebrow(text: "KAYITLAR").padding(.bottom, 18)
                        ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                            HStack(alignment: .top, spacing: 16) {
                                RoundedRectangle(cornerRadius: 2).fill(area.tint).frame(width: 3, height: 34)
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(record.title).font(.body.weight(.medium))
                                    if !record.detail.isEmpty { Text(record.detail).font(.subheadline).foregroundStyle(.secondary) }
                                }
                                Spacer(minLength: 0)
                                if let minor = record.amountMinor, let currency = record.currency {
                                    Text(Double(minor) / 100, format: .currency(code: currency)).font(.headline).monospacedDigit().foregroundStyle(area.tint)
                                }
                            }.padding(.vertical, 16)
                            if index < records.count - 1 { Divider().overlay(.white.opacity(0.04)) }
                        }
                    }
                }
            }.padding(24).padding(.bottom, 16)
        }.background(PersooBackdrop(accent: area.tint)).navigationTitle(area.title).navigationBarTitleDisplayMode(.large)
    }
}
