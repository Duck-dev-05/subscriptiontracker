import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isChecking: Bool = true
    @Published var errorMsg: String?

    init() {
        // Ensure Firebase is configured before accessing any Auth features
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Always rely strictly on the listener to prevent flashing wrong screens
        // due to slow keychain reads or stale cached tokens.
        
        // Listen to Firebase auth state changes to reliably check if a user is logged in
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                self?.isChecking = false
            }
        }
    }

    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.errorMsg = "Firebase is not configured correctly."
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error = error {
                self?.errorMsg = error.localizedDescription
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self?.errorMsg = "Google Sign In missed user data"
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMsg = error.localizedDescription
                        return
                    }
                    self?.isAuthenticated = true
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
        } catch let signOutError {
            self.errorMsg = "Error signing out: \(signOutError.localizedDescription)"
        }
    }
}
