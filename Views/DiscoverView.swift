import SwiftUI

// MARK: - Template Model

struct SubscriptionTemplate: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let cycle: BillingCycle
    let category: SubscriptionCategory
    let icon: String
    let colorHex: String

    var asSubscription: Subscription {
        Subscription(
            name: name,
            price: price,
            billingCycle: cycle,
            nextBillingDate: Date(),
            colorHex: colorHex,
            category: category,
            icon: icon
        )
    }
}

// Category enum cases mapped to valid SubscriptionCategory values
let popularTemplates: [SubscriptionTemplate] = [
    SubscriptionTemplate(name: "Netflix",              price: 15.49,  cycle: .monthly, category: .streaming,    icon: "🎬", colorHex: "E50914"),
    SubscriptionTemplate(name: "Spotify",              price: 10.99,  cycle: .monthly, category: .music,        icon: "🎵", colorHex: "1DB954"),
    SubscriptionTemplate(name: "Amazon Prime",         price: 139.00, cycle: .yearly,  category: .other,        icon: "📦", colorHex: "00A8E1"),
    SubscriptionTemplate(name: "Disney+",              price: 7.99,   cycle: .monthly, category: .streaming,    icon: "✨", colorHex: "113CCF"),
    SubscriptionTemplate(name: "Apple Music",          price: 10.99,  cycle: .monthly, category: .music,        icon: "🍎", colorHex: "FA243C"),
    SubscriptionTemplate(name: "Gym",                  price: 50.00,  cycle: .monthly, category: .fitness,      icon: "💪", colorHex: "2C2C2C"),
    SubscriptionTemplate(name: "iCloud+",              price: 2.99,   cycle: .monthly, category: .cloud,        icon: "☁️", colorHex: "007AFF"),
    SubscriptionTemplate(name: "PlayStation Plus",     price: 17.99,  cycle: .monthly, category: .gaming,       icon: "🎮", colorHex: "003791"),
    SubscriptionTemplate(name: "Xbox Game Pass",       price: 16.99,  cycle: .monthly, category: .gaming,       icon: "🕹️", colorHex: "107C10"),
    SubscriptionTemplate(name: "Adobe Creative Cloud", price: 54.99,  cycle: .monthly, category: .productivity, icon: "🎨", colorHex: "FF0000"),
]

// MARK: - Discover View

struct DiscoverView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @State private var selectedTemplate: Subscription?
    @State private var showingLimitAlert = false

    let columns = [GridItem(.adaptive(minimum: 155), spacing: 14)]

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Inline header
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Popular apps")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("Discover")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(popularTemplates) { template in
                                TemplateCard(template: template)
                                    .onTapGesture {
                                        if manager.isAnonymous && manager.subscriptions.count >= 3 {
                                            showingLimitAlert = true
                                        } else {
                                            selectedTemplate = template.asSubscription
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)

                        Color.clear.frame(height: 110)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedTemplate) { sub in
                AddEditSubscriptionView(mode: .template(sub))
            }
            .alert("Guest Limit Reached", isPresented: $showingLimitAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Sign up for free in your Profile to add unlimited subscriptions!")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Template Card

struct TemplateCard: View {
    let template: SubscriptionTemplate
    @State private var pressed = false

    private var cardColor: Color {
        Color(hex: template.colorHex) ?? AppTheme.accentPurple
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.14))
                    .frame(width: 64, height: 64)
                Text(template.icon)
                    .font(.system(size: 32))
            }

            VStack(spacing: 5) {
                Text(template.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text(String(format: "$%.2f / %@",
                            template.price,
                            template.cycle.abbreviation.replacingOccurrences(of: "/", with: "")))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.72))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 152)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [cardColor, cardColor.opacity(0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
        )
        .shadow(color: cardColor.opacity(0.30), radius: 10, x: 0, y: 6)
        .scaleEffect(pressed ? 0.93 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in pressed = pressing }, perform: {})
    }
}
