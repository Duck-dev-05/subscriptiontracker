import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var manager: SubscriptionManager

    private var sortedByPrice: [Subscription] {
        manager.subscriptions.sorted { $0.monthlyCost > $1.monthlyCost }
    }

    private var categoryTotals: [(SubscriptionCategory, Double)] {
        let grouped = Dictionary(grouping: manager.subscriptions, by: { $0.category })
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.monthlyCost }) }
                      .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if manager.subscriptions.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {

                            // Summary Cards
                            summaryCards
                                .padding(.horizontal, 20)

                            // Ring Chart
                            if categoryTotals.count > 1 {
                                ringChart
                                    .padding(.horizontal, 20)
                            }

                            // By Category
                            categoryBreakdown
                                .padding(.horizontal, 20)

                            // Top subscriptions
                            topSubscriptions
                                .padding(.horizontal, 20)

                            Spacer(minLength: 100)
                        }
                        .padding(.top, 16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Analytics")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        HStack(spacing: 14) {
            summaryCard(
                label: "Monthly",
                value: "\(manager.currencySymbol)\(String(format: "%.2f", manager.totalMonthlyCost))",
                icon: "calendar",
                gradient: LinearGradient.heroGradient
            )
            summaryCard(
                label: "Yearly",
                value: "\(manager.currencySymbol)\(String(format: "%.2f", manager.totalYearlyCost))",
                icon: "chart.bar.xaxis",
                gradient: LinearGradient.tealGradient
            )
        }
    }

    private func summaryCard(label: String, value: String, icon: String, gradient: LinearGradient) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(gradient)
        )
    }

    // MARK: - Ring Chart

    private var ringChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Spending by Category")

            ZStack {
                Color.cardBackground.cornerRadius(20)

                HStack(spacing: 24) {
                    RingChartView(data: categoryTotals, total: manager.totalMonthlyCost)
                        .frame(width: 140, height: 140)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(categoryTotals.prefix(5), id: \.0) { item in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(item.0.accentColor)
                                    .frame(width: 10, height: 10)
                                Text(item.0.rawValue)
                                    .font(.system(size: 13))
                                    .foregroundColor(.textSecondary)
                                Spacer()
                                Text("\(Int(item.1 / manager.totalMonthlyCost * 100))%")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
    }

    // MARK: - Category Breakdown

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Category Breakdown")

            VStack(spacing: 10) {
                ForEach(categoryTotals, id: \.0) { item in
                    categoryBar(item)
                }
            }
            .padding(16)
            .glassCard()
        }
    }

    private func categoryBar(_ item: (SubscriptionCategory, Double)) -> some View {
        let fraction = manager.totalMonthlyCost > 0 ? item.1 / manager.totalMonthlyCost : 0
        return VStack(spacing: 6) {
            HStack {
                Text(item.0.emoji + " " + item.0.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
                Spacer()
                Text("\(manager.currencySymbol)\(String(format: "%.2f", item.1))/mo")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.surfaceColor).frame(height: 6)
                    Capsule()
                        .fill(item.0.accentColor)
                        .frame(width: geo.size.width * CGFloat(fraction), height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Top Subscriptions

    private var topSubscriptions: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Most Expensive")

            VStack(spacing: 0) {
                ForEach(Array(sortedByPrice.prefix(5).enumerated()), id: \.element.id) { idx, sub in
                    HStack(spacing: 14) {
                        Text("#\(idx+1)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.textMuted)
                            .frame(width: 28)

                        Text(sub.icon)
                            .font(.system(size: 22))

                        Text(sub.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.textPrimary)

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("\(manager.currencySymbol)\(String(format: "%.2f", sub.monthlyCost))")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            Text("/mo")
                                .font(.system(size: 11))
                                .foregroundColor(.textMuted)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if idx < min(sortedByPrice.count, 5) - 1 {
                        Divider().background(Color.textMuted.opacity(0.25)).padding(.horizontal, 16)
                    }
                }
            }
            .glassCard()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("📊")
                .font(.system(size: 56))
            Text("No data yet")
                .font(.headline)
                .foregroundColor(.textPrimary)
            Text("Add subscriptions to see your analytics here.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.textPrimary)
    }
}

// MARK: - Ring Chart Drawing

struct RingChartView: View {
    let data: [(SubscriptionCategory, Double)]
    let total: Double

    var body: some View {
        ZStack {
            ForEach(Array(slices().enumerated()), id: \.offset) { idx, slice in
                Circle()
                    .trim(from: slice.start, to: slice.end)
                    .stroke(
                        data[idx].0.accentColor,
                        style: StrokeStyle(lineWidth: 22, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }

            // Centre text
            VStack(spacing: 2) {
                Text("\(data.count)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textPrimary)
                Text("cats")
                    .font(.system(size: 11))
                    .foregroundColor(.textSecondary)
            }
        }
    }

    private struct Slice { var start: CGFloat; var end: CGFloat }

    private func slices() -> [Slice] {
        guard total > 0 else { return [] }
        var result: [Slice] = []
        var cumulative: CGFloat = 0
        let gap: CGFloat = 0.01
        for item in data {
            let fraction = CGFloat(item.1 / total) - gap
            result.append(Slice(start: cumulative + gap / 2, end: cumulative + fraction + gap / 2))
            cumulative += fraction + gap
        }
        return result
    }
}
