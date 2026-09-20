import SwiftUI

// MARK: - Tab Enum

enum AppTab: Int, CaseIterable {
    case home, calendar, discover, statistics, settings

    var title: String {
        switch self {
        case .home:       return "Home"
        case .calendar:   return "Calendar"
        case .discover:   return "Discover"
        case .statistics: return "Analytics"
        case .settings:   return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home:       return "house.fill"
        case .calendar:   return "calendar"
        case .discover:   return "sparkles.rectangle.stack.fill"
        case .statistics: return "chart.pie.fill"
        case .settings:   return "gearshape.fill"
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            // Page content
            Group {
                switch selectedTab {
                case .home:       HomeView()
                case .calendar:   CalendarView()
                case .discover:   DiscoverView()
                case .statistics: StatisticsView()
                case .settings:   SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabBarButton(tab: tab, isSelected: selectedTab == tab) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 14)
        .padding(.bottom, 28)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.surfaceColor.opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: -4)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(LinearGradient.heroGradient)
                            .frame(width: 42, height: 42)
                            .shadow(color: Color.accentIndigo.opacity(0.5), radius: 8)
                    }
                    Image(systemName: tab.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? .white : Color.textMuted)
                }

                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? Color.accentIndigo : Color.textMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
