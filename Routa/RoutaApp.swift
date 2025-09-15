import SwiftUI
import FirebaseAuth
import FirebaseCore
import Foundation

@main
struct RoutaApp: App {
    // Dependency Container - ileride kullanacağız
    @StateObject private var dependencyContainer = DependencyContainer()
    @StateObject private var themeManager = RoutaThemeManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var authManager = AuthManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isCheckingAuth = true
    @State private var showLaunchScreen = true
    
    init() {
        FirebaseApp.configure()
    }

    
    var body: some Scene {
        WindowGroup {
            Group {
                if showLaunchScreen {
                    // Show launch screen while checking auth state
                    LaunchScreenView()
                } else if !hasCompletedOnboarding {
                    // Show onboarding for new users
                    OnboardingView {
                        hasCompletedOnboarding = true
                        authManager.appState = .gateway
                    }
                    .environmentObject(dependencyContainer)
                    .environmentObject(themeManager)
                    .environmentObject(languageManager)
                    .environmentObject(authManager)
                } else if authManager.isAuthenticated || authManager.isGuest {
                    // Show main app for authenticated users and guests
                    ContentView()
                        .environmentObject(dependencyContainer)
                        .environmentObject(themeManager)
                        .environmentObject(languageManager)
                        .environmentObject(authManager)
                        .onAppear {
                            print("🔵 Showing ContentView - isAuthenticated: \(authManager.isAuthenticated), isGuest: \(authManager.isGuest)")
                        }
                } else {
                    // Show auth gateway for unauthenticated users
                    AuthGatewayView()
                        .environmentObject(dependencyContainer)
                        .environmentObject(themeManager)
                        .environmentObject(languageManager)
                        .environmentObject(authManager)
                        .onAppear {
                            print("🔵 Showing AuthGatewayView - isAuthenticated: \(authManager.isAuthenticated), isGuest: \(authManager.isGuest)")
                        }
                }
            }
            .detectLanguageChange() // Force UI refresh on language change
            .routaDesignSystem()
            .onAppear {
                setupApp()
            }
        }
    }
    
    private func setupApp() {
        // Setup design system immediately
        RoutaDesignSystemConfiguration.setupDesignSystem()
        
        // Hide launch screen after a brief moment to allow Firebase auth to initialize
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showLaunchScreen = false
                isCheckingAuth = false
            }
        }
    }
}

// MARK: - Launch Screen View
struct LaunchScreenView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.routaPrimary,
                    Color.routaSecondary,
                    Color.routaAccent
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App Logo
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .routaGlow(color: .white, radius: 20)
                    
                    Image(systemName: "map.circle.fill")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // App Name
                Text("Routa")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(logoOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}

// Dependency Injection Container
class DependencyContainer: ObservableObject {
    // Repositories
    let destinationRepository: DestinationRepository
    let routeRepository: RouteRepository
    let placeRepository: PlaceRepository
    
    init() {
        // Initialize repositories with mock implementations
        self.destinationRepository = MockDestinationRepository()
        self.routeRepository = MockRouteRepository()
        self.placeRepository = MockPlaceRepository()
    }
}
