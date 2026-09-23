import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "SubscriptionTracker")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    func fetchAllSubscriptions() -> [CDSubscription] {
        let request = NSFetchRequest<CDSubscription>(entityName: "CDSubscription")
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching subscriptions: \(error)")
            return []
        }
    }
}

@objc(CDSubscription)
public class CDSubscription: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var billingCycle: String?
    @NSManaged public var nextBillingDate: Date?
    @NSManaged public var colorHex: String?
    @NSManaged public var category: String?
    @NSManaged public var icon: String?
    @NSManaged public var notes: String?
    @NSManaged public var accountName: String?
    @NSManaged public var isArchived: Bool
    @NSManaged public var paymentHistoryData: Data?

    var toSubscription: Subscription? {
        guard let id = id,
              let name = name,
              let billingCycleStr = billingCycle,
              let cycle = BillingCycle(rawValue: billingCycleStr),
              let nextBillingDate = nextBillingDate,
              let categoryStr = category,
              let subCategory = SubscriptionCategory(rawValue: categoryStr)
        else { return nil }
        
        var history: [PaymentHistory] = []
        if let data = paymentHistoryData,
           let decoded = try? JSONDecoder().decode([PaymentHistory].self, from: data) {
            history = decoded
        }

        return Subscription(
            id: id,
            name: name,
            price: price,
            billingCycle: cycle,
            nextBillingDate: nextBillingDate,
            colorHex: colorHex ?? "6C63FF",
            category: subCategory,
            icon: icon ?? "📦",
            notes: notes ?? "",
            accountName: accountName,
            paymentHistory: history,
            isArchived: isArchived
        )
    }

    func update(from sub: Subscription) {
        self.id = sub.id
        self.name = sub.name
        self.price = sub.price
        self.billingCycle = sub.billingCycle.rawValue
        self.nextBillingDate = sub.nextBillingDate
        self.colorHex = sub.colorHex
        self.category = sub.category.rawValue
        self.icon = sub.icon
        self.notes = sub.notes
        self.accountName = sub.accountName
        self.isArchived = sub.isArchived
        self.paymentHistoryData = try? JSONEncoder().encode(sub.paymentHistory)
    }
}
