import SwiftUI

extension Color {
    init(hex: UInt32) { self.init(red: Double((hex >> 16) & 255)/255, green: Double((hex >> 8) & 255)/255, blue: Double(hex & 255)/255) }
}
struct Palette {
    var dark = false
    var canvas: Color { Color(hex: dark ? 0x111715 : 0xF8F9F7) }
    var surface: Color { Color(hex: dark ? 0x1D2522 : 0xFFFFFF) }
    var ink: Color { Color(hex: dark ? 0xF0F5F2 : 0x172520) }
    var secondary: Color { Color(hex: dark ? 0xADBDB3 : 0x56645D) }
    var accent: Color { Color(hex: dark ? 0x84D3B5 : 0x176B56) }
    var soft: Color { Color(hex: dark ? 0x263C32 : 0xE5EEE8) }
    var line: Color { Color(hex: dark ? 0x415148 : 0xD5DED7) }
}
struct DesignEnvironment: EnvironmentKey { static let defaultValue = Palette() }
extension EnvironmentValues { var persoo: Palette { get { self[DesignEnvironment.self] } set { self[DesignEnvironment.self] = newValue } } }

struct LabelText: View {
    @Environment(\.persoo) var p
    var text: String
    var body: some View { Text(text).font(.system(size: 12, weight: .semibold)).tracking(1.6).foregroundStyle(p.secondary) }
}
struct PrimaryAction: View {
    @Environment(\.persoo) var p
    var title: String
    var symbol: String? = nil
    var quiet = false
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) { if let symbol { Image(systemName: symbol) }; Text(title) }
                .font(.system(size: 17, weight: .semibold)).frame(maxWidth: .infinity).frame(height: 52)
                .foregroundStyle(quiet ? p.accent : p.canvas).background(quiet ? p.soft : p.accent, in: Capsule())
        }.buttonStyle(.plain)
    }
}
struct Rule: View {
    @Environment(\.persoo) var p
    var body: some View { Rectangle().fill(p.line).frame(height: 0.5) }
}
struct DetailRow: View {
    @Environment(\.persoo) var p
    var symbol: String
    var title: String
    var subtitle: String
    var value: String = ""
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: symbol).font(.system(size: 20, weight: .medium)).foregroundStyle(p.accent).frame(width: 26)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 17, weight: .medium))
                Text(subtitle).font(.system(size: 13)).foregroundStyle(p.secondary)
            }
            Spacer(minLength: 8)
            Text(value).font(.system(size: 17, weight: .semibold)).monospacedDigit()
        }.foregroundStyle(p.ink).padding(.vertical, 14).frame(minHeight: 64)
    }
}
struct LedgerRow: View {
    @Environment(\.persoo) var p
    var merchant: String; var category: String; var amount: String
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 5) { Text(merchant).font(.system(size: 18, weight: .medium)); Text(category).font(.system(size: 14)).foregroundStyle(p.secondary) }
            Spacer(); Text(amount).font(.system(size: 19, weight: .medium)).monospacedDigit()
        }.padding(.vertical, 14)
    }
}
struct Metric: View {
    @Environment(\.persoo) var p
    var value: String; var unit: String; var caption: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(value).font(.system(size: 54, weight: .semibold)).tracking(-2).monospacedDigit()
                Text(unit).font(.system(size: 20, weight: .medium)).foregroundStyle(p.secondary)
            }
            Text(caption).font(.system(size: 15)).foregroundStyle(p.secondary)
        }
    }
}
struct SectionTitle: View {
    @Environment(\.persoo) var p
    var title: String; var trailing: String = ""
    var body: some View { HStack { Text(title).font(.system(size: 21, weight: .semibold)); Spacer(); Text(trailing).font(.system(size: 14, weight: .medium)).foregroundStyle(p.accent) }.padding(.top, 12) }
}
struct WeekBars: View {
    @Environment(\.persoo) var p
    var body: some View {
        HStack(alignment: .bottom, spacing: 13) {
            ForEach(Array(zip(["M","T","W","T","F","S","S"], [68.0,0,86,0,76,0,0]).enumerated()), id: \.offset) { index, item in
                VStack(spacing: 10) {
                    ZStack(alignment: .bottom) { Capsule().fill(p.soft).frame(height: 90); Capsule().fill(p.accent).frame(height: max(item.1, 4)) }.frame(width: 30)
                    Text(item.0).font(.system(size: 12, weight: .medium)).foregroundStyle(p.secondary)
                }.frame(maxWidth: .infinity)
            }
        }.padding(.vertical, 16).accessibilityLabel("Three workouts this week: Monday, Wednesday and Friday")
    }
}
struct AgendaRow: View {
    @Environment(\.persoo) var p
    var time: String; var end: String; var title: String; var place: String; var current = false
    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 5) { Text(time).font(.system(size: 17, weight: .semibold)); Text(end).font(.system(size: 13)).foregroundStyle(p.secondary) }.frame(width: 52, alignment: .leading)
            RoundedRectangle(cornerRadius: 2).fill(current ? p.accent : p.line).frame(width: 3, height: 78)
            VStack(alignment: .leading, spacing: 8) { Text(title).font(.system(size: 20, weight: .semibold)); Text(place).font(.system(size: 14)).foregroundStyle(p.secondary); if current { Text("NEXT CLASS").font(.system(size: 10, weight: .bold)).tracking(1).foregroundStyle(p.accent) } }
            Spacer(minLength: 0)
        }.padding(.vertical, 16)
    }
}
struct ContextFact: View {
    @Environment(\.persoo) var p
    var title: String; var source: String; var inferred = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text(inferred ? "INFERRED" : "YOU TOLD PERSOO").font(.system(size: 10, weight: .bold)).tracking(1.3).foregroundStyle(p.accent); Spacer(); Image(systemName: "ellipsis").frame(width: 44, height: 24) }
            Text(title).font(.system(size: 19, weight: .medium))
            Text(source).font(.system(size: 13)).foregroundStyle(p.secondary)
            if inferred { HStack(spacing: 24) { Text("That's right"); Text("Correct"); Text("Forget") }.font(.system(size: 13, weight: .medium)).foregroundStyle(p.accent) }
        }.padding(.vertical, 18)
    }
}
