import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class SubscriptionManager: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    
    @Published var currencySymbol: String = "$" {
        didSet { UserDefaults.standard.set(currencySymbol, forKey: currencyKey) }
    }

    private let currencyKey = "CurrencySymbol"
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        currencySymbol = UserDefaults.standard.string(forKey: currencyKey) ?? "$"
        
        // Listen for authentication state changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                self?.listenToFirestore(userId: user.uid)
            } else {
                self?.subscriptions = []
                self?.listenerRegistration?.remove()
            }
        }
    }
    
    deinit {
        listenerRegistration?.remove()
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: CRUD
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    func add(_ subscription: Subscription) {
        guard let uid = userId else { return }
        do {
            try db.collection("users").document(uid).collection("subscriptions").document(subscription.id.uuidString).setData(from: subscription)
            NotificationManager.shared.scheduleNotification(for: subscription)
        } catch {
            print("Error adding to Firestore: \(error)")
        }
    }

    func update(_ subscription: Subscription) {
        guard let uid = userId else { return }
        do {
            try db.collection("users").document(uid).collection("subscriptions").document(subscription.id.uuidString).setData(from: subscription)
            NotificationManager.shared.scheduleNotification(for: subscription)
        } catch {
            print("Error updating in Firestore: \(error)")
        }
    }

    func delete(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { subscriptions[$0] }
        for item in itemsToDelete {
            delete(item)
        }
    }

    func delete(_ subscription: Subscription) {
        guard let uid = userId else { return }
        db.collection("users").document(uid).collection("subscriptions").document(subscription.id.uuidString).delete()
        NotificationManager.shared.cancelNotification(for: subscription.id.uuidString)
    }

    func clearAll() {
        guard let uid = userId else { return }
        let ref = db.collection("users").document(uid).collection("subscriptions")
        ref.getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            for doc in docs {
                doc.reference.delete()
            }
            NotificationManager.shared.cancelAllNotifications()
        }
    }

    // MARK: Computed
    
    var activeSubscriptions: [Subscription] {
        subscriptions.filter { !$0.isArchived }
    }
    
    var archivedSubscriptions: [Subscription] {
        subscriptions.filter { $0.isArchived }
    }

    var totalMonthlyCost: Double {
        activeSubscriptions.reduce(0) { $0 + $1.monthlyCost }
    }

    var totalYearlyCost: Double {
        totalMonthlyCost * 12
    }

    var dueSoon: [Subscription] {
        activeSubscriptions.filter { $0.isDueSoon }.sorted { $0.daysUntilNextBilling < $1.daysUntilNextBilling }
    }

    var uniqueAccounts: [String] {
        let accounts = activeSubscriptions.map { $0.displayAccountName }
        return Array(Set(accounts)).sorted()
    }

    func subscriptions(forAccount account: String) -> [Subscription] {
        activeSubscriptions.filter { $0.displayAccountName == account }
    }

    // MARK: Persistence (Firestore)

    private func listenToFirestore(userId: String) {
        listenerRegistration?.remove()
        
        let ref = db.collection("users").document(userId).collection("subscriptions")
        listenerRegistration = ref.addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            self?.subscriptions = documents.compactMap { doc -> Subscription? in
                try? doc.data(as: Subscription.self)
            }
        }
    }
}
