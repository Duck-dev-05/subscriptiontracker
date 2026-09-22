import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentStep = 0
    
    let steps = [
        OnboardingStep(
            title: "Track Subscriptions",
            description: "Never lose track of your recurring payments again.",
            icon: "creditcard.fill",
            color: AppTheme.accentPurple
        ),
        OnboardingStep(
            title: "Smart Analytics",
            description: "Understand your spending habits with detailed breakdowns.",
            icon: "chart.pie.fill",
            color: .blue
        ),
        OnboardingStep(
            title: "Get Notified",
            description: "Receive alerts before your bills are due.",
            icon: "bell.badge.fill",
            color: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Icon / Illustration
                ZStack {
                    Circle()
                        .fill(steps[currentStep].color.opacity(0.15))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: steps[currentStep].icon)
                        .font(.system(size: 60))
                        .foregroundColor(steps[currentStep].color)
                }
                .padding(.bottom, 40)
                
                // Text Content
                VStack(spacing: 16) {
                    Text(steps[currentStep].title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(steps[currentStep].description)
                        .font(.body)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentStep ? steps[currentStep].color : AppTheme.surface)
                            .frame(width: index == currentStep ? 24 : 8, height: 8)
                            .animation(.spring(), value: currentStep)
                    }
                }
                .padding(.bottom, 40)
                
                // Next / Get Started Button
                Button {
                    withAnimation {
                        if currentStep < steps.count - 1 {
                            currentStep += 1
                        } else {
                            hasSeenOnboarding = true
                        }
                    }
                } label: {
                    Text(currentStep == steps.count - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMd)
                                .fill(AppTheme.accentGradient)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .shadow(color: AppTheme.accentPurple.opacity(0.4), radius: 12, x: 0, y: 6)
            }
        }
    }
}

struct OnboardingStep {
    let title: String
    let description: String
    let icon: String
    let color: Color
}
