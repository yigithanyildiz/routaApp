import SwiftUI
import Foundation

/// Provides mock objects for SwiftUI previews to prevent crashes

@MainActor

struct PreviewProviders {
    
    // MARK: - Guest Auth Manager
    
    static let guestAuth: AuthManager = {
        let auth = AuthManager()
        // Keep as guest state - no user authentication
        return auth
    }()
    
    // MARK: - Authenticated Auth Manager
    
    static let authenticatedAuth: AuthManager = {
        let auth = AuthManager()
        // Mock authenticated user
        auth.user = User(
            id: "preview-user-123",
            email: "preview@routa.app",
            displayName: "Preview User"
        )
        auth.isAuthenticated = true
        auth.isGuest = false
        auth.appState = .authenticated
        
        // Mock favorites manager will be initialized when needed
        // Avoid actor isolation issues in static context
        
        return auth
    }()
    
    // MARK: - Dependency Container
    
    static let dependencyContainer = DependencyContainer()
    
    // MARK: - Theme Manager
    
    static let themeManager = RoutaThemeManager.shared
}

// MARK: - Preview Environment Setup

extension View {
    func previewEnvironment(authenticated: Bool = false) -> some View {
        let authManager = authenticated ? PreviewProviders.authenticatedAuth : PreviewProviders.guestAuth
        
        return self
            .environmentObject(authManager)
            .environmentObject(PreviewProviders.dependencyContainer)
            .environmentObject(PreviewProviders.themeManager)
    }
}

// MARK: - Mock Data Helpers

extension PreviewProviders {
    static let mockDestination = Destination(
        id: "preview-destination",
        name: "Preview Destination",
        country: "Preview Country",
        description: "This is a preview destination used in SwiftUI previews.",
        imageURL: "https://picsum.photos/400/300",
        popularMonths: ["Haziran", "Temmuz", "Ağustos"],
        averageTemperature: Destination.Temperature(summer: 28, winter: 12),
        currency: "EUR",
        language: "English",
        coordinates: Destination.Coordinates(latitude: 41.0082, longitude: 28.9784),
        address: "Preview Address, Preview City",
        popularPlaces: [
            PopularPlace(
                id: "preview-place-1",
                name: "Preview Place",
                type: "Attraction",
                coordinate: PopularPlace.Coordinates(latitude: 41.0082, longitude: 28.9784),
                rating: 4.5,
                imageURL: "https://picsum.photos/200/150",
                description: "A preview place for testing"
            )
        ]
    )
    
    static let mockUser = User(
        id: "preview-user",
        email: "preview@routa.app",
        displayName: "Preview User"
    )
}
