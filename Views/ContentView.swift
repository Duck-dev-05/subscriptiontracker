import SwiftUI

// MARK: - Tab Enum

enum AppTab: Int, CaseIterable {
    case home, statistics, profile, settings

    var title: String {
        switch self {
        case .home:       return "Home"
        case .statistics: return "Analytics"
        case .profile:    return "Profile"
        case .settings:   return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home:       return "house.fill"
        case .statistics: return "chart.pie.fill"
        case .profile:    return "person.crop.circle.fill"
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
            
            StatisticsView()
                .tabItem {
                    Label(AppTab.statistics.title, systemImage: AppTab.statistics.icon)
                }
                .tag(AppTab.statistics)
                
            ProfileView()
                .tabItem {
                    Label(AppTab.profile.title, systemImage: AppTab.profile.icon)
                }
                .tag(AppTab.profile)
            
            SettingsView()
                .tabItem {
                    Label(AppTab.settings.title, systemImage: AppTab.settings.icon)
                }
                .tag(AppTab.settings)
        }
        .onAppear {
            NotificationManager.shared.requestPermission()
        }
    }
}
