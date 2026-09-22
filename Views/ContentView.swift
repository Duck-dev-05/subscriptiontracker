import SwiftUI

// MARK: - Tab Enum

enum AppTab: Int, CaseIterable {
    case home, discover, statistics, settings, profile

    var title: String {
        switch self {
        case .home:       return "Home"
        case .discover:   return "Discover"
        case .statistics: return "Analytics"
        case .settings:   return "Settings"
        case .profile:    return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home:       return "house.fill"
        case .discover:   return "sparkles.rectangle.stack.fill"
        case .statistics: return "chart.pie.fill"
        case .settings:   return "gearshape.fill"
        case .profile:    return "person.crop.circle.fill"
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background.ignoresSafeArea()

            // Page content
            Group {
                switch selectedTab {
                case .home:       HomeView()
                case .discover:   DiscoverView()
                case .statistics: StatisticsView()
                case .settings:   SettingsView()
                case .profile:    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating tab bar
            FloatingTabBar(selectedTab: $selectedTab)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            NotificationManager.shared.requestPermission()
        }
    }
}

// MARK: - Floating Tab Bar

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabBarButton(tab: tab, selectedTab: $selectedTab)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(red: 0.09, green: 0.09, blue: 0.14).opacity(0.97))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.55), radius: 24, x: 0, y: 10)
        )
        .padding(.horizontal, 18)
        .padding(.bottom, 22)
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let tab: AppTab
    @Binding var selectedTab: AppTab

    private var isSelected: Bool { selectedTab == tab }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.33, dampingFraction: 0.68)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppTheme.accentGradient)
                            .frame(width: 46, height: 30)
                            .shadow(color: AppTheme.accentPurple.opacity(0.55),
                                    radius: 8, x: 0, y: 4)
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                }
                .frame(width: 46, height: 30)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(ScaleButtonStyle())
    }
}
