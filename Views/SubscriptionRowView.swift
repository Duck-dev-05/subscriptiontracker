import SwiftUI

struct SubscriptionRowView: View {
    @EnvironmentObject var manager: SubscriptionManager
    let subscription: Subscription

    var accentColor: Color {
        Color(hex: subscription.colorHex) ?? AppTheme.accentPurple
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon with gradient ring
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 50, height: 50)

                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 46, height: 46)

                Text(subscription.icon)
                    .font(.system(size: 22))
            }

            // Name + meta
            VStack(alignment: .leading, spacing: 5) {
                Text(subscription.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: 6) {
                    Text(subscription.category.emoji)
                        .font(.caption2)
                    Text(subscription.category.rawValue)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)

                    if subscription.isDueSoon {
                        PillTag(
                            text: dateLabel,
                            color: subscription.daysUntilNextBilling <= 2
                                ? AppTheme.danger : AppTheme.warning
                        )
                    }
                }
            }

            Spacer()

            // Price
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(CurrencyManager.symbol(for: subscription.currencyCode))\(String(format: "%.2f", subscription.price))")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(subscription.billingCycle.abbreviation)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                        .stroke(AppTheme.borderStrong, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }

    private var dateLabel: String {
        let d = subscription.daysUntilNextBilling
        if d == 0 { return "Today" }
        if d == 1 { return "Tomorrow" }
        if d < 0  { return "Overdue" }
        return subscription.nextBillingDate.formatted(.dateTime.month(.abbreviated).day())
    }
}
