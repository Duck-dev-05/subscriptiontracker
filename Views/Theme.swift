import SwiftUI

// MARK: - Color Palette

extension Color {
    // Backgrounds
    static let appBackground   = Color(hex: "0D0D1A")!
    static let cardBackground  = Color(hex: "16162A")!
    static let surfaceColor    = Color(hex: "1E1E35")!

    // Accents
    static let accentIndigo    = Color(hex: "6C63FF")!
    static let accentViolet    = Color(hex: "9B59F5")!
    static let accentPink      = Color(hex: "F561B8")!
    static let accentTeal      = Color(hex: "2EDFB3")!
    static let accentOrange    = Color(hex: "FF845E")!
    static let accentRed       = Color(hex: "FF4D6D")!
    static let accentGold      = Color(hex: "FFD166")!

    // Text
    static let textPrimary     = Color.white
    static let textSecondary   = Color(hex: "8A8AAD")!
    static let textMuted       = Color(hex: "4A4A6A")!

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

// MARK: - Gradients

extension LinearGradient {
    static let heroGradient = LinearGradient(
        colors: [Color.accentIndigo, Color.accentViolet, Color.accentPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let tealGradient = LinearGradient(
        colors: [Color.accentTeal, Color.accentIndigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [Color.cardBackground, Color.surfaceColor],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Preset Accent Colors

let presetColors: [(name: String, hex: String)] = [
    ("Indigo",  "6C63FF"),
    ("Violet",  "9B59F5"),
    ("Pink",    "F561B8"),
    ("Teal",    "2EDFB3"),
    ("Orange",  "FF845E"),
    ("Red",     "FF4D6D"),
    ("Gold",    "FFD166"),
    ("Blue",    "3A86FF"),
    ("Green",   "06D6A0"),
    ("Coral",   "EF476F"),
]

// MARK: - View Modifiers

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.cardBackground.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                    )
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient.heroGradient
                    .cornerRadius(16)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension View {
    func glassCard() -> some View {
        self.modifier(GlassCardModifier())
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - Category Colors

extension SubscriptionCategory {
    var accentColor: Color {
        switch self {
        case .streaming:    return .accentPink
        case .music:        return .accentViolet
        case .fitness:      return .accentTeal
        case .productivity: return .accentIndigo
        case .gaming:       return .accentOrange
        case .news:         return .accentGold
        case .cloud:        return Color(hex: "3A86FF")!
        case .other:        return .textSecondary
        }
    }
}
