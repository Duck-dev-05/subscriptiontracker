import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMsg: String?

    init() {
        // Check if there is already a user logged in
        if Auth.auth().currentUser != nil {
            self.isAuthenticated = true
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
