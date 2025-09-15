import SwiftUI

// MARK: - App Theme
struct RoutaTheme {
    // MARK: - Colors
    static let primaryColor = Color(red: 0.0, green: 0.478, blue: 1.0) // Canlı mavi
    static let secondaryColor = Color(red: 1.0, green: 0.584, blue: 0.0) // Turuncu
    static let backgroundColor = Color(.systemBackground)
    static let cardBackground = Color(.systemGray6)
    
    // Gradient colors
    static let gradientStart = Color(red: 0.0, green: 0.478, blue: 1.0)
    static let gradientEnd = Color(red: 0.0, green: 0.3, blue: 0.8)
    
    // Budget type colors
    static let budgetColor = Color(red: 0.2, green: 0.8, blue: 0.4) // Yeşil
    static let standardColor = Color(red: 0.0, green: 0.478, blue: 1.0) // Mavi
    static let luxuryColor = Color(red: 0.8, green: 0.6, blue: 0.2) // Altın
    
    // MARK: - Spacing
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    
    // MARK: - Corner Radius
    static let smallRadius: CGFloat = 8
    static let mediumRadius: CGFloat = 12
    static let largeRadius: CGFloat = 20
    
    // MARK: - Shadow
    static let defaultShadow = Color.black.opacity(0.1)
    static let shadowRadius: CGFloat = 10
    
    // MARK: - Animation
    static let defaultAnimation = Animation.spring(response: 0.3, dampingFraction: 0.8)
}

// MARK: - Custom View Modifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(RoutaTheme.cardBackground)
            .cornerRadius(RoutaTheme.mediumRadius)
            .shadow(color: RoutaTheme.defaultShadow, radius: 5, x: 0, y: 2)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [RoutaTheme.gradientStart, RoutaTheme.gradientEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(RoutaTheme.mediumRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func primaryButton() -> some View {
        buttonStyle(PrimaryButtonStyle())
    }
}
