import SwiftUI

struct SubscriptionDetailView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    let subscription: Subscription

    @State private var showingEdit  = false
    @State private var showingDelete = false

    private var accent: Color {
        Color(hex: subscription.colorHex) ?? .accentIndigo
    }

    // Generate next 5 billing dates
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
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Hero Banner
                    heroBanner

                    // Details Card
                    detailsCard

                    // Upcoming Payments
                    upcomingCard

                    // Notes
                    if !subscription.notes.isEmpty {
                        notesCard
                    }

                    // Action Buttons
                    actionButtons
                        .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle(subscription.name)
        .navigationBarTitleDisplayMode(.inline)
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
            Text("Are you sure you want to delete \"\(subscription.name)\"? This cannot be undone.")
        }
    }

    // MARK: - Hero Banner

    private var heroBanner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accent, accent.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(maxWidth: .infinity)

            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 150)
                .offset(x: 90, y: -40)

            VStack(spacing: 12) {
                Text(subscription.icon)
                    .font(.system(size: 56))

                Text(subscription.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    Text(subscription.category.emoji)
                    Text(subscription.category.rawValue)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.white.opacity(0.15)))
            }
            .padding(.vertical, 32)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(label: "Price",
                      value: "\(manager.currencySymbol)\(String(format: "%.2f", subscription.price)) \(subscription.billingCycle.abbreviation)")
            Divider().background(Color.textMuted.opacity(0.3)).padding(.horizontal, 16)
            detailRow(label: "Monthly Cost",
                      value: "\(manager.currencySymbol)\(String(format: "%.2f", subscription.monthlyCost))")
            Divider().background(Color.textMuted.opacity(0.3)).padding(.horizontal, 16)
            detailRow(label: "Billing Cycle",
                      value: subscription.billingCycle.rawValue)
            Divider().background(Color.textMuted.opacity(0.3)).padding(.horizontal, 16)
            detailRow(label: "Next Billing",
                      value: subscription.nextBillingDate.formatted(date: .long, time: .omitted),
                      valueColor: subscription.isDueSoon ? .accentOrange : .textPrimary)
        }
        .glassCard()
        .padding(.horizontal, 20)
    }

    private func detailRow(label: String, value: String, valueColor: Color = .textPrimary) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(valueColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - Upcoming Payments

    private var upcomingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("UPCOMING PAYMENTS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textMuted)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(Array(upcomingDates.enumerated()), id: \.offset) { idx, date in
                    HStack {
                        ZStack {
                            Circle()
                                .fill(idx == 0 ? accent : Color.surfaceColor)
                                .frame(width: 32, height: 32)
                            Text(idx == 0 ? "→" : "\(idx+1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(idx == 0 ? .white : .textSecondary)
                        }

                        Text(date.formatted(date: .long, time: .omitted))
                            .font(.system(size: 14, weight: idx == 0 ? .semibold : .regular))
                            .foregroundColor(idx == 0 ? .textPrimary : .textSecondary)

                        Spacer()

                        Text("\(manager.currencySymbol)\(String(format: "%.2f", subscription.price))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(idx == 0 ? accent : .textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if idx < upcomingDates.count - 1 {
                        Divider()
                            .background(Color.textMuted.opacity(0.25))
                            .padding(.horizontal, 16)
                    }
                }
            }
            .glassCard()
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Notes Card

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NOTES")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textMuted)
                .padding(.horizontal, 20)

            Text(subscription.notes)
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
                .padding(20)
                .glassCard()
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 14) {
            Button(action: { showingEdit = true }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient.heroGradient)
                )
            }

            Button(action: { showingDelete = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.accentRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.accentRed.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.accentRed.opacity(0.4), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Date Helper

    private func nextDate(after date: Date) -> Date {
        var components = DateComponents()
        switch subscription.billingCycle {
        case .weekly:  components.day = 7
        case .monthly: components.month = 1
        case .yearly:  components.year = 1
        }
        return Calendar.current.date(byAdding: components, to: date) ?? date
    }
}
