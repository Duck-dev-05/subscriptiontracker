import SwiftUI

struct SubscriptionTemplate: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let category: SubscriptionCategory
    let colorHex: String
    let estimatedPrice: Double
}

struct DiscoverView: View {
    @State private var selectedTemplate: SubscriptionTemplate? = nil
    
    let popularTemplates: [SubscriptionTemplate] = [
        SubscriptionTemplate(name: "Netflix", icon: "🎬", category: .streaming, colorHex: "E50914", estimatedPrice: 15.49),
        SubscriptionTemplate(name: "Spotify", icon: "🎵", category: .music, colorHex: "1DB954", estimatedPrice: 10.99),
        SubscriptionTemplate(name: "Apple One", icon: "🍎", category: .other, colorHex: "000000", estimatedPrice: 19.95),
        SubscriptionTemplate(name: "Amazon Prime", icon: "📦", category: .other, colorHex: "00A8E1", estimatedPrice: 14.99),
        SubscriptionTemplate(name: "Gym", icon: "💪", category: .fitness, colorHex: "3A86FF", estimatedPrice: 30.00),
        SubscriptionTemplate(name: "Adobe CC", icon: "🖥️", category: .productivity, colorHex: "FF0000", estimatedPrice: 54.99),
        SubscriptionTemplate(name: "iCloud+", icon: "☁️", category: .cloud, colorHex: "3A86FF", estimatedPrice: 2.99),
        SubscriptionTemplate(name: "PlayStation Plus", icon: "🎮", category: .gaming, colorHex: "003791", estimatedPrice: 14.99),
        SubscriptionTemplate(name: "Xbox Game Pass", icon: "🎮", category: .gaming, colorHex: "107C10", estimatedPrice: 14.99),
        SubscriptionTemplate(name: "NY Times", icon: "📰", category: .news, colorHex: "000000", estimatedPrice: 17.00)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Popular Subscriptions")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(popularTemplates) { template in
                                TemplateCard(template: template)
                                    .onTapGesture {
                                        selectedTemplate = template
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Discover")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $selectedTemplate) { template in
            // When a template is selected, open the Add screen pre-filled with a dummy subscription object.
            AddEditSubscriptionView(mode: .template(Subscription(
                id: UUID(), // temporary ID
                name: template.name,
                price: template.estimatedPrice,
                billingCycle: .monthly,
                nextBillingDate: Date(),
                colorHex: template.colorHex,
                category: template.category,
                icon: template.icon,
                notes: ""
            )))
        }
    }
}

// MARK: - Template Card

struct TemplateCard: View {
    let template: SubscriptionTemplate
    
    private var accent: Color {
        Color(hex: template.colorHex) ?? .accentIndigo
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Text(template.icon)
                    .font(.system(size: 28))
            }
            
            VStack(spacing: 4) {
                Text(template.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                Text(template.category.rawValue)
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .glassCard()
    }
}
