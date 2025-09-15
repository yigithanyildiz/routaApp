import SwiftUI

struct FavoriteButton: View {
    let destinationId: String
    let size: Size
    @EnvironmentObject var authManager: AuthManager
    @State private var showLoginPrompt = false
    @State private var isAnimating = false
    
    enum Size {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
        
        var buttonSize: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 40
            case .large: return 48
            }
        }
        
        var animationScale: CGFloat {
            switch self {
            case .small: return 1.2
            case .medium: return 1.3
            case .large: return 1.4
            }
        }
    }
    
    init(destinationId: String, size: Size = .medium) {
        self.destinationId = destinationId
        self.size = size
    }
    
    private var isFavorite: Bool {
        // Only return true if user is authenticated and destination is favorited
        guard authManager.isAuthenticated else { return false }
        return authManager.favoritesManager.isFavorite(destinationId: destinationId)
    }
    
    private var isLoading: Bool {
        authManager.favoritesManager.isLoading
    }
    
    var body: some View {
        Button(action: handleTap) {
            ZStack {
                // Background circle
                Circle()
                    .fill(isFavorite ? 
                          LinearGradient(
                            colors: [Color.routaPrimary, Color.routaSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ) : 
                          LinearGradient(
                            colors: [Color.routaSurface, Color.routaSurface],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                    )
                    .frame(width: size.buttonSize, height: size.buttonSize)
                    .routaShadow(.medium)
                    .overlay(
                        Circle()
                            .stroke(
                                isFavorite ? Color.clear : Color.routaBorder.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                
                // Heart icon or loading indicator
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(
                                tint: isFavorite ? .white : .routaPrimary
                            ))
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: size.iconSize, weight: .medium))
                            .foregroundColor(isFavorite ? .white : .routaTextSecondary)
                            .scaleEffect(isAnimating ? size.animationScale : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                    }
                }
            }
        }
        .disabled(isLoading)
        .scaleEffect(isAnimating ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isAnimating)
        .sheet(isPresented: $showLoginPrompt) {
            LoginPromptSheet.favoritePrompt()
                .environmentObject(authManager)
        }
        .onChange(of: isFavorite) { _, newValue in
            // Trigger animation when favorite status changes
            if !isLoading {
                triggerAnimation()
            }
        }
    }
    
    private func handleTap() {
        // Check if user is authenticated
        guard authManager.isAuthenticated else {
            RoutaHapticsManager.shared.buttonTap()
            showLoginPrompt = true
            return
        }
        
        // Trigger immediate animation for responsiveness
        triggerAnimation()
        
        // Toggle favorite status
        Task {
            await authManager.favoritesManager.toggleFavorite(destinationId: destinationId)
        }
    }
    
    private func triggerAnimation() {
        withAnimation(.easeInOut(duration: 0.1)) {
            isAnimating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isAnimating = false
            }
        }
    }
}

// MARK: - Toolbar Favorite Button

struct ToolbarFavoriteButton: View {
    let destinationId: String
    @EnvironmentObject var authManager: AuthManager
    @State private var showLoginPrompt = false
    
    private var isFavorite: Bool {
        // Only return true if user is authenticated and destination is favorited
        guard authManager.isAuthenticated else { return false }
        return authManager.favoritesManager.isFavorite(destinationId: destinationId)
    }
    
    private var isLoading: Bool {
        authManager.favoritesManager.isLoading
    }
    
    var body: some View {
        Button(action: handleTap) {
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .routaPrimary))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isFavorite ? .routaError : .routaPrimary)
                }
            }
        }
        .disabled(isLoading)
        .sheet(isPresented: $showLoginPrompt) {
            LoginPromptSheet.favoritePrompt()
                .environmentObject(authManager)
        }
    }
    
    private func handleTap() {
        guard authManager.isAuthenticated else {
            RoutaHapticsManager.shared.buttonTap()
            showLoginPrompt = true
            return
        }
        
        Task {
            await authManager.favoritesManager.toggleFavorite(destinationId: destinationId)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            FavoriteButton(destinationId: "test1", size: .small)
            FavoriteButton(destinationId: "test2", size: .medium)
            FavoriteButton(destinationId: "test3", size: .large)
        }
        
        ToolbarFavoriteButton(destinationId: "test4")
    }
    .padding()
    .background(Color.routaBackground)
    .previewEnvironment(authenticated: true)
}