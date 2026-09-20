import SwiftUI

struct StatisticsView: View {
    let subscriptions: [Subscription]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Overview")) {
                    HStack {
                        Text("Total Active Subscriptions")
                        Spacer()
                        Text("\(subscriptions.count)")
                            .bold()
                    }
                    
                    HStack {
                        Text("Estimated Monthly Cost")
                        Spacer()
                        Text(String(format: "$%.2f", calculateTotalMonthly()))
                            .bold()
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("Estimated Yearly Cost")
                        Spacer()
                        Text(String(format: "$%.2f", calculateTotalYearly()))
                            .bold()
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Breakdown by Cycle")) {
                    HStack {
                        Text("Weekly Subscriptions")
                        Spacer()
                        Text("\(subscriptions.filter { $0.billingCycle == .weekly }.count)")
                    }
                    
                    HStack {
                        Text("Monthly Subscriptions")
                        Spacer()
                        Text("\(subscriptions.filter { $0.billingCycle == .monthly }.count)")
                    }
                    
                    HStack {
                        Text("Yearly Subscriptions")
                        Spacer()
                        Text("\(subscriptions.filter { $0.billingCycle == .yearly }.count)")
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func calculateTotalMonthly() -> Double {
        subscriptions.reduce(0) { total, sub in
            switch sub.billingCycle {
            case .weekly: return total + (sub.price * 52 / 12)
            case .monthly: return total + sub.price
            case .yearly: return total + (sub.price / 12)
            }
        }
    }
    
    private func calculateTotalYearly() -> Double {
        subscriptions.reduce(0) { total, sub in
            switch sub.billingCycle {
            case .weekly: return total + (sub.price * 52)
            case .monthly: return total + (sub.price * 12)
            case .yearly: return total + sub.price
            }
        }
    }
}
