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
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(AppTab.home.title, systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)
            
            CalendarView()
                .tabItem {
                    Label(AppTab.calendar.title, systemImage: AppTab.calendar.icon)
                }
                .tag(AppTab.calendar)
            
            DiscoverView()
                .tabItem {
                    Label(AppTab.discover.title, systemImage: AppTab.discover.icon)
                }
                .tag(AppTab.discover)
            
            StatisticsView()
                .tabItem {
                    Label(AppTab.statistics.title, systemImage: AppTab.statistics.icon)
                }
                .tag(AppTab.statistics)
            
            SettingsView()
                .tabItem {
                    Label(AppTab.settings.title, systemImage: AppTab.settings.icon)
                }
                .tag(AppTab.settings)
        }
    }
}
