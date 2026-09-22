import SwiftUI

struct AccountsView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                Group {
                    if manager.uniqueAccounts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "folder")
                                .font(.system(size: 44))
                                .foregroundColor(AppTheme.textTertiary)
                            Text("No Accounts Yet")
                                .font(.headline)
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Assign subscriptions to accounts to group them here")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textTertiary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 10) {
                                ForEach(manager.uniqueAccounts, id: \.self) { account in
                                    NavigationLink(destination: AccountDetailView(accountName: account)) {
                                        accountRow(for: account)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                Color.clear.frame(height: 40)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }
                    }
                }
            }
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppTheme.accentPurple)
                }
            }
        }
    }

    private func accountRow(for account: String) -> some View {
        let subs      = manager.subscriptions(forAccount: account)
        let totalCost = subs.reduce(0) { $0 + $1.monthlyCost }

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentPurple.opacity(0.14))
                    .frame(width: 48, height: 48)
                Text(account == "Personal" ? "👤" : "💳")
                    .font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(account)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                Text("\(subs.count) subscription\(subs.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(manager.currencySymbol)\(String(format: "%.2f", totalCost))")
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.textPrimary)
                Text("/mo")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                .fill(AppTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        )
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
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Total card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Monthly")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                            Text("\(manager.currencySymbol)\(String(format: "%.2f", totalCost))")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        Spacer()
                        PillTag(text: "\(subscriptions.count) subs", color: AppTheme.accentPurple)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.radiusLg, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.accentPurple.opacity(0.18), AppTheme.accentIndigo.opacity(0.06)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.radiusLg, style: .continuous)
                                    .stroke(AppTheme.accentPurple.opacity(0.20), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)

                    if subscriptions.isEmpty {
                        Text("No subscriptions found.")
                            .foregroundColor(AppTheme.textSecondary)
                            .padding()
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(subscriptions) { sub in
                                NavigationLink(destination: SubscriptionDetailView(initialSubscription: sub)) {
                                    SubscriptionRowView(subscription: sub)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    Color.clear.frame(height: 110)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle(accountName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
