import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var isAnonymous: Bool = Auth.auth().currentUser?.isAnonymous ?? true
    @State private var authStateHandle: AuthStateDidChangeListenerHandle?
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                if isAnonymous {
                    LoginView()
                } else {
                    profileContent
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                authStateHandle = Auth.auth().addStateDidChangeListener { _, user in
                    isAnonymous = user?.isAnonymous ?? true
                }
            }
            .onDisappear {
                if let handle = authStateHandle {
                    Auth.auth().removeStateDidChangeListener(handle)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var profileContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Avatar + name
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accentGradient)
                            .frame(width: 92, height: 92)
                            .shadow(color: AppTheme.accentPurple.opacity(0.42),
                                    radius: 18, x: 0, y: 8)

                        Image(systemName: "person.fill")
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    VStack(spacing: 5) {
                        if let email = Auth.auth().currentUser?.email {
                            Text(email)
                                .font(.title3.bold())
                                .foregroundColor(AppTheme.textPrimary)
                        } else {
                            Text("User")
                                .font(.title3.bold())
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        if let uid = Auth.auth().currentUser?.uid {
                            Text("ID: \(uid.prefix(8))…")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(AppTheme.surface)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.top, 20)

                // Cloud sync badge
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.success.opacity(0.12))
                            .frame(width: 50, height: 50)
                        Image(systemName: "checkmark.icloud.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.success)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Cloud Sync Active")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Your data is synced securely")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Spacer()

                    PillTag(text: "Live", color: AppTheme.success)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                        .fill(AppTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                .stroke(AppTheme.success.opacity(0.20), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                
                // Settings Button
                Button {
                    showSettings = true
                } label: {
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                            .fill(AppTheme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 20)
                
                // Log Out Button
                Button {
                    try? Auth.auth().signOut()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Log Out")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(AppTheme.danger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                            .fill(AppTheme.danger.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                    .stroke(AppTheme.danger.opacity(0.25), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 20)

                Color.clear.frame(height: 110)
            }
        }
    }
}

// MARK: - Login View

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                Spacer().frame(height: 40)
                
                // Hero
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accentPurple.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 34))
                            .foregroundColor(AppTheme.accentPurple)
                    }
                    
                    Text(isSignUp ? "Create Account" : "Welcome Back")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(isSignUp ? "Sign up to sync your subscriptions across devices." : "Log in to access your synced subscriptions.")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Form
                VStack(spacing: 16) {
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(AppTheme.danger)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.danger.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    VStack(spacing: 0) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        
                        Divider().background(AppTheme.border)
                        
                        SecureField("Password", text: $password)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                            .fill(AppTheme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                    )
                    
                    Button(action: submit) {
                        ZStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(isSignUp ? "Sign Up" : "Log In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                .fill(AppTheme.accentGradient)
                        )
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .opacity((isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                    .shadow(color: AppTheme.accentPurple.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 20)
                
                // Toggle mode
                Button {
                    withAnimation {
                        isSignUp.toggle()
                        errorMessage = ""
                    }
                } label: {
                    Text(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.accentPurple)
                }
                
                Color.clear.frame(height: 110)
            }
        }
    }
    
    private func submit() {
        isLoading = true
        errorMessage = ""
        
        if isSignUp {
            if let user = Auth.auth().currentUser, user.isAnonymous {
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                user.link(with: credential) { result, error in
                    isLoading = false
                    if let error = error {
                        errorMessage = error.localizedDescription
                    }
                }
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    isLoading = false
                    if let error = error { errorMessage = error.localizedDescription }
                }
            }
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                isLoading = false
                if let error = error { errorMessage = error.localizedDescription }
            }
        }
    }
}
