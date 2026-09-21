import Foundation

struct PaymentHistory: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var amount: Double
}
