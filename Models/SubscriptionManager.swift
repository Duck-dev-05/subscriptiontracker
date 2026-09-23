import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth
import CoreData

class SubscriptionManager: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    @Published var isAnonymous: Bool = true
    
    @Published var currencySymbol: String = "$" {
        didSet { UserDefaults.standard.set(currencySymbol, forKey: currencyKey) }
    }

    private let currencyKey = "CurrencySymbol"
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        currencySymbol = UserDefaults.standard.string(forKey: currencyKey) ?? "$"
        
        // 1. Instantly load local data
        fetchLocalData()
        
        // 2. Listen for auth changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.isAnonymous = user?.isAnonymous ?? true
            if let user = user {
                self?.listenToFirestore(userId: user.uid)
            } else {
                Auth.auth().signInAnonymously { result, error in
                    if let error = error { print("Error signing in anonymously: \(error)") }
                }
                self?.listenerRegistration?.remove()
            }
        }
    }
    
    deinit {
        listenerRegistration?.remove()
        if let handle = authStateListenerHandle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    // MARK: - CoreData + Firestore Sync
    
    func fetchLocalData() {
        let cdSubs = CoreDataManager.shared.fetchAllSubscriptions()
        self.subscriptions = cdSubs.compactMap { $0.toSubscription }
        processRollovers()
    }
    
    func processRollovers() {
        var didRollover = false
        for i in 0..<subscriptions.count {
            var sub = subscriptions[i]
            if sub.nextBillingDate < Date() {
                // Add payment history
                let history = PaymentHistory(id: UUID(), amount: sub.price, date: sub.nextBillingDate, status: "Paid")
                sub.paymentHistory.append(history)
                
                // Roll over date
                if let next = Calendar.current.date(byAdding: sub.billingCycle.dateComponent, to: sub.nextBillingDate) {
                    sub.nextBillingDate = next
                }
                
                subscriptions[i] = sub
                updateLocal(sub)
                syncToCloud(sub)
                didRollover = true
            }
        }
        
        if didRollover {
            NotificationManager.shared.scheduleAllNotifications(for: activeSubscriptions)
        }
    }

    private func updateLocal(_ subscription: Subscription) {
        let context = CoreDataManager.shared.context
        let cdSubs = CoreDataManager.shared.fetchAllSubscriptions()
        
        if let existing = cdSubs.first(where: { $0.id == subscription.id }) {
            existing.update(from: subscription)
        } else {
            let newCD = CDSubscription(context: context)
            newCD.update(from: subscription)
        }
        CoreDataManager.shared.saveContext()
    }

    private func deleteLocal(_ id: UUID) {
        let context = CoreDataManager.shared.context
        let cdSubs = CoreDataManager.shared.fetchAllSubscriptions()
        if let existing = cdSubs.first(where: { $0.id == id }) {
            context.delete(existing)
            CoreDataManager.shared.saveContext()
        }
    }

    private func syncToCloud(_ subscription: Subscription) {
        guard !isAnonymous, let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try db.collection("users").document(uid).collection("subscriptions").document(subscription.id.uuidString).setData(from: subscription)
        } catch {
            print("Error syncing to Firestore: \(error)")
        }
    }
    
    private func listenToFirestore(userId: String) {
        listenerRegistration?.remove()
        
        let ref = db.collection("users").document(userId).collection("subscriptions")
        listenerRegistration = ref.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self, let documents = querySnapshot?.documents else { return }
            
            let cloudSubs = documents.compactMap { try? $0.data(as: Subscription.self) }
            
            // Basic conflict resolution: Cloud wins for now.
            for sub in cloudSubs {
                self.updateLocal(sub)
            }
            
            self.fetchLocalData()
        }
    }

    // MARK: - CRUD
    
    func add(_ subscription: Subscription) {
        updateLocal(subscription)
        subscriptions.append(subscription)
        syncToCloud(subscription)
        NotificationManager.shared.scheduleNotification(for: subscription)
    }

    func update(_ subscription: Subscription) {
        updateLocal(subscription)
        if let idx = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            subscriptions[idx] = subscription
        }
        syncToCloud(subscription)
        NotificationManager.shared.scheduleNotification(for: subscription)
    }

    func delete(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { subscriptions[$0] }
        for item in itemsToDelete { delete(item) }
    }

    func delete(_ subscription: Subscription) {
        deleteLocal(subscription.id)
        subscriptions.removeAll { $0.id == subscription.id }
        
        if let uid = Auth.auth().currentUser?.uid, !isAnonymous {
            db.collection("users").document(uid).collection("subscriptions").document(subscription.id.uuidString).delete()
        }
        NotificationManager.shared.cancelNotification(for: subscription.id.uuidString)
    }

    func clearAll() {
        let context = CoreDataManager.shared.context
        let cdSubs = CoreDataManager.shared.fetchAllSubscriptions()
        for cdSub in cdSubs { context.delete(cdSub) }
        CoreDataManager.shared.saveContext()
        
        subscriptions.removeAll()
        
        if let uid = Auth.auth().currentUser?.uid, !isAnonymous {
            let ref = db.collection("users").document(uid).collection("subscriptions")
            ref.getDocuments { snapshot, _ in
                snapshot?.documents.forEach { $0.reference.delete() }
            }
        }
        NotificationManager.shared.cancelAllNotifications()
    }

    // MARK: - Computed
    
    var activeSubscriptions: [Subscription] { subscriptions.filter { !$0.isArchived } }
    var archivedSubscriptions: [Subscription] { subscriptions.filter { $0.isArchived } }
    var totalMonthlyCost: Double { activeSubscriptions.reduce(0) { $0 + $1.monthlyCost } }
    var totalYearlyCost: Double { totalMonthlyCost * 12 }
    var dueSoon: [Subscription] { activeSubscriptions.filter { $0.isDueSoon }.sorted { $0.daysUntilNextBilling < $1.daysUntilNextBilling } }
    
    var uniqueAccounts: [String] {
        let accounts = activeSubscriptions.map { $0.displayAccountName }
        return Array(Set(accounts)).sorted()
    }

    func subscriptions(forAccount account: String) -> [Subscription] {
        activeSubscriptions.filter { $0.displayAccountName == account }
    }
}
