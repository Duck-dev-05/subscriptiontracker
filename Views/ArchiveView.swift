import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject var manager: SubscriptionManager

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if manager.archivedSubscriptions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 44))
                        .foregroundColor(AppTheme.textTertiary)
                    Text("Nothing Archived")
                        .font(.headline)
                        .foregroundColor(AppTheme.textSecondary)
                    Text("Archived subscriptions will appear here")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(manager.archivedSubscriptions) { sub in
                            archivedRow(sub)
                        }
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("Archive")
        .navigationBarTitleDisplayMode(.large)

    }

    private func archivedRow(_ sub: Subscription) -> some View {
        let accent = Color(hex: sub.colorHex) ?? AppTheme.accentPurple

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.08))
                    .frame(width: 46, height: 46)
                Text(sub.icon)
                    .font(.system(size: 22))
                    .opacity(0.55)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(sub.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary.opacity(0.55))
                PillTag(text: "Archived", color: AppTheme.textSecondary)
            }

            Spacer()

            Button {
                var updated = sub
                updated.isArchived = false
                manager.update(updated)
            } label: {
                Text("Reactivate")
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.accentPurple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(AppTheme.accentPurple.opacity(0.10))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppTheme.accentPurple.opacity(0.28), lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                .fill(AppTheme.surface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                        .stroke(AppTheme.border.opacity(0.5), lineWidth: 1)
                )
        )
    }
}
