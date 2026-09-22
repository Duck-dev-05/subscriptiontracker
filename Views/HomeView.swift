import SwiftUI

// MARK: - Sort Option

enum SortOption: String, CaseIterable {
    case nextBilling   = "Next Billing Date"
    case costHighToLow = "Cost (High to Low)"
    case name          = "Name (A-Z)"
}

// MARK: - HomeView

struct HomeView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @State private var showingAdd      = false
    @State private var showingAccounts = false
    @State private var sortOption: SortOption = .nextBilling
    @State private var appeared = false

    var sortedSubscriptions: [Subscription] {
        manager.activeSubscriptions.sorted { lhs, rhs in
            switch sortOption {
            case .nextBilling:   return lhs.nextBillingDate < rhs.nextBillingDate
            case .costHighToLow: return lhs.monthlyCost > rhs.monthlyCost
            case .name:          return lhs.name.lowercased() < rhs.name.lowercased()
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                        heroCard.padding(.horizontal, 20)

                        if !manager.dueSoon.isEmpty {
                            dueSoonSection
                        }

                        subscriptionsSection

                        Color.clear.frame(height: 110)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAdd)      { AddEditSubscriptionView(mode: .add) }
            .sheet(isPresented: $showingAccounts) { AccountsView() }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) { appeared = true }
        }
    }

    // MARK: Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good \(timeOfDay)")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                Text("Subscriptions")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
            }

            Spacer()

            HStack(spacing: 10) {
                iconButton(systemImage: "folder.fill") { showingAccounts = true }

                Menu {
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(width: 38, height: 38)
                        .background(AppTheme.surface)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                }

                Button { showingAdd = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(AppTheme.accentGradient)
                        .clipShape(Circle())
                        .shadow(color: AppTheme.accentPurple.opacity(0.45), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func iconButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 38, height: 38)
                .background(AppTheme.surface)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
        }
    }

    // MARK: Hero Card

    private var heroCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.radiusLg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.48, green: 0.23, blue: 0.93),
                            Color(red: 0.31, green: 0.28, blue: 0.90),
                            Color(red: 0.17, green: 0.14, blue: 0.48)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Decorative orbs
            Circle().fill(Color.white.opacity(0.06)).frame(width: 180).offset(x: 90, y: -36)
            Circle().fill(Color.white.opacity(0.04)).frame(width: 110).offset(x: 110, y: 30)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Monthly Spend")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.72))
                    Spacer()
                    PillTag(text: "\(manager.activeSubscriptions.count) active", color: .white)
                }

                Text("\(manager.currencySymbol)\(String(format: "%.2f", manager.totalMonthlyCost))")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Divider().background(Color.white.opacity(0.2))

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Yearly estimate")
                            .font(.caption).foregroundColor(.white.opacity(0.6))
                        Text("\(manager.currencySymbol)\(String(format: "%.2f", manager.totalYearlyCost))")
                            .font(.subheadline.bold()).foregroundColor(.white)
                    }
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1, height: 34)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Due soon")
                            .font(.caption).foregroundColor(.white.opacity(0.6))
                        Text("\(manager.dueSoon.count)")
                            .font(.subheadline.bold())
                            .foregroundColor(manager.dueSoon.isEmpty ? .white : Color(hex: "FFCC00")!)
                    }
                }
            }
            .padding(20)
        }
        .shadow(color: AppTheme.accentPurple.opacity(0.30), radius: 20, x: 0, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 18)
    }

    // MARK: Due Soon Strip

    private var dueSoonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Due Soon", icon: "calendar.badge.exclamationmark")
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(manager.dueSoon) { sub in
                        DueSoonCard(subscription: sub)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: Subscriptions List

    private var subscriptionsSection: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "All Subscriptions", icon: "list.bullet")
                .padding(.horizontal, 20)

            if manager.activeSubscriptions.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(sortedSubscriptions) { sub in
                        NavigationLink(destination: SubscriptionDetailView(initialSubscription: sub)) {
                            SubscriptionRowView(subscription: sub)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 44))
                .foregroundColor(AppTheme.textTertiary)
            Text("No Subscriptions Yet")
                .font(.headline)
                .foregroundColor(AppTheme.textSecondary)
            Text("Tap + to add your first subscription")
                .font(.subheadline)
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
            Button { showingAdd = true } label: {
                Text("Add Subscription")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.accentGradient)
                    .clipShape(Capsule())
            }
        }
        .padding(36)
        .frame(maxWidth: .infinity)
        .glassCard(cornerRadius: AppTheme.radiusLg, padding: 0)
        .padding(.horizontal, 20)
    }

    private var timeOfDay: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "morning" }
        if h < 17 { return "afternoon" }
        return "evening"
    }

    private func deleteSubscription(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { sortedSubscriptions[$0] }
        for item in itemsToDelete { manager.delete(item) }
    }
}

// MARK: - Due Soon Card

struct DueSoonCard: View {
    let subscription: Subscription

    private var accentColor: Color {
        Color(hex: subscription.colorHex) ?? AppTheme.accentPurple
    }
    private var urgencyColor: Color {
        subscription.daysUntilNextBilling <= 2 ? AppTheme.danger : AppTheme.warning
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle().fill(accentColor.opacity(0.18)).frame(width: 40, height: 40)
                Text(subscription.icon).font(.system(size: 20))
            }

            Text(subscription.name)
                .font(.subheadline.bold())
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)

            HStack(spacing: 5) {
                Circle().fill(urgencyColor).frame(width: 6, height: 6)
                Text(daysLabel)
                    .font(.caption)
                    .foregroundColor(urgencyColor)
            }
        }
        .padding(14)
        .frame(width: 128, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                .fill(AppTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                        .stroke(accentColor.opacity(0.22), lineWidth: 1)
                )
        )
        .shadow(color: accentColor.opacity(0.10), radius: 8, x: 0, y: 4)
    }

    private var daysLabel: String {
        let d = subscription.daysUntilNextBilling
        if d == 0 { return "Due today" }
        if d == 1 { return "Tomorrow" }
        return "In \(d) days"
    }
}
