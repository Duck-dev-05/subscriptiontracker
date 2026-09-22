import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @Binding var selectedTab: AppTab
    @State private var animateProgress = false

    var totalCost: Double { manager.totalMonthlyCost }

    var categoryBreakdown: [(category: SubscriptionCategory, amount: Double, percentage: Double)] {
        var totals: [SubscriptionCategory: Double] = [:]
        for sub in manager.activeSubscriptions {
            totals[sub.category, default: 0] += sub.monthlyCost
        }
        return totals.map { cat, amt in
            let pct = totalCost > 0 ? (amt / totalCost) : 0
            return (category: cat, amount: amt, percentage: pct)
        }.sorted { $0.amount > $1.amount }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Inline header
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Overview")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("Analytics")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        if manager.isAnonymous {
                            lockedState
                        } else if manager.activeSubscriptions.isEmpty {
                            emptyState
                        } else {
                            heroCard.padding(.horizontal, 20)
                            donutSection.padding(.horizontal, 20)
                            categorySection.padding(.horizontal, 20)
                            Color.clear.frame(height: 110)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeOut(duration: 0.85)) {
                    animateProgress = true
                }
            }
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Monthly Total")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                Text("\(manager.currencySymbol)\(String(format: "%.2f", totalCost))")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                Text("\(manager.activeSubscriptions.count) active subscriptions")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text("Yearly")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Text("\(manager.currencySymbol)\(String(format: "%.0f", manager.totalYearlyCost))")
                    .font(.title3.bold())
                    .foregroundColor(AppTheme.accentPurple)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusLg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.accentPurple.opacity(0.20), AppTheme.accentIndigo.opacity(0.07)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusLg, style: .continuous)
                        .stroke(AppTheme.accentPurple.opacity(0.22), lineWidth: 1)
                )
        )
    }

    // MARK: - Donut + Top Category

    private var donutSection: some View {
        HStack(spacing: 20) {
            DonutChart(breakdown: categoryBreakdown, animate: animateProgress)
                .frame(width: 130, height: 130)

            VStack(alignment: .leading, spacing: 10) {
                if let top = categoryBreakdown.first {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Top Category")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        Text("\(top.category.emoji) \(top.category.rawValue)")
                            .font(.headline.bold())
                            .foregroundColor(AppTheme.textPrimary)
                        Text("\(Int(top.percentage * 100))% of spending")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Divider().background(AppTheme.border)
                }

                VStack(alignment: .leading, spacing: 7) {
                    ForEach(categoryBreakdown.prefix(4), id: \.category) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.category.accentColor)
                                .frame(width: 8, height: 8)
                            Text(item.category.rawValue)
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text("\(Int(item.percentage * 100))%")
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                }
            }
        }
        .padding(18)
        .glassCard(cornerRadius: AppTheme.radiusLg, padding: 0)
    }

    // MARK: - Category Bars

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)

            ForEach(Array(categoryBreakdown.enumerated()), id: \.element.category) { idx, item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.category.emoji).font(.subheadline)
                        Text(item.category.rawValue)
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text("\(manager.currencySymbol)\(String(format: "%.2f", item.amount))")
                            .font(.subheadline.bold())
                            .foregroundColor(item.category.accentColor)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppTheme.surface)
                                .frame(height: 8)
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [item.category.accentColor, item.category.accentColor.opacity(0.55)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: animateProgress
                                        ? max(8, geo.size.width * CGFloat(item.percentage))
                                        : 8,
                                    height: 8
                                )
                                .animation(
                                    .easeOut(duration: 0.75).delay(Double(idx) * 0.08),
                                    value: animateProgress
                                )
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.vertical, 4)

                if idx < categoryBreakdown.count - 1 {
                    Divider().background(AppTheme.border)
                }
            }
        }
        .glassCard(cornerRadius: AppTheme.radiusLg)
    }

    // MARK: - Locked State
    
    private var lockedState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentPurple.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 34))
                    .foregroundColor(AppTheme.accentPurple)
            }
            
            VStack(spacing: 8) {
                Text("Analytics Locked")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Sign up for free to unlock powerful insights and spending breakdowns.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                selectedTab = .profile
            } label: {
                Text("Sign Up to Unlock")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                            .fill(AppTheme.accentGradient)
                    )
                    .shadow(color: AppTheme.accentPurple.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .padding(.top, 10)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .glassCard(cornerRadius: AppTheme.radiusLg, padding: 0)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 44))
                .foregroundColor(AppTheme.textTertiary)
            Text("No Data Yet")
                .font(.headline)
                .foregroundColor(AppTheme.textSecondary)
            Text("Add subscriptions to see your spending analytics")
                .font(.subheadline)
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(36)
        .frame(maxWidth: .infinity)
        .glassCard(cornerRadius: AppTheme.radiusLg, padding: 0)
        .padding(.horizontal, 20)
    }
}

// MARK: - Donut Chart

struct DonutChart: View {
    let breakdown: [(category: SubscriptionCategory, amount: Double, percentage: Double)]
    let animate: Bool

    var body: some View {
        ZStack {
            if breakdown.isEmpty {
                Circle()
                    .stroke(AppTheme.border, lineWidth: 14)
            } else {
                ForEach(Array(breakdown.enumerated()), id: \.offset) { idx, item in
                    let startDeg = breakdown.prefix(idx).reduce(-90.0) { $0 + $1.percentage * 360 }
                    let endDeg   = startDeg + item.percentage * 360

                    DonutSlice(
                        startAngle: .degrees(startDeg),
                        endAngle:   .degrees(animate ? endDeg : startDeg)
                    )
                    .fill(item.category.accentColor)
                    .animation(
                        .easeOut(duration: 0.75).delay(Double(idx) * 0.06),
                        value: animate
                    )
                }
            }

            // Hole
            Circle()
                .fill(AppTheme.background)
                .frame(width: 72, height: 72)
        }
    }
}

// MARK: - Donut Slice Shape

struct DonutSlice: Shape {
    var startAngle: Angle
    var endAngle:   Angle

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle.degrees, endAngle.degrees) }
        set {
            startAngle = .degrees(newValue.first)
            endAngle   = .degrees(newValue.second)
        }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer  = min(rect.width, rect.height) / 2
        let inner  = outer * 0.54
        p.addArc(center: center, radius: outer, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        p.addArc(center: center, radius: inner, startAngle: endAngle,   endAngle: startAngle, clockwise: true)
        p.closeSubpath()
        return p
    }
}
