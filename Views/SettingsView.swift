import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @State private var showingClearAlert = false
    @AppStorage("appThemeOverride") private var appThemeOverride = "dark"

    private let currencies = [
        ("USD", "$"), ("EUR", "€"), ("GBP", "£"),
        ("JPY", "¥"), ("THB", "฿"), ("AUD", "A$"),
        ("CAD", "C$"), ("SGD", "S$")
    ]

    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // App Header
                        appHeader

                        // Currency Section
                        settingsSection(title: "Currency") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(currencies, id: \.0) { code, symbol in
                                        Button(action: { manager.currencySymbol = symbol }) {
                                            VStack(spacing: 4) {
                                                Text(symbol)
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(
                                                        manager.currencySymbol == symbol ? .white : .textSecondary
                                                    )
                                                Text(code)
                                                    .font(.system(size: 11, weight: .medium))
                                                    .foregroundColor(
                                                        manager.currencySymbol == symbol
                                                            ? Color.accentIndigo.opacity(0.9) : .textMuted
                                                    )
                                            }
                                            .frame(width: 60, height: 60)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(manager.currencySymbol == symbol
                                                          ? LinearGradient.heroGradient
                                                          : LinearGradient(colors: [Color.surfaceColor],
                                                                           startPoint: .top, endPoint: .bottom))
                                            )
                                            .shadow(color: manager.currencySymbol == symbol
                                                    ? Color.accentIndigo.opacity(0.4) : .clear, radius: 8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                        }

                        // Summary
                        settingsSection(title: "Overview") {
                            settingsRow(icon: "creditcard.fill",
                                        iconColor: .accentIndigo,
                                        label: "Active Subscriptions",
                                        value: "\(manager.subscriptions.count)")
                            divider
                            settingsRow(icon: "calendar",
                                        iconColor: .accentTeal,
                                        label: "Monthly Total",
                                        value: "\(manager.currencySymbol)\(String(format: "%.2f", manager.totalMonthlyCost))")
                            divider
                            settingsRow(icon: "chart.bar.fill",
                                        iconColor: .accentViolet,
                                        label: "Yearly Total",
                                        value: "\(manager.currencySymbol)\(String(format: "%.2f", manager.totalYearlyCost))")
                        }

                        // Danger Zone
                        settingsSection(title: "Data") {
                            Button(action: { showingClearAlert = true }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.accentRed.opacity(0.2))
                                            .frame(width: 34, height: 34)
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.accentRed)
                                    }
                                    Text("Clear All Subscriptions")
                                        .font(.system(size: 16))
                                        .foregroundColor(.accentRed)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        // About
                        settingsSection(title: "About") {
                            settingsRow(icon: "app.fill",
                                        iconColor: .accentGold,
                                        label: "Version",
                                        value: "\(appVersion) (\(buildNumber))")
                            divider
                            settingsRow(icon: "iphone",
                                        iconColor: .accentTeal,
                                        label: "Minimum iOS",
                                        value: "iOS 15+")
                            divider
                            settingsRow(icon: "heart.fill",
                                        iconColor: .accentPink,
                                        label: "Made with",
                                        value: "SwiftUI ❤️")
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Clear All Data", isPresented: $showingClearAlert) {
            Button("Clear All", role: .destructive) { manager.clearAll() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all \(manager.subscriptions.count) subscription(s). This action cannot be undone.")
        }
    }

    // MARK: - App Header

    private var appHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient.heroGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.accentIndigo.opacity(0.5), radius: 20)
                Text("💳")
                    .font(.system(size: 36))
            }
            Text("Subscription Tracker")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)
            Text("Keep track of all your recurring costs")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .glassCard()
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers

    private var divider: some View {
        Divider().background(Color.textMuted.opacity(0.25)).padding(.horizontal, 16)
    }

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textMuted)
                .padding(.horizontal, 20)

            VStack(spacing: 0) { content() }
                .glassCard()
                .padding(.horizontal, 20)
        }
    }

    private func settingsRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.18))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(iconColor)
            }
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.textPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
