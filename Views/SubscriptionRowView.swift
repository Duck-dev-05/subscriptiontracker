import SwiftUI

struct SubscriptionRowView: View {
    @EnvironmentObject var manager: SubscriptionManager
    let subscription: Subscription

    var accentColor: Color {
        Color(hex: subscription.colorHex) ?? .accentIndigo
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon Avatar
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .stroke(accentColor.opacity(0.4), lineWidth: 1.5)
                    )
                Text(subscription.icon)
                    .font(.system(size: 24))
            }

            // Name + category
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)

                HStack(spacing: 6) {
                    Text(subscription.category.emoji)
                        .font(.system(size: 11))
                    Text(subscription.category.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(subscription.category.accentColor)

                    Text("•")
                        .foregroundColor(.textMuted)
                        .font(.system(size: 10))

                    Text(dateLabel)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer()

            // Price
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(manager.currencySymbol)\(String(format: "%.2f", subscription.price))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)

                Text(subscription.billingCycle.abbreviation)
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(16)
        .glassCard()
    }

    private var dateLabel: String {
        let d = subscription.daysUntilNextBilling
        if d == 0 { return "Today" }
        if d == 1 { return "Tomorrow" }
        if d < 0  { return "Overdue" }
        return subscription.nextBillingDate.formatted(.dateTime.month(.abbreviated).day())
    }
}
