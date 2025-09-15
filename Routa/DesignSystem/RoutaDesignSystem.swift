import SwiftUI

// MARK: - Routa Design System
/*
 * Comprehensive Modern Design System for Routa App
 * 
 * Features:
 * • Custom color palette with gradients
 * • Modern typography with custom font weights
 * • Neumorphic/Glassmorphic card designs
 * • Smooth spring animations
 * • Custom floating tab bar
 * • Micro-interactions on all buttons
 * • Haptic feedback integration
 * • Dynamic shadows and elevation system
 * 
 * Usage:
 * Import this file to access all design system components.
 * Use the DesignSystemShowcase view to see all components in action.
 */

// MARK: - Design System Version
struct RoutaDesignSystemInfo {
    static let version = "1.0.0"
    static let name = "Routa Design System"
    static let description = "A comprehensive modern design system for the Routa travel app"
}

// MARK: - Spacing System
struct RoutaSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

// MARK: - Design System Configuration
struct RoutaDesignSystemConfiguration {
    static var isHapticsEnabled: Bool {
        get { RoutaHapticsManager.shared.isHapticsEnabled }
        set { RoutaHapticsManager.shared.isHapticsEnabled = newValue }
    }
    
    static func setupDesignSystem() {
        // Initialize haptics
        let _ = RoutaHapticsManager.shared
        
        // Set default animations
        UIView.animate(withDuration: 0.3) {
            // Configure default animation duration
        }
    }
}

// MARK: - Quick Access Extensions
extension View {
    // MARK: - Quick Styling
    func routaCardStyle(
        _ style: RoutaCard<EmptyView>.CardStyle = .standard,
        elevation: RoutaCardElevation = .medium
    ) -> some View {
        self.padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.routaCard)
            )
            .routaShadow(
                elevation == .flat ? .none :
                elevation == .low ? .low :
                elevation == .medium ? .medium :
                elevation == .high ? .high : .floating
            )
    }
    
    func routaButton(
        variant: RoutaButtonVariant = .primary,
        size: RoutaButtonSize = .medium,
        haptic: RoutaHapticType = .buttonTap
    ) -> some View {
        self.onTapHaptic(haptic) {}
            .foregroundColor(variant.foregroundColor())
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: size.height / 2)
                    .fill(variant.backgroundColor())
            )
    }
    
    // MARK: - Animation Shortcuts
    func routaSpringAnimation(
        _ type: RoutaAnimationType = .smooth
    ) -> some View {
        self.animation(type.animation, value: UUID())
    }
    
    // MARK: - Haptic Shortcuts
    func withHaptic(_ type: RoutaHapticType = .buttonTap) -> some View {
        self.onAppear {
            type.trigger()
        }
    }
}

// MARK: - Animation Types
enum RoutaAnimationType {
    case quick
    case smooth
    case bounce
    case gentle
    
    var animation: Animation {
        switch self {
        case .quick: return RoutaAnimations.quickSpring
        case .smooth: return RoutaAnimations.smoothSpring
        case .bounce: return RoutaAnimations.bounceSpring
        case .gentle: return RoutaAnimations.gentleSpring
        }
    }
}

// MARK: - Theme Manager
class RoutaThemeManager: ObservableObject {
    static let shared = RoutaThemeManager()
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet {
            currentColorScheme = RoutaColorScheme(isDarkMode: isDarkMode)
        }
    }
    
    @Published var accentColor: Color = .routaPrimary
    @Published var currentColorScheme: RoutaColorScheme
    
    private init() {
        self.currentColorScheme = RoutaColorScheme(isDarkMode: false)
        self.currentColorScheme = RoutaColorScheme(isDarkMode: self.isDarkMode)
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    func setAccentColor(_ color: Color) {
        accentColor = color
    }
}

// MARK: - Component Library
struct RoutaComponentLibrary {
    
    // MARK: - Common Card Configurations
    static func infoCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        RoutaCard(style: .standard, elevation: .low) {
            content()
        }
    }
    
    static func featureCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        RoutaCard(style: .glassmorphic, elevation: .medium) {
            content()
        }
    }
    
    static func heroCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        RoutaCard(style: .gradient, elevation: .high) {
            content()
        }
    }
    
    // MARK: - Common Button Configurations
    static func primaryActionButton(
        _ title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        RoutaButton(title, icon: icon, variant: .primary, size: .large, action: action)
    }
    
    static func secondaryActionButton(
        _ title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        RoutaButton(title, icon: icon, variant: .outline, size: .medium, action: action)
    }
    
    // MARK: - Common Layout Helpers
    static func sectionHeader(_ title: String) -> some View {
        Text(title)
            .routaTitle2()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
    }
    
    static func sectionContent<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.routaSurface)
        )
    }
}

// MARK: - Environment Keys
struct RoutaThemeKey: EnvironmentKey {
    static let defaultValue = RoutaThemeManager.shared
}

extension EnvironmentValues {
    var routaTheme: RoutaThemeManager {
        get { self[RoutaThemeKey.self] }
        set { self[RoutaThemeKey.self] = newValue }
    }
}

// MARK: - Design System App Modifier
struct RoutaDesignSystemModifier: ViewModifier {
    @ObservedObject private var theme = RoutaThemeManager.shared
    @ObservedObject private var haptics = RoutaHapticsManager.shared
    
    func body(content: Content) -> some View {
        content
            .environment(\.routaTheme, theme)
            .environment(\.haptics, haptics)
            .preferredColorScheme(theme.isDarkMode ? .dark : .light)
            .accentColor(theme.accentColor)
            .onAppear {
                RoutaDesignSystemConfiguration.setupDesignSystem()
            }
    }
}

extension View {
    func routaDesignSystem() -> some View {
        modifier(RoutaDesignSystemModifier())
    }
}

// MARK: - Usage Examples and Documentation
/*
 USAGE EXAMPLES:

 1. Basic Card:
 RoutaCard(style: .standard, elevation: .medium) {
     VStack {
         Text("Title").routaHeadline()
         Text("Description").routaBody()
     }
 }

 2. Button with Haptic:
 RoutaButton("Click Me", variant: .primary) {
     // Action
 }

 3. Floating Tab Bar:
 RoutaFloatingTabBar(
     items: tabItems,
     selectedTab: $selectedTab,
     style: .withCenter,
     centerAction: { /* Center action */ }
 )

 4. Typography:
 Text("Hero Title").routaHeroTitle()
 Text("Body text").routaBody()

 5. Shadows:
 someView.routaShadow(.medium, style: .colored(.blue))

 6. Animations:
 someView
     .routaPulse()
     .routaFloat()
     .routaGlow()

 7. Haptics:
 Button("Tap") {
     RoutaHapticType.buttonTap.trigger()
 }

 8. Complete App Setup:
 @main
 struct RoutaApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
                 .routaDesignSystem()
         }
     }
 }
 */