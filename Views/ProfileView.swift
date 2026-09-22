import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Info")) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Anonymous User")
                                .font(.headline)
                            
                            if let uid = Auth.auth().currentUser?.uid {
                                Text("ID: \(uid.prefix(8))...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Not connected")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Data Sync"), footer: Text("Your subscriptions are securely synced to the cloud anonymously using your device ID. We no longer require a Google Account to sync.")) {
                    HStack {
                        Image(systemName: "checkmark.icloud.fill")
                            .foregroundColor(.green)
                        Text("Cloud Sync Active")
                    }
                }
            }
            .navigationTitle("Profile")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
