import SwiftUI

struct AutoScanningView: View {
    @EnvironmentObject var manager: SubscriptionManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var statusMessage = "Scanning your inbox for subscriptions..."
    @State private var isScanning = true
    @State private var foundCount = 0
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                if isScanning {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accentPurple))
                        .scaleEffect(1.5)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.success)
                }
                
                Text(statusMessage)
                    .font(.title3.bold())
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                if !isScanning {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Continue")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                    .fill(AppTheme.accentGradient)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                }
            }
        }
        .onAppear(perform: startScan)
        .navigationBarHidden(true)
    }
    
    private func startScan() {
        GmailScannerService.shared.scanForSubscriptions { result in
            DispatchQueue.main.async {
                self.isScanning = false
                
                switch result {
                case .success(let subscriptions):
                    if subscriptions.isEmpty {
                        self.statusMessage = "No subscriptions found in recent emails."
                    } else {
                        self.foundCount = subscriptions.count
                        self.statusMessage = "Found \(self.foundCount) subscriptions!"
                        for sub in subscriptions {
                            self.manager.add(sub)
                        }
                    }
                case .failure(let error):
                    // In a real app we might handle this better, but for demo we fail gracefully
                    self.statusMessage = "Scan failed or permissions missing. Please add subscriptions manually."
                    print("Scanner error: \(error)")
                }
            }
        }
    }
}
