import SwiftUI

// MARK: - App Theme

enum AppTheme {

    // MARK: Colours
    static let background    = Color(red: 0.051, green: 0.051, blue: 0.082)   // #0D0D15
    static let surface       = Color.white.opacity(0.07)
    static let surfaceStrong = Color.white.opacity(0.11)
    static let border        = Color.white.opacity(0.10)
    static let borderStrong  = Color.white.opacity(0.20)

    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.55)
    static let textTertiary  = Color.white.opacity(0.30)

    // Accent
    static let accentPurple  = Color(red: 0.486, green: 0.227, blue: 0.929)  // #7C3AED
    static let accentIndigo  = Color(red: 0.310, green: 0.275, blue: 0.898)  // #4F46E5
    static let accentGradient = LinearGradient(
        colors: [Color(red: 0.486, green: 0.227, blue: 0.929),
                 Color(red: 0.310, green: 0.275, blue: 0.898)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Status
    static let success = Color(red: 0.204, green: 0.780, blue: 0.349)  // #34C759
    static let warning = Color(red: 1.000, green: 0.584, blue: 0.000)  // #FF9500
    static let danger  = Color(red: 1.000, green: 0.231, blue: 0.188)  // #FF3B30

    // Corner radii
    static let radiusSm: CGFloat = 10
    static let radiusMd: CGFloat = 16
    static let radiusLg: CGFloat = 22
}

// MARK: - Color Extension

extension Color {
    // Hex initialiser (supports 3, 6, 8 digit)
    init?(hex: String) {
        var raw = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                     .replacingOccurrences(of: "#", with: "")
        if raw.count == 3 {
            raw = raw.map { "\($0)\($0)" }.joined()
        }
        guard raw.count == 6 || raw.count == 8 else { return nil }
        var value: UInt64 = 0
        guard Scanner(string: raw).scanHexInt64(&value) else { return nil }
        let hasAlpha = raw.count == 8
        let r = CGFloat((value >> (hasAlpha ? 24 : 16)) & 0xFF) / 255
        let g = CGFloat((value >> (hasAlpha ? 16 : 8))  & 0xFF) / 255
        let b = CGFloat((value >> (hasAlpha ? 8  : 0))  & 0xFF) / 255
        let a = hasAlpha ? CGFloat(value & 0xFF) / 255 : 1.0
        self.init(red: r, green: g, blue: b, opacity: a)
    }

    // Convert Color → hex string
    func toHex() -> String {
        let uic = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uic.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02lX%02lX%02lX",
                      lroundf(Float(r) * 255),
                      lroundf(Float(g) * 255),
                      lroundf(Float(b) * 255))
    }
}

// MARK: - Preset Accent Colors

let presetColors: [(name: String, hex: String)] = [
    ("Purple", "7C3AED"),
    ("Indigo", "4F46E5"),
    ("Blue",   "007AFF"),
    ("Pink",   "FF2D55"),
    ("Red",    "FF3B30"),
    ("Orange", "FF9500"),
    ("Yellow", "FFCC00"),
    ("Green",  "34C759"),
    ("Teal",   "5AC8FA"),
    ("Gray",   "8E8E93"),
]

// MARK: - Category Colors

extension SubscriptionCategory {
    var accentColor: Color {
        switch self.rawValue {
        case SubscriptionCategory.streaming.rawValue:    return Color(hex: "FF2D55")!
        case SubscriptionCategory.music.rawValue:        return Color(hex: "7C3AED")!
        case SubscriptionCategory.fitness.rawValue:      return Color(hex: "34C759")!
        case SubscriptionCategory.productivity.rawValue: return Color(hex: "007AFF")!
        case SubscriptionCategory.gaming.rawValue:       return Color(hex: "FF9500")!
        case SubscriptionCategory.news.rawValue:         return Color(hex: "8E8E93")!
        case SubscriptionCategory.cloud.rawValue:        return Color(hex: "5AC8FA")!
        default:                                         return Color.white.opacity(0.45)
        }
    }
}

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.radiusMd
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = AppTheme.radiusMd, padding: CGFloat = 16) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - Pill Tag

struct PillTag: View {
    let text: String
    var color: Color = AppTheme.accentPurple

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.accentPurple)

            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)

            Spacer()
        }
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Backward Compatibility Modifiers

extension View {
    @ViewBuilder
    func customToolbarBackground() -> some View {
        if #available(iOS 16.0, *) {
            self
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
        } else {
            self
        }
    }

    @ViewBuilder
    func customScrollBackground() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self.onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}
