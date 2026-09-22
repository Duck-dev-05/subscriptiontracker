import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Avatar + name
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accentGradient)
                                    .frame(width: 92, height: 92)
                                    .shadow(color: AppTheme.accentPurple.opacity(0.42),
                                            radius: 18, x: 0, y: 8)

                                Image(systemName: "person.fill")
                                    .font(.system(size: 38, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            VStack(spacing: 5) {
                                Text("Anonymous User")
                                    .font(.title3.bold())
                                    .foregroundColor(AppTheme.textPrimary)

                                if let uid = Auth.auth().currentUser?.uid {
                                    Text("ID: \(uid.prefix(8))…")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(AppTheme.surface)
                                        .clipShape(Capsule())
                                } else {
                                    Text("Not connected")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                        }
                        .padding(.top, 20)

                        // Cloud sync badge
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.success.opacity(0.12))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "checkmark.icloud.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(AppTheme.success)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Cloud Sync Active")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("Your data is synced securely")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }

                            Spacer()

                            PillTag(text: "Live", color: AppTheme.success)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                .fill(AppTheme.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                        .stroke(AppTheme.success.opacity(0.20), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)

                        // Info card
                        VStack(alignment: .leading, spacing: 10) {
                            Label("About Sync", systemImage: "info.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textSecondary)

                            Text("Your subscriptions are securely synced to the cloud anonymously using your device ID. No Google Account is required to sync.")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .glassCard(cornerRadius: AppTheme.radiusMd)
                        .padding(.horizontal, 20)

                        Color.clear.frame(height: 110)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
