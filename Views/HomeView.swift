import SwiftUI

struct HomeView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @State private var showingAdd = false
    @State private var showingAccounts = false

    var sortedSubscriptions: [Subscription] {
        manager.subscriptions.sorted { $0.nextBillingDate < $1.nextBillingDate }
    }

    var body: some View {
        NavigationView {
            List {
                // MARK: Hero Summary
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Monthly")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(manager.currencySymbol)\(String(format: "%.2f", manager.totalMonthlyCost))")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Yearly estimate")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(manager.currencySymbol)\(String(format: "%.2f", manager.totalYearlyCost))")
                                    .font(.subheadline)
                                    .bold()
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Active")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(manager.subscriptions.count)")
                                    .font(.subheadline)
                                    .bold()
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // MARK: Due Soon Strip
                if !manager.dueSoon.isEmpty {
                    Section(header: Text("Due Soon")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(manager.dueSoon) { sub in
                                    DueSoonCard(subscription: sub)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                    }
                }
                
                // MARK: All Subscriptions
                Section(header: Text("All Subscriptions")) {
                    if manager.subscriptions.isEmpty {
                        Text("No subscriptions yet. Tap + to add.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(sortedSubscriptions) { sub in
                            NavigationLink(destination: SubscriptionDetailView(subscription: sub)) {
                                SubscriptionRowView(subscription: sub)
                            }
                        }
                        .onDelete(perform: deleteSubscription)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingAccounts = true }) {
                        Image(systemName: "folder")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditSubscriptionView(mode: .add)
            }
            .sheet(isPresented: $showingAccounts) {
                AccountsView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func deleteSubscription(at offsets: IndexSet) {
        // Because the list is sorted, we need to find the actual items to delete
        let itemsToDelete = offsets.map { sortedSubscriptions[$0] }
        for item in itemsToDelete {
            manager.delete(item)
        }
    }
}

// MARK: - Due Soon Card

struct DueSoonCard: View {
    let subscription: Subscription

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(subscription.icon)
                .font(.system(size: 24))
            
            Text(subscription.name)
                .font(.subheadline)
                .bold()
                .lineLimit(1)
            
            Text(daysLabel)
                .font(.caption)
                .foregroundColor(subscription.daysUntilNextBilling <= 2 ? .red : .orange)
        }
        .padding(12)
        .frame(width: 120, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var daysLabel: String {
        let d = subscription.daysUntilNextBilling
        if d == 0 { return "Due today" }
        if d == 1 { return "Due tomorrow" }
        return "In \(d) days"
    }
}
