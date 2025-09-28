import SwiftUI

// MARK: - Onboarding Container View
struct OnboardingContainerView: View {
    @State private var isLoadingComplete = false
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            if isLoadingComplete {
                // Show main onboarding after loading
                OnboardingView(onComplete: onComplete)
                    .transition(.opacity)
            } else {
                // Show loading screen first
                OnboardingLoadingView {
                    isLoadingComplete = true
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isLoadingComplete)
    }
}

// MARK: - Preview
#Preview {
    OnboardingContainerView {
        print("Onboarding complete!")
    }
}