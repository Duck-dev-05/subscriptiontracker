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

enum SubscriptionCategory: String, Codable, CaseIterable {
    case streaming   = "Streaming"
    case music       = "Music"
    case fitness     = "Fitness"
    case productivity = "Productivity"
    case gaming      = "Gaming"
    case news        = "News"
    case cloud       = "Cloud"
    case other       = "Other"

    var emoji: String {
        switch self {
        case .streaming:    return "🎬"
        case .music:        return "🎵"
        case .fitness:      return "💪"
        case .productivity: return "🖥️"
        case .gaming:       return "🎮"
        case .news:         return "📰"
        case .cloud:        return "☁️"
        case .other:        return "📦"
        }
    }
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
        isArchived: Bool = false
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
    }
}

