import SwiftUI

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
    ("Blue",    "007AFF"),
    ("Purple",  "5856D6"),
    ("Indigo",  "5E5CE6"),
    ("Pink",    "FF2D55"),
    ("Red",     "FF3B30"),
    ("Orange",  "FF9500"),
    ("Yellow",  "FFCC00"),
    ("Green",   "34C759"),
    ("Teal",    "5AC8FA"),
    ("Gray",    "8E8E93"),
]

// MARK: - Category Colors

extension SubscriptionCategory {
    var accentColor: Color {
        switch self {
        case .streaming:    return Color(hex: "FF2D55")!
        case .music:        return Color(hex: "5856D6")!
        case .fitness:      return Color(hex: "34C759")!
        case .productivity: return Color(hex: "007AFF")!
        case .gaming:       return Color(hex: "FF9500")!
        case .news:         return Color(hex: "8E8E93")!
        case .cloud:        return Color(hex: "5AC8FA")!
        case .other:        return Color.secondary
        }
    }
}

// MARK: - View Modifiers

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
