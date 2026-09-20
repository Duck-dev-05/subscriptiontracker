import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class SubscriptionManager: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    
    @Published var currencySymbol: String = "$" {
        didSet { UserDefaults.standard.set(currencySymbol, forKey: currencyKey) }
    }

    private let currencyKey = "CurrencySymbol"
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    init() {
        currencySymbol = UserDefaults.standard.string(forKey: currencyKey) ?? "$"
        
        // Listen for authentication state changes
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
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
    }

    // MARK: CRUD
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    func add(_ subscription: Subscription) {
        guard let uid = userId else { return }
        do {
            try db.collection("users").document(uid).collection("subscriptions").document(subscription.id.uuidString).setData(from: subscription)
        } catch {
            print("Error adding to Firestore: \(error)")
        }
    }

    func update(_ subscription: Subscription) {
        guard let uid = userId else { return }
        do {
            try db.collection("users").document(uid).collection("subscriptions").document(subscription.id.uuidString).setData(from: subscription)
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
    }

    func clearAll() {
        guard let uid = userId else { return }
        let ref = db.collection("users").document(uid).collection("subscriptions")
        ref.getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            for doc in docs {
                doc.reference.delete()
            }
        }
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
