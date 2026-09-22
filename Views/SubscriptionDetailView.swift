import SwiftUI

struct SubscriptionDetailView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    let initialSubscription: Subscription

    var subscription: Subscription {
        manager.subscriptions.first(where: { $0.id == initialSubscription.id }) ?? initialSubscription
    }

    @State private var showingEdit   = false
    @State private var showingDelete = false

    private var accent: Color {
        Color(hex: subscription.colorHex) ?? AppTheme.accentPurple
    }

    private var upcomingDates: [Date] {
        var dates: [Date] = []
        var date = subscription.nextBillingDate
        for _ in 0..<5 {
            dates.append(date)
            date = nextDate(after: date)
        }
        return dates
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    heroHeader
                    detailsCard.padding(.horizontal, 20)
                    upcomingCard.padding(.horizontal, 20)

                    if !subscription.notes.isEmpty {
                        notesCard.padding(.horizontal, 20)
                    }

                    if !subscription.paymentHistory.isEmpty {
                        paymentHistoryCard.padding(.horizontal, 20)
                    }

                    actionsSection.padding(.horizontal, 20)
                    Color.clear.frame(height: 110)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(subscription.name)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
        .customToolbarBackground()
        .sheet(isPresented: $showingEdit) {
            AddEditSubscriptionView(mode: .edit(subscription))
        }
        .alert("Delete Subscription", isPresented: $showingDelete) {
            Button("Delete", role: .destructive) {
                manager.delete(subscription)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(subscription.name)\"?")
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [accent.opacity(0.75), accent.opacity(0.25), AppTheme.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 230)
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 200, height: 200)
                    .offset(x: 60, y: -70)
            }

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(accent.opacity(0.45), lineWidth: 3)
                        .frame(width: 90, height: 90)
                    Circle()
                        .fill(accent.opacity(0.14))
                        .frame(width: 86, height: 86)
                    Text(subscription.icon)
                        .font(.system(size: 40))
                }

                Text(subscription.name)
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)

                PillTag(
                    text: "\(subscription.category.emoji) \(subscription.category.rawValue)",
                    color: accent
                )
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(icon: "tag.fill",         label: "Price",
                      value: "\(manager.currencySymbol)\(String(format: "%.2f", subscription.price)) \(subscription.billingCycle.abbreviation)")
            rowDivider
            detailRow(icon: "equal.circle.fill", label: "Monthly Equivalent",
                      value: "\(manager.currencySymbol)\(String(format: "%.2f", subscription.monthlyCost))")
            rowDivider
            detailRow(icon: "arrow.clockwise",   label: "Billing Cycle",
                      value: subscription.billingCycle.rawValue)

            if let account = subscription.accountName, !account.isEmpty {
                rowDivider
                detailRow(icon: "folder.fill", label: "Account", value: account)
            }

            rowDivider

            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(accent)
                    .frame(width: 26)
                Text("Next Billing")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
                Text(subscription.nextBillingDate.formatted(date: .long, time: .omitted))
                    .font(.subheadline.bold())
                    .foregroundColor(subscription.isDueSoon ? AppTheme.danger : AppTheme.textPrimary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
        }
        .glassCard(cornerRadius: AppTheme.radiusMd, padding: 0)
    }

    private var rowDivider: some View {
        Divider()
            .background(AppTheme.border)
            .padding(.leading, 54)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(accent)
                .frame(width: 26)
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }

    // MARK: - Upcoming Payments

    private var upcomingCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Upcoming Payments", systemImage: "clock.fill")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)

            ForEach(Array(upcomingDates.enumerated()), id: \.offset) { idx, date in
                HStack(spacing: 14) {
                    // Track dot
                    VStack(spacing: 0) {
                        if idx > 0 {
                            Rectangle().fill(AppTheme.border).frame(width: 2, height: 8)
                        }
                        Circle()
                            .fill(idx == 0 ? accent : AppTheme.border)
                            .frame(width: 10, height: 10)
                        if idx < upcomingDates.count - 1 {
                            Rectangle().fill(AppTheme.border).frame(width: 2, height: 8)
                        }
                    }
                    .frame(width: 20)

                    Text(idx == 0 ? "Next" : "#\(idx + 1)")
                        .font(.caption.bold())
                        .foregroundColor(idx == 0 ? accent : AppTheme.textTertiary)
                        .frame(width: 32, alignment: .leading)

                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(idx == 0 ? AppTheme.textPrimary : AppTheme.textSecondary)

                    Spacer()

                    Text("\(manager.currencySymbol)\(String(format: "%.2f", subscription.price))")
                        .font(.subheadline)
                        .fontWeight(idx == 0 ? .bold : .regular)
                        .foregroundColor(idx == 0 ? AppTheme.textPrimary : AppTheme.textSecondary)
                }
            }
        }
        .glassCard(cornerRadius: AppTheme.radiusMd)
    }

    // MARK: - Notes

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Notes", systemImage: "note.text")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
            Text(subscription.notes)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .glassCard(cornerRadius: AppTheme.radiusMd)
    }

    // MARK: - Payment History

    private var paymentHistoryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Payment History", systemImage: "clock.arrow.circlepath")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)

            ForEach(subscription.paymentHistory.sorted(by: { $0.date > $1.date })) { payment in
                HStack {
                    Text(payment.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text("\(manager.currencySymbol)\(String(format: "%.2f", payment.amount))")
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.success)
                }
            }
        }
        .glassCard(cornerRadius: AppTheme.radiusMd)
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 10) {
            // Mark as Paid
            Button(action: markAsPaid) {
                Label("Mark as Paid", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                            .fill(LinearGradient(
                                colors: [AppTheme.success, Color(red: 0.15, green: 0.62, blue: 0.30)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                    )
            }

            HStack(spacing: 10) {
                // Edit
                Button { showingEdit = true } label: {
                    Label("Edit", systemImage: "pencil")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                .fill(AppTheme.accentGradient)
                        )
                }

                // Archive
                Button {
                    var updated = subscription
                    updated.isArchived = true
                    manager.update(updated)
                    dismiss()
                } label: {
                    Label("Archive", systemImage: "archivebox")
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.warning)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                .fill(AppTheme.warning.opacity(0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                        .stroke(AppTheme.warning.opacity(0.28), lineWidth: 1)
                                )
                        )
                }
            }

            // Delete
            Button { showingDelete = true } label: {
                Label("Delete Subscription", systemImage: "trash")
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.danger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                            .fill(AppTheme.danger.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                    .stroke(AppTheme.danger.opacity(0.25), lineWidth: 1)
                            )
                    )
            }
        }
    }

    // MARK: - Helpers

    private func nextDate(after date: Date) -> Date {
        var components = DateComponents()
        switch subscription.billingCycle {
        case .weekly:  components.day = 7
        case .monthly: components.month = 1
        case .yearly:  components.year = 1
        }
        return Calendar.current.date(byAdding: components, to: date) ?? date
    }

    private func markAsPaid() {
        var updated = subscription
        let payment = PaymentHistory(date: Date(), amount: subscription.price)
        updated.paymentHistory.append(payment)
        updated.nextBillingDate = nextDate(after: subscription.nextBillingDate)
        manager.update(updated)
    }
}
