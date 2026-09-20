import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var manager: SubscriptionManager
    
    @State private var showingAddSubscription = false
    @State private var showingStatistics = false
    
    var sortedSubscriptions: [Subscription] {
        manager.subscriptions.sorted { $0.nextBillingDate < $1.nextBillingDate }
    }
    
    var body: some View {
        NavigationView {
            List {
                if manager.subscriptions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "creditcard.trianglebadge.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No Subscriptions")
                            .font(.title2)
                            .bold()
                        Text("Add your first subscription to start tracking your expenses.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    Section {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Monthly Cost")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(String(format: "$%.2f", calculateMonthlyCost()))
                                    .font(.title2)
                                    .bold()
                            }
                            
                            Spacer()
                            
                            Button(action: { showingStatistics = true }) {
                                Image(systemName: "chart.pie.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section(header: Text("Upcoming Bills")) {
                        ForEach(sortedSubscriptions) { subscription in
                            SubscriptionRowView(subscription: subscription)
                        }
                        .onDelete(perform: deleteSubscriptions)
                    }
                }
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSubscription = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSubscription) {
                AddSubscriptionView()
            }
            .sheet(isPresented: $showingStatistics) {
                StatisticsView(subscriptions: manager.subscriptions)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func deleteSubscriptions(offsets: IndexSet) {
        withAnimation {
            manager.delete(at: offsets)
        }
    }
    
    private func calculateMonthlyCost() -> Double {
        manager.subscriptions.reduce(0) { total, sub in
            switch sub.billingCycle {
            case .weekly: return total + (sub.price * 52 / 12)
            case .monthly: return total + sub.price
            case .yearly: return total + (sub.price / 12)
            }
        }
    }
}
