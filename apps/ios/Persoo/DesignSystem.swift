import SwiftUI

/// Content stays on opaque surfaces; the system renders glass for navigation and actions.
struct PersooBackdrop: View {
    var accent: Color = .indigo
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                if !reduceTransparency {
                    RadialGradient(colors: [accent.opacity(0.22), accent.opacity(0.06), .clear], center: .init(x: 0.85, y: 0.95), startRadius: 0, endRadius: geometry.size.height * 0.65)
                    RadialGradient(colors: [Color.blue.opacity(0.10), .clear], center: .init(x: 0.05, y: 0.3), startRadius: 0, endRadius: geometry.size.width)
                }
            }
        }.ignoresSafeArea().allowsHitTesting(false).accessibilityHidden(true)
    }
}
struct ContentSurface: ViewModifier {
    var accent: Color = .white
    func body(content: Content) -> some View {
        content.padding(22)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(colors: [accent.opacity(0.09), Color(white: 0.055)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay { RoundedRectangle(cornerRadius: 28, style: .continuous).strokeBorder(.white.opacity(0.065), lineWidth: 0.5) }
            }
    }
}
extension View {
    func contentSurface(accent: Color = .white) -> some View { modifier(ContentSurface(accent: accent)) }
}
struct SectionEyebrow: View {
    let text: String
    var body: some View { Text(text).font(.caption.weight(.semibold)).tracking(1.2).foregroundStyle(.secondary) }
}
