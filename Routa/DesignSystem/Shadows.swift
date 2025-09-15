import SwiftUI

// MARK: - Shadow System
struct RoutaShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
    
    init(
        color: Color = .black,
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat,
        opacity: Double = 0.15
    ) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
        self.opacity = opacity
    }
}

// MARK: - Elevation Levels
enum RoutaElevation: CaseIterable {
    case none
    case subtle
    case low
    case medium
    case high
    case floating
    case modal
    
    var shadow: RoutaShadow {
        switch self {
        case .none:
            return RoutaShadow(radius: 0, y: 0, opacity: 0)
        case .subtle:
            return RoutaShadow(radius: 2, y: 1, opacity: 0.08)
        case .low:
            return RoutaShadow(radius: 4, y: 2, opacity: 0.12)
        case .medium:
            return RoutaShadow(radius: 8, y: 4, opacity: 0.15)
        case .high:
            return RoutaShadow(radius: 16, y: 8, opacity: 0.18)
        case .floating:
            return RoutaShadow(radius: 24, y: 12, opacity: 0.20)
        case .modal:
            return RoutaShadow(radius: 32, y: 16, opacity: 0.25)
        }
    }
    
    var coloredShadow: RoutaShadow {
        let baseShadow = shadow
        return RoutaShadow(
            color: .routaPrimary,
            radius: baseShadow.radius,
            x: baseShadow.x,
            y: baseShadow.y,
            opacity: baseShadow.opacity * 0.6
        )
    }
    
    var warmShadow: RoutaShadow {
        let baseShadow = shadow
        return RoutaShadow(
            color: Color(red: 0.2, green: 0.1, blue: 0.05),
            radius: baseShadow.radius,
            x: baseShadow.x,
            y: baseShadow.y,
            opacity: baseShadow.opacity
        )
    }
    
    var coolShadow: RoutaShadow {
        let baseShadow = shadow
        return RoutaShadow(
            color: Color(red: 0.05, green: 0.1, blue: 0.2),
            radius: baseShadow.radius,
            x: baseShadow.x,
            y: baseShadow.y,
            opacity: baseShadow.opacity
        )
    }
}

// MARK: - Shadow Styles
enum RoutaShadowStyle {
    case standard
    case colored(Color)
    case warm
    case cool
    case neumorphic
    case glassmorphic
    case glow(Color)
    case custom(RoutaShadow)
    
    func shadow(for elevation: RoutaElevation) -> RoutaShadow {
        switch self {
        case .standard:
            return elevation.shadow
        case .colored(let color):
            let baseShadow = elevation.shadow
            return RoutaShadow(
                color: color,
                radius: baseShadow.radius,
                x: baseShadow.x,
                y: baseShadow.y,
                opacity: baseShadow.opacity * 0.6
            )
        case .warm:
            return elevation.warmShadow
        case .cool:
            return elevation.coolShadow
        case .neumorphic:
            return neumorphicShadow(for: elevation)
        case .glassmorphic:
            return glassmorphicShadow(for: elevation)
        case .glow(let color):
            return glowShadow(for: elevation, color: color)
        case .custom(let shadow):
            return shadow
        }
    }
    
    private func neumorphicShadow(for elevation: RoutaElevation) -> RoutaShadow {
        let baseShadow = elevation.shadow
        return RoutaShadow(
            color: .black,
            radius: baseShadow.radius * 0.5,
            x: baseShadow.x,
            y: baseShadow.y,
            opacity: baseShadow.opacity * 0.8
        )
    }
    
    private func glassmorphicShadow(for elevation: RoutaElevation) -> RoutaShadow {
        let baseShadow = elevation.shadow
        return RoutaShadow(
            color: .black,
            radius: baseShadow.radius * 1.5,
            x: baseShadow.x,
            y: baseShadow.y,
            opacity: baseShadow.opacity * 0.3
        )
    }
    
    private func glowShadow(for elevation: RoutaElevation, color: Color) -> RoutaShadow {
        let baseShadow = elevation.shadow
        return RoutaShadow(
            color: color,
            radius: baseShadow.radius * 2,
            x: 0,
            y: 0,
            opacity: baseShadow.opacity * 0.4
        )
    }
}

// MARK: - Dynamic Shadow Modifier
struct DynamicShadowModifier: ViewModifier {
    let elevation: RoutaElevation
    let style: RoutaShadowStyle
    let isPressed: Bool
    let isHovered: Bool
    
    private var currentShadow: RoutaShadow {
        let baseShadow = style.shadow(for: elevation)
        
        if isPressed {
            // Reduce shadow when pressed
            return RoutaShadow(
                color: baseShadow.color,
                radius: baseShadow.radius * 0.5,
                x: baseShadow.x * 0.5,
                y: baseShadow.y * 0.5,
                opacity: baseShadow.opacity * 0.7
            )
        } else if isHovered {
            // Increase shadow when hovered
            return RoutaShadow(
                color: baseShadow.color,
                radius: baseShadow.radius * 1.2,
                x: baseShadow.x * 1.1,
                y: baseShadow.y * 1.2,
                opacity: baseShadow.opacity * 1.1
            )
        } else {
            return baseShadow
        }
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: currentShadow.color.opacity(currentShadow.opacity),
                radius: currentShadow.radius,
                x: currentShadow.x,
                y: currentShadow.y
            )
    }
}

// MARK: - Multi-Layer Shadow Modifier
struct MultiLayerShadowModifier: ViewModifier {
    let shadows: [RoutaShadow]
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        shadows.reduce(AnyView(content)) { view, shadow in
            let adjustedShadow = isPressed ? adjustForPressed(shadow) : shadow
            return AnyView(view.shadow(
                color: adjustedShadow.color.opacity(adjustedShadow.opacity),
                radius: adjustedShadow.radius,
                x: adjustedShadow.x,
                y: adjustedShadow.y
            ))
        }
        .animation(.easeInOut(duration: 0.15), value: isPressed)
    }
    
    private func adjustForPressed(_ shadow: RoutaShadow) -> RoutaShadow {
        RoutaShadow(
            color: shadow.color,
            radius: shadow.radius * 0.6,
            x: shadow.x * 0.6,
            y: shadow.y * 0.6,
            opacity: shadow.opacity * 0.8
        )
    }
}

// MARK: - Neumorphic Shadow Modifier
struct NeumorphicShadowModifier: ViewModifier {
    let elevation: RoutaElevation
    let isPressed: Bool
    let backgroundColor: Color
    
    private var lightShadow: RoutaShadow {
        let baseShadow = elevation.shadow
        return RoutaShadow(
            color: .white,
            radius: baseShadow.radius * 0.8,
            x: isPressed ? -baseShadow.x * 0.3 : -baseShadow.x * 0.5,
            y: isPressed ? -baseShadow.y * 0.3 : -baseShadow.y * 0.5,
            opacity: isPressed ? 0.3 : 0.6
        )
    }
    
    private var darkShadow: RoutaShadow {
        let baseShadow = elevation.shadow
        return RoutaShadow(
            color: .black,
            radius: baseShadow.radius,
            x: isPressed ? baseShadow.x * 0.3 : baseShadow.x * 0.5,
            y: isPressed ? baseShadow.y * 0.3 : baseShadow.y * 0.5,
            opacity: isPressed ? baseShadow.opacity * 0.5 : baseShadow.opacity
        )
    }
    
    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .shadow(
                color: lightShadow.color.opacity(lightShadow.opacity),
                radius: lightShadow.radius,
                x: lightShadow.x,
                y: lightShadow.y
            )
            .shadow(
                color: darkShadow.color.opacity(darkShadow.opacity),
                radius: darkShadow.radius,
                x: darkShadow.x,
                y: darkShadow.y
            )
            .animation(.easeInOut(duration: 0.15), value: isPressed)
    }
}

// MARK: - Animated Glow Modifier
struct AnimatedGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let intensity: Double
    
    @State private var isGlowing = false
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(isGlowing ? intensity : intensity * 0.5),
                radius: isGlowing ? radius * 1.5 : radius,
                x: 0,
                y: 0
            )
            .animation(
                Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                value: isGlowing
            )
            .onAppear {
                isGlowing = true
            }
    }
}

// MARK: - Elevation Transition Modifier
struct ElevationTransitionModifier: ViewModifier {
    let fromElevation: RoutaElevation
    let toElevation: RoutaElevation
    let style: RoutaShadowStyle
    let isActive: Bool
    
    private var currentElevation: RoutaElevation {
        isActive ? toElevation : fromElevation
    }
    
    func body(content: Content) -> some View {
        content
            .modifier(DynamicShadowModifier(
                elevation: currentElevation,
                style: style,
                isPressed: false,
                isHovered: false
            ))
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isActive)
    }
}

// MARK: - View Extensions for Shadows
extension View {
    func routaShadow(
        _ elevation: RoutaElevation,
        style: RoutaShadowStyle = .standard,
        isPressed: Bool = false,
        isHovered: Bool = false
    ) -> some View {
        modifier(DynamicShadowModifier(
            elevation: elevation,
            style: style,
            isPressed: isPressed,
            isHovered: isHovered
        ))
    }
    
    func routaMultiShadow(_ shadows: [RoutaShadow], isPressed: Bool = false) -> some View {
        modifier(MultiLayerShadowModifier(shadows: shadows, isPressed: isPressed))
    }
    
    func routaNeumorphicShadow(
        _ elevation: RoutaElevation,
        isPressed: Bool = false,
        backgroundColor: Color = .routaSurface
    ) -> some View {
        modifier(NeumorphicShadowModifier(
            elevation: elevation,
            isPressed: isPressed,
            backgroundColor: backgroundColor
        ))
    }
    
    func routaGlow(
        color: Color = .routaPrimary,
        radius: CGFloat = 10,
        intensity: Double = 0.6
    ) -> some View {
        modifier(AnimatedGlowModifier(
            color: color,
            radius: radius,
            intensity: intensity
        ))
    }
    
    func routaElevationTransition(
        from: RoutaElevation,
        to: RoutaElevation,
        style: RoutaShadowStyle = .standard,
        isActive: Bool
    ) -> some View {
        modifier(ElevationTransitionModifier(
            fromElevation: from,
            toElevation: to,
            style: style,
            isActive: isActive
        ))
    }
}

// MARK: - Shadow Presets
struct RoutaShadowPresets {
    static let cardDefault = [
        RoutaShadow(radius: 4, y: 2, opacity: 0.08),
        RoutaShadow(radius: 12, y: 6, opacity: 0.12)
    ]
    
    static let cardHover = [
        RoutaShadow(radius: 8, y: 4, opacity: 0.12),
        RoutaShadow(radius: 20, y: 10, opacity: 0.15)
    ]
    
    static let buttonDefault = [
        RoutaShadow(radius: 2, y: 1, opacity: 0.1),
        RoutaShadow(radius: 6, y: 3, opacity: 0.08)
    ]
    
    static let floatingAction = [
        RoutaShadow(radius: 8, y: 4, opacity: 0.15),
        RoutaShadow(radius: 16, y: 8, opacity: 0.1),
        RoutaShadow(color: .routaPrimary, radius: 20, y: 10, opacity: 0.2)
    ]
    
    static let modal = [
        RoutaShadow(radius: 16, y: 8, opacity: 0.15),
        RoutaShadow(radius: 32, y: 16, opacity: 0.1),
        RoutaShadow(radius: 64, y: 32, opacity: 0.05)
    ]
    
    static let neumorphicPressed = [
        RoutaShadow(color: .white, radius: 4, x: -2, y: -2, opacity: 0.6),
        RoutaShadow(color: .black, radius: 4, x: 2, y: 2, opacity: 0.15)
    ]
    
    static let neumorphicRaised = [
        RoutaShadow(color: .white, radius: 8, x: -4, y: -4, opacity: 0.6),
        RoutaShadow(color: .black, radius: 8, x: 4, y: 4, opacity: 0.15)
    ]
}

// MARK: - Interactive Shadow Card
struct InteractiveShadowCard<Content: View>: View {
    let content: Content
    let baseElevation: RoutaElevation
    let hoverElevation: RoutaElevation
    let pressedElevation: RoutaElevation
    let style: RoutaShadowStyle
    let cornerRadius: CGFloat
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    init(
        baseElevation: RoutaElevation = .low,
        hoverElevation: RoutaElevation = .medium,
        pressedElevation: RoutaElevation = .subtle,
        style: RoutaShadowStyle = .standard,
        cornerRadius: CGFloat = 12,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.baseElevation = baseElevation
        self.hoverElevation = hoverElevation
        self.pressedElevation = pressedElevation
        self.style = style
        self.cornerRadius = cornerRadius
    }
    
    var currentElevation: RoutaElevation {
        if isPressed {
            return pressedElevation
        } else if isHovered {
            return hoverElevation
        } else {
            return baseElevation
        }
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.routaCard)
            )
            .routaShadow(currentElevation, style: style)
            .scaleEffect(isPressed ? 0.98 : (isHovered ? 1.02 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentElevation)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isHovered)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
            .onHover { hovering in
                isHovered = hovering
            }
    }
}