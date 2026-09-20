import SwiftUI

struct DiscoverTemplate: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let category: SubscriptionCategory
    let colorHex: String
    let estimatedPrice: Double
}

struct DiscoverView: View {
    @State private var selectedTemplate: DiscoverTemplate? = nil
    
    let popularTemplates: [DiscoverTemplate] = [
        DiscoverTemplate(name: "Netflix", icon: "🎬", category: .streaming, colorHex: "E50914", estimatedPrice: 15.49),
        DiscoverTemplate(name: "Spotify", icon: "🎵", category: .music, colorHex: "1DB954", estimatedPrice: 10.99),
        DiscoverTemplate(name: "Apple One", icon: "🍎", category: .other, colorHex: "000000", estimatedPrice: 19.95),
        DiscoverTemplate(name: "Amazon Prime", icon: "📦", category: .other, colorHex: "00A8E1", estimatedPrice: 14.99),
        DiscoverTemplate(name: "Gym Membership", icon: "💪", category: .fitness, colorHex: "34C759", estimatedPrice: 40.00),
        DiscoverTemplate(name: "iCloud+", icon: "☁️", category: .cloud, colorHex: "5AC8FA", estimatedPrice: 2.99),
        DiscoverTemplate(name: "Xbox Game Pass", icon: "🎮", category: .gaming, colorHex: "107C10", estimatedPrice: 16.99),
        DiscoverTemplate(name: "Disney+", icon: "📺", category: .streaming, colorHex: "113CCF", estimatedPrice: 13.99),
        DiscoverTemplate(name: "Adobe Creative Cloud", icon: "🎨", category: .productivity, colorHex: "FF0000", estimatedPrice: 54.99),
        DiscoverTemplate(name: "ChatGPT Plus", icon: "🤖", category: .productivity, colorHex: "10A37F", estimatedPrice: 20.00)
    ]

    var body: some View {
        NavigationView {
            List(popularTemplates) { template in
                Button(action: {
                    selectedTemplate = template
                }) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: template.colorHex)?.opacity(0.2) ?? Color.blue.opacity(0.2))
                                .frame(width: 44, height: 44)
                            Text(template.icon)
                                .font(.system(size: 24))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(template.category.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("~\(String(format: "%.2f", template.estimatedPrice))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Discover")
            .sheet(item: $selectedTemplate) { template in
                AddEditSubscriptionView(mode: .template(Subscription(
                    id: UUID(), // temporary ID
                    name: template.name,
                    price: template.estimatedPrice,
                    billingCycle: .monthly,
                    nextBillingDate: Date(),
                    colorHex: template.colorHex,
                    category: template.category,
                    icon: template.icon,
                    notes: "Added from template"
                )))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
