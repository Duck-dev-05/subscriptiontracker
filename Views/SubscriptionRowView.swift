import SwiftUI

struct SubscriptionRowView: View {
    @EnvironmentObject var manager: SubscriptionManager
    let subscription: Subscription

    var accentColor: Color {
        Color(hex: subscription.colorHex) ?? .blue
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon Avatar
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                Text(subscription.icon)
                    .font(.system(size: 24))
            }

            // Name + category
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 6) {
                    Text(subscription.category.emoji)
                        .font(.caption)
                    Text(subscription.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    Text(dateLabel)
                        .font(.caption)
                        .foregroundColor(subscription.isDueSoon ? .red : .secondary)
                }
            }

            Spacer()

            // Price
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(manager.currencySymbol)\(String(format: "%.2f", subscription.price))")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subscription.billingCycle.abbreviation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var dateLabel: String {
        let d = subscription.daysUntilNextBilling
        if d == 0 { return "Today" }
        if d == 1 { return "Tomorrow" }
        if d < 0  { return "Overdue" }
        return subscription.nextBillingDate.formatted(.dateTime.month(.abbreviated).day())
    }
}
