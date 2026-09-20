import SwiftUI

struct AccountsView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                if manager.uniqueAccounts.isEmpty {
                    Section {
                        Text("No accounts yet.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    }
                } else {
                    Section {
                        ForEach(manager.uniqueAccounts, id: \.self) { account in
                            NavigationLink(destination: AccountDetailView(accountName: account)) {
                                accountRow(for: account)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func accountRow(for account: String) -> some View {
        let subs = manager.subscriptions(forAccount: account)
        let totalCost = subs.reduce(0) { $0 + $1.monthlyCost }

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(uiColor: .systemGray5))
                    .frame(width: 40, height: 40)
                Text(account == "Personal" ? "👤" : "💳")
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(account)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("\(subs.count) subscription\(subs.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(manager.currencySymbol)\(String(format: "%.2f", totalCost))")
                    .font(.subheadline)
                    .bold()

                Text("/mo")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Account Detail View

struct AccountDetailView: View {
    @EnvironmentObject var manager: SubscriptionManager
    let accountName: String

    var subscriptions: [Subscription] {
        manager.subscriptions(forAccount: accountName)
    }

    var totalCost: Double {
        subscriptions.reduce(0) { $0 + $1.monthlyCost }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Total Monthly")
                    Spacer()
                    Text("\(manager.currencySymbol)\(String(format: "%.2f", totalCost))")
                        .bold()
                }
            }
            
            Section(header: Text("Subscriptions")) {
                if subscriptions.isEmpty {
                    Text("No subscriptions found.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(subscriptions) { sub in
                        NavigationLink(destination: SubscriptionDetailView(subscription: sub)) {
                            SubscriptionRowView(subscription: sub)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(accountName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
