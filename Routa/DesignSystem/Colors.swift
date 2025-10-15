import SwiftUI

// MARK: - Routa Design System Colors
extension Color {
    
    // MARK: - Primary Colors (Adaptive)
    static let routaPrimary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ?
        UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0) :
        UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
    })
    static let routaPrimaryDark = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ?
        UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0) :
        UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1.0)
    })
    static let routaPrimaryLight = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ?
        UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0) :
        UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
    })
    
    // MARK: - Secondary Colors (Adaptive)
    static let routaSecondary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ?
        UIColor(red: 0.8, green: 0.5, blue: 0.95, alpha: 1.0) :
        UIColor(red: 0.7, green: 0.3, blue: 0.9, alpha: 1.0)
    })
    static let routaSecondaryDark = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ?
        UIColor(red: 0.6, green: 0.3, blue: 0.8, alpha: 1.0) :
        UIColor(red: 0.5, green: 0.2, blue: 0.7, alpha: 1.0)
    })
    static let routaSecondaryLight = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ?
        UIColor(red: 0.9, green: 0.6, blue: 1.0, alpha: 1.0) :
        UIColor(red: 0.8, green: 0.5, blue: 0.95, alpha: 1.0)
    })
    
    // MARK: - Accent Colors (Adaptive)
    static let routaAccent = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ?
        UIColor(red: 1.0, green: 0.6, blue: 0.5, alpha: 1.0) :
        UIColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 1.0)
    })
    static let routaAccentDark = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ?
        UIColor(red: 0.9, green: 0.4, blue: 0.3, alpha: 1.0) :
        UIColor(red: 0.8, green: 0.2, blue: 0.1, alpha: 1.0)
    })
    static let routaAccentLight = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ?
        UIColor(red: 1.0, green: 0.7, blue: 0.6, alpha: 1.0) :
        UIColor(red: 1.0, green: 0.6, blue: 0.5, alpha: 1.0)
    })
    
    // MARK: - Neutral Colors (Adaptive)
    static let routaBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ?
        UIColor(red: 0.04, green: 0.1, blue: 0.16, alpha: 1.0) :
        UIColor.systemBackground
    })
    static let routaSurface = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ?
        UIColor(red: 0.08, green: 0.13, blue: 0.21, alpha: 1.0) :
        UIColor.secondarySystemBackground
    })
    static let routaCard = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ?
        UIColor(red: 0.1, green: 0.16, blue: 0.26, alpha: 1.0) :
        UIColor.tertiarySystemBackground
    })
    static let routaText = Color(UIColor.label)
    static let routaTextSecondary = Color(UIColor.secondaryLabel)
    static let routaBorder = Color(UIColor.separator)
    
    // MARK: - Status Colors
    static let routaSuccess = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let routaWarning = Color(red: 1.0, green: 0.7, blue: 0.2)
    static let routaError = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let routaInfo = Color(red: 0.3, green: 0.7, blue: 1.0)
}

// MARK: - Gradient System
struct RoutaGradients {
    
    // MARK: - Primary Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color.routaPrimary, Color.routaPrimaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let primaryRadialGradient = RadialGradient(
        colors: [Color.routaPrimaryLight, Color.routaPrimary, Color.routaPrimaryDark],
        center: .center,
        startRadius: 0,
        endRadius: 100
    )
    
    // MARK: - Secondary Gradients
    static let secondaryGradient = LinearGradient(
        colors: [Color.routaSecondary, Color.routaSecondaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Accent Gradients
    static let accentGradient = LinearGradient(
        colors: [Color.routaAccent, Color.routaAccentDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Status Gradients
    static let successGradient = LinearGradient(
        colors: [Color.routaSuccess, Color.routaSuccess.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warningGradient = LinearGradient(
        colors: [Color.routaWarning, Color.routaWarning.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let errorGradient = LinearGradient(
        colors: [Color.routaError, Color.routaError.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Special Gradients
    static let heroGradient = LinearGradient(
        colors: [
            Color.routaPrimary.opacity(0.8),
            Color.routaSecondary.opacity(0.6),
            Color.routaAccent.opacity(0.4)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassmorphicGradient = LinearGradient(
        colors: [
            Color.routaBackground.opacity(0.25),
            Color.routaBackground.opacity(0.1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let neumorphicGradient = LinearGradient(
        colors: [
            Color.routaSurface,
            Color.routaBackground
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Dark Background Gradient
    static let darkBackgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.04, green: 0.1, blue: 0.16),
            Color(red: 0.08, green: 0.13, blue: 0.21),
            Color(red: 0.1, green: 0.16, blue: 0.26)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Shadow Gradients
    static let shadowGradient = RadialGradient(
        colors: [
            Color(red: 0.04, green: 0.1, blue: 0.16).opacity(0.15),
            Color(red: 0.04, green: 0.1, blue: 0.16).opacity(0.05),
            Color.clear
        ],
        center: .center,
        startRadius: 0,
        endRadius: 50
    )
    
    // MARK: - Animated Gradients
    static func animatedGradient(offset: CGFloat) -> LinearGradient {
        return LinearGradient(
            colors: [
                Color.routaPrimary,
                Color.routaSecondary,
                Color.routaAccent,
                Color.routaPrimary
            ],
            startPoint: UnitPoint(x: offset, y: 0),
            endPoint: UnitPoint(x: offset + 1, y: 1)
        )
    }
}

// MARK: - Dynamic Color System
struct RoutaColorScheme {
    let isDarkMode: Bool
    
    var primaryColor: Color {
        isDarkMode ? Color.routaPrimaryLight : Color.routaPrimary
    }
    
    var backgroundColor: Color {
        isDarkMode ? Color(red: 0.04, green: 0.1, blue: 0.16) : Color.routaBackground
    }
    
    var surfaceColor: Color {
        isDarkMode ? Color(red: 0.08, green: 0.13, blue: 0.21) : Color.routaSurface
    }
    
    var cardColor: Color {
        isDarkMode ? Color(red: 0.1, green: 0.16, blue: 0.26) : Color.routaCard
    }
    
    var textColor: Color {
        isDarkMode ? Color.white : Color.routaText
    }
    
    var textSecondaryColor: Color {
        isDarkMode ? Color.gray : Color.routaTextSecondary
    }
}