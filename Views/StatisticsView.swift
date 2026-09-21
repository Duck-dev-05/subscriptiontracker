import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var manager: SubscriptionManager

    var totalCost: Double { manager.totalMonthlyCost }

    // Aggregate cost per category
    var categoryBreakdown: [(category: SubscriptionCategory, amount: Double, percentage: Double)] {
        var totals: [SubscriptionCategory: Double] = [:]
        for sub in manager.activeSubscriptions {
            totals[sub.category, default: 0] += sub.monthlyCost
        }
        
        return totals.map { cat, amt in
            let pct = totalCost > 0 ? (amt / totalCost) : 0
            return (category: cat, amount: amt, percentage: pct)
        }.sorted { $0.amount > $1.amount }
    }

    var body: some View {
        NavigationView {
            List {
                if manager.activeSubscriptions.isEmpty {
                    Section {
                        Text("No data available.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    }
                } else {
                    Section(header: Text("Total Monthly Spending")) {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Text("\(manager.currencySymbol)\(String(format: "%.2f", totalCost))")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Across \(manager.activeSubscriptions.count) subscriptions")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 16)
                    }

                    Section(header: Text("Category Breakdown")) {
                        ForEach(categoryBreakdown, id: \.category) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(item.category.emoji)
                                    Text(item.category.rawValue)
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    Text("\(manager.currencySymbol)\(String(format: "%.2f", item.amount))")
                                        .font(.subheadline)
                                        .bold()
                                }
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color(uiColor: .systemGray5))
                                            .frame(height: 8)
                                        
                                        Capsule()
                                            .fill(item.category.accentColor)
                                            .frame(width: max(0, geo.size.width * CGFloat(item.percentage)), height: 8)
                                    }
                                }
                                .frame(height: 8)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Analytics")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
