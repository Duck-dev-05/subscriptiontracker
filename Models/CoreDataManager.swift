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
public class CDSubscription: NSManagedObject, Identifiable {
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
}
