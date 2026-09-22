import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    return true
  }
}

@main
struct SubscriptionTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var authManager = AuthenticationManager()

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isChecking {
                ZStack {
                    Color(UIColor.systemBackground).ignoresSafeArea()
                    VStack(spacing: 30) {
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Subscription Tracker")
                            .font(.largeTitle)
                            .bold()
                    }
                }
            } else if authManager.isAuthenticated {
                ContentView()
                    .environmentObject(subscriptionManager)
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
            }
        }
    }
}
