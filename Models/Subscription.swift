import Foundation
import Combine

enum BillingCycle: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

struct Subscription: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var price: Double
    var billingCycle: BillingCycle
    var nextBillingDate: Date
    var colorHex: String
    
    // Convenience property for UI
    var cycleAbbreviation: String {
        switch billingCycle {
        case .weekly: return "/wk"
        case .monthly: return "/mo"
        case .yearly: return "/yr"
        }
    }
}

class SubscriptionManager: ObservableObject {
    @Published var subscriptions: [Subscription] = [] {
        didSet {
            save()
        }
    }
    
    private let saveKey = "SavedSubscriptions"
    
    init() {
        load()
    }
    
    func add(_ subscription: Subscription) {
        subscriptions.append(subscription)
    }
    
    func delete(at offsets: IndexSet) {
        subscriptions.remove(atOffsets: offsets)
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Subscription].self, from: data) {
                self.subscriptions = decoded
                return
            }
        }
        self.subscriptions = []
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
