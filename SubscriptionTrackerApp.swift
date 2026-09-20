import SwiftUI

@main
struct SubscriptionTrackerApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(subscriptionManager)
        }
    }
}
