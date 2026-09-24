import Foundation
import Combine

// MARK: - Enums

enum BillingCycle: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"

    var abbreviation: String {
        switch self {
        case .weekly: return "/wk"
        case .monthly: return "/mo"
        case .yearly: return "/yr"
        }
    }

    /// Cost normalised to a monthly amount
    func monthlyEquivalent(of price: Double) -> Double {
        switch self {
        case .weekly:  return price * 52.0 / 12.0
        case .monthly: return price
        case .yearly:  return price / 12.0
        }
    }

    var dateComponent: DateComponents {
        switch self {
        case .weekly:  return DateComponents(day: 7)
        case .monthly: return DateComponents(month: 1)
        case .yearly:  return DateComponents(year: 1)
        }
    }
}

struct SubscriptionCategory: Codable, Hashable, Equatable, Identifiable {
    var id: String { rawValue }
    var rawValue: String
    var emoji: String
    
    init(rawValue: String, emoji: String) {
        self.rawValue = rawValue
        self.emoji = emoji
    }
    
    init(rawValue: String) {
        self.rawValue = rawValue
        // Find default emoji if it matches a default category, otherwise 📦
        let matched = SubscriptionCategory.defaultCases.first { $0.rawValue == rawValue }
        self.emoji = matched?.emoji ?? "📦"
    }

    static let streaming = SubscriptionCategory(rawValue: "Streaming", emoji: "🎬")
    static let music = SubscriptionCategory(rawValue: "Music", emoji: "🎵")
    static let fitness = SubscriptionCategory(rawValue: "Fitness", emoji: "💪")
    static let productivity = SubscriptionCategory(rawValue: "Productivity", emoji: "🖥️")
    static let gaming = SubscriptionCategory(rawValue: "Gaming", emoji: "🎮")
    static let news = SubscriptionCategory(rawValue: "News", emoji: "📰")
    static let cloud = SubscriptionCategory(rawValue: "Cloud", emoji: "☁️")
    static let other = SubscriptionCategory(rawValue: "Other", emoji: "📦")
    
    static let defaultCases: [SubscriptionCategory] = [
        .streaming, .music, .fitness, .productivity, .gaming, .news, .cloud, .other
    ]
}

// MARK: - Model

struct Subscription: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var price: Double
    var billingCycle: BillingCycle
    var nextBillingDate: Date
    var colorHex: String
    var category: SubscriptionCategory
    var icon: String        // emoji string chosen by user
    var notes: String
    var accountName: String? // Which account it belongs to
    var paymentHistory: [PaymentHistory] = []
    var isArchived: Bool = false
    var currencyCode: String = "USD"

    enum CodingKeys: String, CodingKey {
        case id, name, price, billingCycle, nextBillingDate, colorHex, category, icon, notes, accountName, paymentHistory, isArchived, currencyCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        billingCycle = try container.decode(BillingCycle.self, forKey: .billingCycle)
        nextBillingDate = try container.decode(Date.self, forKey: .nextBillingDate)
        colorHex = try container.decode(String.self, forKey: .colorHex)
        category = try container.decode(SubscriptionCategory.self, forKey: .category)
        icon = try container.decode(String.self, forKey: .icon)
        notes = try container.decode(String.self, forKey: .notes)
        accountName = try container.decodeIfPresent(String.self, forKey: .accountName)
        paymentHistory = try container.decodeIfPresent([PaymentHistory].self, forKey: .paymentHistory) ?? []
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
        currencyCode = try container.decodeIfPresent(String.self, forKey: .currencyCode) ?? "USD"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(billingCycle, forKey: .billingCycle)
        try container.encode(nextBillingDate, forKey: .nextBillingDate)
        try container.encode(colorHex, forKey: .colorHex)
        try container.encode(category, forKey: .category)
        try container.encode(icon, forKey: .icon)
        try container.encode(notes, forKey: .notes)
        try container.encodeIfPresent(accountName, forKey: .accountName)
        try container.encode(paymentHistory, forKey: .paymentHistory)
        try container.encode(isArchived, forKey: .isArchived)
        try container.encode(currencyCode, forKey: .currencyCode)
    }

    var displayAccountName: String {
        if let acc = accountName?.trimmingCharacters(in: .whitespacesAndNewlines), !acc.isEmpty {
            return acc
        }
        return "Personal"
    }

    /// Monthly normalised cost
    var monthlyCost: Double {
        billingCycle.monthlyEquivalent(of: price)
    }

    /// Days until next billing
    var daysUntilNextBilling: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: nextBillingDate).day ?? 0
    }

    /// True if due within 7 days
    var isDueSoon: Bool {
        daysUntilNextBilling >= 0 && daysUntilNextBilling <= 7
    }

    /// Default initialiser
    init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        billingCycle: BillingCycle,
        nextBillingDate: Date,
        colorHex: String = "6C63FF",
        category: SubscriptionCategory = .other,
        icon: String = "📦",
        notes: String = "",
        accountName: String? = nil,
        paymentHistory: [PaymentHistory] = [],
        isArchived: Bool = false,
        currencyCode: String = "USD"
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.billingCycle = billingCycle
        self.nextBillingDate = nextBillingDate
        self.colorHex = colorHex
        self.category = category
        self.icon = icon
        self.notes = notes
        self.accountName = accountName
        self.paymentHistory = paymentHistory
        self.isArchived = isArchived
        self.currencyCode = currencyCode
    }
}

