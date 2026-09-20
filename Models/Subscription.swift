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

    var displayAccountName: String {
        accountName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? accountName! : "Personal"
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
        accountName: String? = nil
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
    }
}

// MARK: - Manager

class SubscriptionManager: ObservableObject {
    @Published var subscriptions: [Subscription] = [] {
        didSet { save() }
    }

    @Published var currencySymbol: String = "$" {
        didSet { UserDefaults.standard.set(currencySymbol, forKey: currencyKey) }
    }

    private let saveKey     = "SavedSubscriptions_v2"
    private let currencyKey = "CurrencySymbol"

    init() {
        load()
        currencySymbol = UserDefaults.standard.string(forKey: currencyKey) ?? "$"
    }

    // MARK: CRUD

    func add(_ subscription: Subscription) {
        subscriptions.append(subscription)
    }

    func update(_ subscription: Subscription) {
        if let idx = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            subscriptions[idx] = subscription
        }
    }

    func delete(at offsets: IndexSet) {
        subscriptions.remove(atOffsets: offsets)
    }

    func delete(_ subscription: Subscription) {
        subscriptions.removeAll { $0.id == subscription.id }
    }

    func clearAll() {
        subscriptions = []
    }

    // MARK: Computed

    var totalMonthlyCost: Double {
        subscriptions.reduce(0) { $0 + $1.monthlyCost }
    }

    var totalYearlyCost: Double {
        totalMonthlyCost * 12
    }

    var dueSoon: [Subscription] {
        subscriptions.filter { $0.isDueSoon }.sorted { $0.daysUntilNextBilling < $1.daysUntilNextBilling }
    }

    var uniqueAccounts: [String] {
        let accounts = subscriptions.map { $0.displayAccountName }
        return Array(Set(accounts)).sorted()
    }

    func subscriptions(forAccount account: String) -> [Subscription] {
        subscriptions.filter { $0.displayAccountName == account }
    }

    // MARK: Persistence

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Subscription].self, from: data) {
            self.subscriptions = decoded
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
