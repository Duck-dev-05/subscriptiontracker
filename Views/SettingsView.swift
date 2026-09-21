import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingWipeAlert = false

    let currencies = ["$", "£", "€", "¥", "₹"]

    var body: some View {
        NavigationView {
            Form {
                if let user = Auth.auth().currentUser {
                    Section(header: Text("Profile")) {
                        HStack {
                            if let photoURL = user.photoURL {
                                AsyncImage(url: photoURL) { image in
                                    image.resizable()
                                         .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(user.displayName ?? "User")
                                    .font(.headline)
                                Text(user.email ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(role: .destructive, action: {
                            authManager.signOut()
                        }) {
                            Text("Sign Out")
                        }
                    }
                }
                
                Section(header: Text("Preferences"), footer: Text("The currency symbol is used throughout the app to display your subscription costs.")) {
                    Picker("Currency", selection: $manager.currencySymbol) {
                        ForEach(currencies, id: \.self) { sym in
                            Text(sym).tag(sym)
                        }
                    }
                }
                
                Section(header: Text("Data")) {
                    NavigationLink(destination: ArchiveView()) {
                        Text("View Archived Subscriptions")
                    }
                    
                    Button(role: .destructive, action: { showingWipeAlert = true }) {
                        Text("Erase All Subscriptions")
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Antigravity")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Erase All Data?", isPresented: $showingWipeAlert) {
                Button("Erase All", role: .destructive) {
                    withAnimation { manager.clearAll() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. All your subscriptions will be permanently deleted.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
