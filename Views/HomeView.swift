import SwiftUI

struct HomeView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @State private var showingAdd = false
    @State private var showingEdit: Subscription? = nil
    @State private var animateHero = false

    var sortedSubscriptions: [Subscription] {
        manager.subscriptions.sorted { $0.nextBillingDate < $1.nextBillingDate }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // MARK: Hero Card
                        heroCard
                            .padding(.horizontal, 20)

                        // MARK: Due Soon Strip
                        if !manager.dueSoon.isEmpty {
                            dueSoonSection
                        }

                        // MARK: All Subscriptions
                        allSubscriptionsSection
                            .padding(.bottom, 120)
                    }
                    .padding(.top, 16)
                }

                // MARK: Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAdd = true }) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient.heroGradient)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color.accentIndigo.opacity(0.6), radius: 16)
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 110)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Subscriptions")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingAdd) {
            AddEditSubscriptionView(mode: .add)
        }
        .sheet(item: $showingEdit) { sub in
            AddEditSubscriptionView(mode: .edit(sub))
        }
        .onAppear { withAnimation(.easeOut(duration: 0.6)) { animateHero = true } }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient.heroGradient)

            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 180)
                .offset(x: 80, y: -50)

            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 120)
                .offset(x: -90, y: 60)

            VStack(alignment: .leading, spacing: 8) {
                Text("Total Monthly")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.75))

                Text("\(manager.currencySymbol)\(String(format: "%.2f", manager.totalMonthlyCost))")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(animateHero ? 1.0 : 0.8)

                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 4)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Yearly estimate")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.65))
                        Text("\(manager.currencySymbol)\(String(format: "%.2f", manager.totalYearlyCost))")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Active")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.65))
                        Text("\(manager.subscriptions.count)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Due Soon

    private var dueSoonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Due Soon")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.textPrimary)
                Spacer()
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(.accentOrange)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(manager.dueSoon) { sub in
                        DueSoonCard(subscription: sub)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - All Subscriptions

    private var allSubscriptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Subscriptions")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("\(manager.subscriptions.count) total")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 20)

            if manager.subscriptions.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(sortedSubscriptions) { sub in
                        NavigationLink(destination: SubscriptionDetailView(subscription: sub)) {
                            SubscriptionRowView(subscription: sub)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 20)
                        .contextMenu {
                            Button {
                                showingEdit = sub
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                withAnimation { manager.delete(sub) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🗂️")
                .font(.system(size: 56))
            Text("No subscriptions yet")
                .font(.headline)
                .foregroundColor(.textPrimary)
            Text("Tap the + button to add your first subscription.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .glassCard()
        .padding(.horizontal, 20)
    }
}

// MARK: - Due Soon Card

struct DueSoonCard: View {
    let subscription: Subscription

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(subscription.icon)
                .font(.system(size: 28))

            Text(subscription.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)
                .lineLimit(1)

            Text(daysLabel)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(subscription.daysUntilNextBilling <= 2 ? .accentRed : .accentOrange)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill((subscription.daysUntilNextBilling <= 2 ? Color.accentRed : Color.accentOrange).opacity(0.18))
                )
        }
        .padding(16)
        .frame(width: 130)
        .glassCard()
    }

    private var daysLabel: String {
        let d = subscription.daysUntilNextBilling
        if d == 0 { return "Due today" }
        if d == 1 { return "Due tomorrow" }
        return "Due in \(d) days"
    }
}
