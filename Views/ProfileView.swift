import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

struct ProfileView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @EnvironmentObject var storeManager: StoreManager
    
    @State private var isAnonymous: Bool = Auth.auth().currentUser?.isAnonymous ?? true
    @State private var authStateHandle: AuthStateDidChangeListenerHandle?
    @State private var showSettings = false
    @State private var showPaywall = false
    
    @AppStorage("needsManualOnboarding") private var needsManualOnboarding = false
    @AppStorage("needsGoogleScan") private var needsGoogleScan = false

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
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $needsManualOnboarding) {
            OnboardingPlatformSelectionView()
        }
        .fullScreenCover(isPresented: $needsGoogleScan) {
            AutoScanningView()
        }
    }

    private var profileContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // Avatar + Name
                VStack(spacing: 16) {
                    ZStack {
                        if let photoURL = Auth.auth().currentUser?.photoURL {
                            AsyncImage(url: photoURL) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 92, height: 92)
                                        .clipShape(Circle())
                                } else if phase.error != nil {
                                    Circle()
                                        .fill(AppTheme.accentGradient)
                                        .frame(width: 92, height: 92)
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 38, weight: .semibold))
                                        .foregroundColor(.white)
                                } else {
                                    Circle()
                                        .fill(AppTheme.accentGradient)
                                        .frame(width: 92, height: 92)
                                    ProgressView().tint(.white)
                                }
                            }
                            
                            // Pro border if they have a custom photo
                            if storeManager.isPro {
                                Circle()
                                    .stroke(LinearGradient(colors: [Color(hex: "FFD700")!, Color(hex: "FDB931")!], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4)
                                    .frame(width: 96, height: 96)
                            }
                        } else {
                            Circle()
                                .fill(storeManager.isPro ? 
                                      LinearGradient(colors: [Color(hex: "FFD700")!, Color(hex: "FDB931")!], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                      AppTheme.accentGradient)
                                .frame(width: 92, height: 92)
                                .shadow(color: storeManager.isPro ? Color(hex: "FFD700")!.opacity(0.4) : AppTheme.accentPurple.opacity(0.42),
                                        radius: 18, x: 0, y: 8)

                            Image(systemName: storeManager.isPro ? "crown.fill" : "person.fill")
                                .font(.system(size: 38, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }

                    VStack(spacing: 5) {
                        let user = Auth.auth().currentUser
                        if let displayName = user?.displayName, !displayName.isEmpty {
                            Text(displayName)
                                .font(.title2.bold())
                                .foregroundColor(AppTheme.textPrimary)
                            if let email = user?.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        } else if let email = user?.email {
                            Text(email)
                                .font(.title3.bold())
                                .foregroundColor(AppTheme.textPrimary)
                        } else {
                            Text("User")
                                .font(.title3.bold())
                                .foregroundColor(AppTheme.textPrimary)
                        }

                        if storeManager.isPro {
                            Text("Pro Member")
                                .font(.caption.bold())
                                .foregroundColor(Color(hex: "FFD700"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(hex: "FFD700")!.opacity(0.15))
                                .clipShape(Capsule())
                        } else if let uid = Auth.auth().currentUser?.uid {
                            Text("ID: \(uid.prefix(8))…")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(AppTheme.borderStrong, lineWidth: 1))
                        }
                    }
                }
                .padding(.top, 20)
                
                // User Stats
                HStack(spacing: 16) {
                    statBox(title: "Active Subs", value: "\(manager.activeSubscriptions.count)", icon: "list.bullet.rectangle.fill", color: .blue)
                    statBox(title: "Monthly", value: "\(manager.currencySymbol)\(String(format: "%.0f", manager.totalMonthlyCost))", icon: "chart.bar.fill", color: .green)
                }
                .padding(.horizontal, 20)

                // Pro Banner
                if !storeManager.isPro {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle().fill(Color(hex: "FFD700")!.opacity(0.2)).frame(width: 46, height: 46)
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "FFD700"))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Upgrade to Pro")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("Unlock unlimited subscriptions & more")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                                .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous).stroke(Color(hex: "FFD700")!.opacity(0.3), lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 20)
                    .buttonStyle(PlainButtonStyle())
                }

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
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                .stroke(AppTheme.borderStrong, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                
                // Actions
                VStack(spacing: 12) {
                    actionButton(title: "Settings", icon: "gearshape.fill", color: AppTheme.textPrimary) { showSettings = true }
                    
                    Button {
                        manager.clearLocalCache()
                        try? Auth.auth().signOut()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log Out")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(AppTheme.danger)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                .fill(AppTheme.danger.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                        .stroke(AppTheme.danger.opacity(0.25), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 20)

                Color.clear.frame(height: 110)
            }
        }
    }
    
    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)
                Text(title)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous).stroke(AppTheme.borderStrong, lineWidth: 1))
        )
    }
    
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.subheadline.bold())
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                            .stroke(AppTheme.borderStrong, lineWidth: 1)
                    )
            )
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
    
    @AppStorage("needsManualOnboarding") private var needsManualOnboarding = false
    @AppStorage("needsGoogleScan") private var needsGoogleScan = false
    
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
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.radiusMd, style: .continuous)
                                    .stroke(AppTheme.borderStrong, lineWidth: 1)
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
                    
                    HStack {
                        VStack { Divider().background(AppTheme.border) }
                        Text("OR")
                            .font(.caption.bold())
                            .foregroundColor(AppTheme.textSecondary)
                        VStack { Divider().background(AppTheme.border) }
                    }
                    .padding(.vertical, 10)
                    
                    Button(action: signInWithGoogle) {
                        HStack(spacing: 12) {
                            Image(systemName: "g.circle.fill") // Placeholder for Google logo
                                .font(.system(size: 24))
                            Text("Continue with Google")
                                .font(.headline)
                        }
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                .fill(.ultraThinMaterial)
                                .environment(\.colorScheme, .dark)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                        .stroke(AppTheme.borderStrong, lineWidth: 1)
                                )
                        )
                    }
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
                    if let error = error {
                        let nsError = error as NSError
                        if nsError.domain == AuthErrorDomain && nsError.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                            Auth.auth().signIn(withEmail: email, password: password) { _, signInError in
                                isLoading = false
                                if let signInError = signInError {
                                    errorMessage = signInError.localizedDescription
                                }
                            }
                        } else {
                            isLoading = false
                            errorMessage = error.localizedDescription
                        }
                    } else {
                        isLoading = false
                        needsManualOnboarding = true
                    }
                }
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    isLoading = false
                    if let error = error { errorMessage = error.localizedDescription }
                    else { needsManualOnboarding = true }
                }
            }
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                isLoading = false
                if let error = error { errorMessage = error.localizedDescription }
            }
        }
    }
    
    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            print("Could not find root view controller")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, hint: nil, additionalScopes: ["https://www.googleapis.com/auth/gmail.readonly"]) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else { return }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            isLoading = true
            
            if let currentUser = Auth.auth().currentUser, currentUser.isAnonymous {
                currentUser.link(with: credential) { _, error in
                    if let error = error {
                        let nsError = error as NSError
                        if nsError.domain == AuthErrorDomain && nsError.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                            Auth.auth().signIn(with: credential) { _, signInError in
                                isLoading = false
                                if let signInError = signInError {
                                    errorMessage = signInError.localizedDescription
                                }
                            }
                        } else {
                            isLoading = false
                            errorMessage = error.localizedDescription
                        }
                    } else {
                        isLoading = false
                        needsGoogleScan = true
                    }
                }
            } else {
                Auth.auth().signIn(with: credential) { _, error in
                    isLoading = false
                    if let error = error { errorMessage = error.localizedDescription }
                    else { needsGoogleScan = true }
                }
            }
        }
    }
}
