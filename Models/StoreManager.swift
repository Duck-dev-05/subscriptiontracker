import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published var isPro: Bool = false
    @Published var proPrice: String = "$4.99 / month"
    @Published var products: [Product] = []
    
    // Replace with your App Store Connect Product IDs
    private let productIds = ["com.subscriptiontracker.pro.monthly"]
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await fetchProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func fetchProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIds)
            self.products = storeProducts
            if let first = storeProducts.first {
                self.proPrice = "\(first.displayPrice) / month"
            }
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchasePro() {
        Task {
            guard let product = products.first else { return }
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    let transaction = try checkVerified(verification)
                    await transaction.finish()
                    self.isPro = true
                case .userCancelled, .pending:
                    break
                @unknown default:
                    break
                }
            } catch {
                print("Failed to purchase: \(error)")
            }
        }
    }
    
    func restorePurchases() {
        Task {
            try? await AppStore.sync()
        }
    }
    
    private func updateCustomerProductStatus() async {
        var isSubscribed = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == "com.subscriptiontracker.pro.monthly" {
                    isSubscribed = true
                }
            }
        }
        self.isPro = isSubscribed
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    await self.updateCustomerProductStatus()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
