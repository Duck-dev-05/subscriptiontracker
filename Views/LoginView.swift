import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "cloud.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Subscription Tracker")
                .font(.largeTitle)
                .bold()
            
            Text("Sign in with Google to sync your subscriptions securely across all your devices.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            if let error = authManager.errorMsg {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button(action: {
                authManager.signInWithGoogle()
            }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .font(.title2)
                    Text("Sign in with Google")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}
