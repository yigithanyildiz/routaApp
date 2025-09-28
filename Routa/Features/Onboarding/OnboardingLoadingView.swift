import SwiftUI

// MARK: - Onboarding Loading View
struct OnboardingLoadingView: View {
    @StateObject private var cacheManager = ImageCacheManager.shared
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0

    var onComplete: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark background
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Logo Section
                    VStack(spacing: 16) {
                        // App Logo/Icon (placeholder - can be replaced with actual logo)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.routaPrimary, .routaSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "location.fill")
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(.white)
                            )
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)

                        // App Name
                        Text("Routa")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(logoOpacity)
                    }

                    Spacer()

                    // Loading Section
                    VStack(spacing: 24) {
                        // Loading Text
                        Text("Preparing your adventure...")
                            .font(.body)
                            .foregroundColor(.gray)
                            .opacity(logoOpacity)

                        // Progress Bar
                        VStack(spacing: 8) {
                            ProgressView(value: cacheManager.preloadingProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .routaPrimary))
                                .frame(height: 4)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(2)
                                .opacity(logoOpacity)

                            // Progress Percentage
                            Text("\(Int(cacheManager.preloadingProgress * 100))%")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .opacity(logoOpacity)
                        }
                    }
                    .padding(.horizontal, 60)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 60)
                }
            }
        }
        .onAppear {
            startLoadingAnimation()
            startImagePreloading()
        }
        .onChange(of: cacheManager.isPreloadingComplete) { _, isComplete in
            if isComplete {
                completeLoading()
            }
        }
    }

    // MARK: - Animation Methods
    private func startLoadingAnimation() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            logoOpacity = 1.0
            logoScale = 1.0
        }
    }

    private func startImagePreloading() {
        Task {
            await cacheManager.preloadOnboardingImages()
        }
    }

    private func completeLoading() {
        // Small delay for smooth transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                onComplete()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingLoadingView {
        print("Loading complete!")
    }
}