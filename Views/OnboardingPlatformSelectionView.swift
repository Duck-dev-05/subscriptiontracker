import SwiftUI

struct PopularPlatform: Identifiable {
    let id = UUID()
    let name: String
    let domain: String
    let defaultCost: Double
    let cycle: BillingCycle
    let category: SubscriptionCategory
    let colorHex: String
}

struct OnboardingPlatformSelectionView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedPlatforms: Set<UUID> = []
    
    let platforms: [PopularPlatform] = [
        PopularPlatform(name: "Netflix", domain: "netflix.com", defaultCost: 15.49, cycle: .monthly, category: .streaming, colorHex: "E50914"),
        PopularPlatform(name: "Spotify", domain: "spotify.com", defaultCost: 10.99, cycle: .monthly, category: .music, colorHex: "1DB954"),
        PopularPlatform(name: "Apple Music", domain: "apple.com", defaultCost: 10.99, cycle: .monthly, category: .music, colorHex: "FA243C"),
        PopularPlatform(name: "YouTube", domain: "youtube.com", defaultCost: 13.99, cycle: .monthly, category: .streaming, colorHex: "FF0000"),
        PopularPlatform(name: "iCloud", domain: "icloud.com", defaultCost: 2.99, cycle: .monthly, category: .cloud, colorHex: "36C2FF"),
        PopularPlatform(name: "Amazon", domain: "amazon.com", defaultCost: 14.99, cycle: .monthly, category: .other, colorHex: "00A8E1"),
        PopularPlatform(name: "Hulu", domain: "hulu.com", defaultCost: 7.99, cycle: .monthly, category: .streaming, colorHex: "1CE783"),
        PopularPlatform(name: "Disney+", domain: "disneyplus.com", defaultCost: 7.99, cycle: .monthly, category: .streaming, colorHex: "113CCF"),
        PopularPlatform(name: "Xbox", domain: "xbox.com", defaultCost: 16.99, cycle: .monthly, category: .gaming, colorHex: "107C10")
    ]
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer().frame(height: 20)
                
                VStack(spacing: 8) {
                    Text("What are you subscribed to?")
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Select the ones you use. We'll set them up with default prices, which you can adjust later.")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(platforms) { platform in
                            PlatformCard(platform: platform, isSelected: selectedPlatforms.contains(platform.id))
                                .onTapGesture {
                                    if selectedPlatforms.contains(platform.id) {
                                        selectedPlatforms.remove(platform.id)
                                    } else {
                                        selectedPlatforms.insert(platform.id)
                                    }
                                }
                        }
                    }
                    .padding()
                }
                
                Button(action: saveAndContinue) {
                    Text(selectedPlatforms.isEmpty ? "Skip for now" : "Add \(selectedPlatforms.count) Subscriptions")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                .fill(AppTheme.accentGradient)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func saveAndContinue() {
        for platformId in selectedPlatforms {
            if let platform = platforms.first(where: { $0.id == platformId }) {
                let sub = Subscription(
                    name: platform.name,
                    price: platform.defaultCost,
                    billingCycle: platform.cycle,
                    nextBillingDate: Date().addingTimeInterval(86400 * 30), // Next month roughly
                    colorHex: platform.colorHex,
                    category: platform.category
                )
                manager.add(sub)
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
}

struct PlatformCard: View {
    let platform: PopularPlatform
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: platform.colorHex) ?? AppTheme.accentPurple)
                    .frame(width: 50, height: 50)
                
                if let url = URL(string: "https://logo.clearbit.com/\(platform.domain)") {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable()
                                 .scaledToFit()
                                 .frame(width: 30, height: 30)
                                 .clipShape(Circle())
                        } else if phase.error != nil {
                            Text(String(platform.name.prefix(1))).font(.title2.bold()).foregroundColor(.white)
                        } else {
                            ProgressView().tint(.white)
                        }
                    }
                } else {
                    Text(String(platform.name.prefix(1))).font(.title2.bold()).foregroundColor(.white)
                }
            }
            
            Text(platform.name)
                .font(.subheadline.bold())
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                .fill(isSelected ? AppTheme.accentPurple.opacity(0.2) : AppTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                        .stroke(isSelected ? AppTheme.accentPurple : AppTheme.border, lineWidth: isSelected ? 2 : 1)
                )
        )
    }
}
