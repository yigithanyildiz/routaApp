import SwiftUI
import UIKit

// MARK: - Layout Constants for Consistent UI Spacing
struct LayoutConstants {

    // MARK: - SafeArea Constants

    /// Standard tab bar height with safe area considerations
    static let tabBarHeight: CGFloat = 90

    /// Standard navigation bar height
    static let navigationBarHeight: CGFloat = 44

    /// Additional padding for Dynamic Island interference
    static let dynamicIslandPadding: CGFloat = 15

    /// Standard status bar height for legacy devices
    static let statusBarHeight: CGFloat = 20

    // MARK: - Standard Padding Values

    /// Extra small padding (4pt)
    static let paddingXS: CGFloat = 4

    /// Small padding (8pt)
    static let paddingSM: CGFloat = 8

    /// Medium padding (12pt)
    static let paddingMD: CGFloat = 12

    /// Large padding (16pt)
    static let paddingLG: CGFloat = 16

    /// Extra large padding (20pt)
    static let paddingXL: CGFloat = 20

    /// Double extra large padding (24pt)
    static let paddingXXL: CGFloat = 24

    // MARK: - Card and Component Spacing

    /// Standard card corner radius
    static let cardCornerRadius: CGFloat = 16

    /// Small card corner radius
    static let cardCornerRadiusSmall: CGFloat = 12

    /// Large card corner radius
    static let cardCornerRadiusLarge: CGFloat = 20

    /// Button corner radius
    static let buttonCornerRadius: CGFloat = 12

    /// Standard button height
    static let buttonHeight: CGFloat = 50

    /// Large button height
    static let buttonHeightLarge: CGFloat = 56

    // MARK: - Animation Durations

    /// Quick animation duration
    static let animationQuick: Double = 0.2

    /// Standard animation duration
    static let animationStandard: Double = 0.3

    /// Slow animation duration
    static let animationSlow: Double = 0.5

    // MARK: - Shadow Values

    /// Light shadow radius
    static let shadowRadiusLight: CGFloat = 2

    /// Medium shadow radius
    static let shadowRadiusMedium: CGFloat = 4

    /// Heavy shadow radius
    static let shadowRadiusHeavy: CGFloat = 8

    /// Shadow offset Y
    static let shadowOffsetY: CGFloat = 2

    /// Shadow opacity
    static let shadowOpacity: Double = 0.1

    // MARK: - Device-Specific Calculations

    /// Get safe tab bar height for current device
    static var safeTabBarHeight: CGFloat {
        return tabBarHeight + UIDevice.safeAreaInsets.bottom
    }

    /// Get total navigation area height (status bar + nav bar)
    static var totalNavigationHeight: CGFloat {
        return UIDevice.safeAreaInsets.top + navigationBarHeight
    }

    /// Get content area height (excluding navigation and tab bar)
    static var contentAreaHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight - totalNavigationHeight - safeTabBarHeight
    }

    /// Get appropriate top padding for hero content
    static var heroContentTopPadding: CGFloat {
        switch UIDevice.deviceType {
        case .dynamicIsland:
            return UIDevice.safeAreaInsets.top + dynamicIslandPadding
        case .notch:
            return UIDevice.safeAreaInsets.top + paddingSM
        case .legacy:
            return UIDevice.safeAreaInsets.top
        }
    }
}

// MARK: - View Extension for Layout Constants
extension View {
    /// Apply standard card styling
    func standardCard() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(LayoutConstants.cardCornerRadius)
            .shadow(
                color: .black.opacity(LayoutConstants.shadowOpacity),
                radius: LayoutConstants.shadowRadiusMedium,
                x: 0,
                y: LayoutConstants.shadowOffsetY
            )
    }

    /// Apply standard button styling
    func standardButton() -> some View {
        self
            .frame(height: LayoutConstants.buttonHeight)
            .cornerRadius(LayoutConstants.buttonCornerRadius)
    }

    /// Apply safe area bottom padding for tab bar
    func tabBarSafePadding() -> some View {
        self.padding(.bottom, LayoutConstants.tabBarHeight)
    }

    /// Apply safe area top padding for navigation
    func navigationSafePadding() -> some View {
        self.padding(.top, LayoutConstants.totalNavigationHeight)
    }
}

// MARK: - Spacing Shortcuts
extension LayoutConstants {
    /// Quick access to common spacing values
    enum Spacing {
        static let xs = LayoutConstants.paddingXS
        static let sm = LayoutConstants.paddingSM
        static let md = LayoutConstants.paddingMD
        static let lg = LayoutConstants.paddingLG
        static let xl = LayoutConstants.paddingXL
        static let xxl = LayoutConstants.paddingXXL
    }

    /// Quick access to corner radius values
    enum CornerRadius {
        static let small = LayoutConstants.cardCornerRadiusSmall
        static let standard = LayoutConstants.cardCornerRadius
        static let large = LayoutConstants.cardCornerRadiusLarge
        static let button = LayoutConstants.buttonCornerRadius
    }

    /// Quick access to animation durations
    enum Animation {
        static let quick = LayoutConstants.animationQuick
        static let standard = LayoutConstants.animationStandard
        static let slow = LayoutConstants.animationSlow
    }
}