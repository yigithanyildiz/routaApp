import SwiftUI

// MARK: - Onboarding Page Model
struct OnboardingPage: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let imageURL: String
    let gradientColors: [Color]
    let requiresLocationPermission: Bool
    let requiresNotificationPermission: Bool

    init(
        title: String,
        subtitle: String,
        description: String,
        imageURL: String,
        gradientColors: [Color],
        requiresLocationPermission: Bool = false,
        requiresNotificationPermission: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.imageURL = imageURL
        self.gradientColors = gradientColors
        self.requiresLocationPermission = requiresLocationPermission
        self.requiresNotificationPermission = requiresNotificationPermission
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Sample Onboarding Pages
extension OnboardingPage {
    static let samplePages: [OnboardingPage] = [
        OnboardingPage(
            title: "Discover Your Next Adventure",
            subtitle: "Welcome to Routa",
            description: "Create personalized travel routes, discover amazing destinations, and collect unforgettable memories.",
            imageURL: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&h=600",
            gradientColors: [.routaPrimary, .routaSecondary]
        ),

        OnboardingPage(
            title: "Smart Route Planning",
            subtitle: "AI-Powered Recommendations",
            description: "Our intelligent algorithm creates perfect routes based on your preferences, budget, and travel style.",
            imageURL: "https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=2070&auto=format&fit=crop",
            gradientColors: [.routaSecondary, .routaAccent]
        ),

        OnboardingPage(
            title: "Yıldızların Ötesine Yolculuk",
            subtitle: "Monitor Your Progress",
            description: "Sıradan yolların dışına çık, gözlerini gökyüzüne dik. Routa ile keşfedilecek sınırsız yer, yaşanacak sonsuz an var. Maceraya hazır mısın?",
            imageURL: "https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=2070&auto=format&fit=crop",
            
            gradientColors: [.routaAccent, .routaSuccess],
            requiresLocationPermission: true,
            requiresNotificationPermission: true
        )
    ]
}
