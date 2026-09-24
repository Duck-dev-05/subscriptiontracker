import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeManager = StoreManager.shared
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header / Close button
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Hero Image
                    ZStack {
                        Circle()
                            .fill(AppTheme.accentPurple.opacity(0.15))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: 54))
                            .foregroundColor(Color(hex: "FFCC00")) // Gold color
                    }
                    
                    // Title and Subtitle
                    VStack(spacing: 8) {
                        Text("Unlock Premium")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Get unlimited access to all features and take full control of your subscriptions.")
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    // Features List
                    VStack(alignment: .leading, spacing: 20) {
                        FeatureRow(icon: "infinity", title: "Unlimited Subscriptions", description: "Add as many subscriptions as you want.")
                        FeatureRow(icon: "icloud.fill", title: "Cloud Sync", description: "Sync your data across all your devices.")
                        FeatureRow(icon: "bell.fill", title: "Smart Reminders", description: "Get notified before you get charged.")
                        FeatureRow(icon: "paintpalette.fill", title: "Custom Categories", description: "Create and manage your own categories.")
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Pricing Card
                    VStack(spacing: 16) {
                        Button {
                            storeManager.purchasePro()
                        } label: {
                            VStack(spacing: 4) {
                                Text(storeManager.isPro ? "Purchased!" : "Upgrade to Pro")
                                    .font(.headline)
                                Text(storeManager.proPrice)
                                    .font(.subheadline)
                                    .opacity(0.8)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "FFCC00")!, AppTheme.accentPurple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .disabled(storeManager.isPro)
                        .shadow(color: AppTheme.accentPurple.opacity(0.4), radius: 12, x: 0, y: 6)
                        
                        Button("Restore Purchases") {
                            storeManager.restorePurchases()
                        }
                        .font(.footnote.bold())
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.top, 4)
                        
                        Text("Cancel anytime. Terms & Conditions apply.")
                            .font(.caption2)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
        }
        .onChange(of: storeManager.isPro) { isPro in
            if isPro {
                dismiss() // Auto dismiss on purchase
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.accentPurple)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
}
