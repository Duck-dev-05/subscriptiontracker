import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingWipeAlert = false
    @ObservedObject var currencyManager = CurrencyManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Inline header
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Preferences")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("Settings")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Currency
                        settingsCard(title: "Base Currency", icon: "banknote.fill") {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text("Display Currency")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                    Picker("Base Currency", selection: $currencyManager.baseCurrency) {
                                        ForEach(CurrencyManager.shared.availableCurrencies, id: \.self) { code in
                                            Text("\(CurrencyManager.symbol(for: code)) \(code)").tag(code)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(AppTheme.accentPurple)
                                }

                                Text("The base currency is used to normalize your total spending analytics.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textTertiary)
                            }
                        }

                        // Notifications
                        settingsCard(title: "Notifications", icon: "bell.fill") {
                            NavigationLink(destination: NotificationSettingsView()) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(AppTheme.accentPurple)
                                    Text("Reminder Settings")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.bold())
                                        .foregroundColor(AppTheme.textTertiary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        // Personalize
                        settingsCard(title: "Personalize", icon: "paintpalette.fill") {
                            NavigationLink(destination: CategoryManagementView()) {
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .foregroundColor(AppTheme.accentPurple)
                                    Text("Manage Categories")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.bold())
                                        .foregroundColor(AppTheme.textTertiary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        // Data
                        settingsCard(title: "Data", icon: "externaldrive.fill") {
                            NavigationLink(destination: ArchiveView()) {
                                HStack {
                                    Image(systemName: "archivebox.fill")
                                        .foregroundColor(AppTheme.accentPurple)
                                    Text("View Archived Subscriptions")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.bold())
                                        .foregroundColor(AppTheme.textTertiary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        // Danger zone
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption.bold())
                                    .foregroundColor(AppTheme.danger)
                                Text("Danger Zone")
                                    .font(.caption.bold())
                                    .foregroundColor(AppTheme.danger)
                            }
                            .padding(.horizontal, 20)

                            Button(role: .destructive) { showingWipeAlert = true } label: {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Erase All Subscriptions")
                                        .font(.subheadline.bold())
                                    Spacer()
                                }
                                .foregroundColor(AppTheme.danger)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                        .fill(AppTheme.danger.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                                .stroke(AppTheme.danger.opacity(0.25), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.horizontal, 20)
                        }

                        // About
                        settingsCard(title: "About", icon: "info.circle.fill") {
                            VStack(spacing: 0) {
                                aboutRow(label: "Version", value: "1.0.0")
                                Divider().background(AppTheme.border)
                                aboutRow(label: "Developer", value: "Antigravity")
                            }
                        }

                        Color.clear.frame(height: 110)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            .alert("Erase All Data?", isPresented: $showingWipeAlert) {
                Button("Erase All", role: .destructive) {
                    withAnimation { manager.clearAll() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. All your subscriptions will be permanently deleted.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Helpers

    private func settingsCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.accentPurple)
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 20)

            content()
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                        .fill(AppTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                .stroke(AppTheme.border, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
        }
    }

    private func aboutRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.vertical, 10)
    }
}
