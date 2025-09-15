import SwiftUI

// MARK: - Routa Animation System
struct RoutaAnimations {
    
    // MARK: - Spring Animations
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let smoothSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let bounceSpring = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let gentleSpring = Animation.spring(response: 0.6, dampingFraction: 0.9)
    
    // MARK: - Easing Animations
    static let quickEase = Animation.easeInOut(duration: 0.2)
    static let smoothEase = Animation.easeInOut(duration: 0.3)
    static let slowEase = Animation.easeInOut(duration: 0.5)
    
    // MARK: - Micro-interaction Animations
    static let buttonPress = Animation.easeInOut(duration: 0.1)
    static let buttonRelease = Animation.easeOut(duration: 0.2)
    static let hover = Animation.easeInOut(duration: 0.15)
    
    // MARK: - Transition Animations
    static let slideIn = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let fadeIn = Animation.easeIn(duration: 0.3)
    static let scaleIn = Animation.spring(response: 0.3, dampingFraction: 0.6)
    
    // MARK: - Complex Animations
    static let cardFlip = Animation.spring(response: 0.6, dampingFraction: 0.7)
    static let morphing = Animation.spring(response: 0.8, dampingFraction: 0.8)
    static let elastic = Animation.spring(response: 0.7, dampingFraction: 0.5)
}

// MARK: - Custom Animation Curves
struct RoutaAnimationCurves {
    static let smooth = UnitCurve.easeInOut
    static let quick = UnitCurve.easeOut
    static let bounce = UnitCurve.easeInOut // Custom bounce would require more complex implementation
    static let gentle = UnitCurve.easeIn
}

// MARK: - Animated Modifiers
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    let minScale: CGFloat
    let maxScale: CGFloat
    let duration: TimeInterval
    
    init(minScale: CGFloat = 0.95, maxScale: CGFloat = 1.05, duration: TimeInterval = 1.0) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? maxScale : minScale)
            .animation(
                Animation.easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

struct FloatingEffect: ViewModifier {
    @State private var isFloating = false
    let amplitude: CGFloat
    let duration: TimeInterval
    
    init(amplitude: CGFloat = 10, duration: TimeInterval = 2.0) {
        self.amplitude = amplitude
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -amplitude : amplitude)
            .animation(
                Animation.easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear {
                isFloating = true
            }
    }
}

struct GlowEffect: ViewModifier {
    @State private var isGlowing = false
    let color: Color
    let radius: CGFloat
    
    init(color: Color = .routaPrimary, radius: CGFloat = 10) {
        self.color = color
        self.radius = radius
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                content
                    .blur(radius: radius)
                    .opacity(isGlowing ? 0.8 : 0.3)
            )
            .animation(
                Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isGlowing
            )
            .onAppear {
                isGlowing = true
            }
    }
}

struct RotatingGradientEffect: ViewModifier {
    @State private var rotation: Double = 0
    let duration: TimeInterval
    
    init(duration: TimeInterval = 3.0) {
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                AngularGradient(
                    colors: [
                        .routaPrimary,
                        .routaSecondary,
                        .routaAccent,
                        .routaPrimary
                    ],
                    center: .center,
                    angle: .degrees(rotation)
                )
                .blur(radius: 20)
                .opacity(0.3)
            )
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Transition Extensions
extension AnyTransition {
    static let routaSlideIn = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )
    
    static let routaScale = AnyTransition.scale(scale: 0.8).combined(with: .opacity)
    
    static let routaFlip = AnyTransition.asymmetric(
        insertion: .scale(scale: 0.1).combined(with: .opacity),
        removal: .scale(scale: 0.1).combined(with: .opacity)
    )
    
    static func routaSlide(edge: Edge) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: edge).combined(with: .opacity),
            removal: .move(edge: edge.opposite).combined(with: .opacity)
        )
    }
}

extension Edge {
    var opposite: Edge {
        switch self {
        case .top: return .bottom
        case .bottom: return .top
        case .leading: return .trailing
        case .trailing: return .leading
        }
    }
}

// MARK: - Animated Button Styles
struct RoutaButtonStyle: ButtonStyle {
    let style: ButtonStyleType
    
    enum ButtonStyleType {
        case primary
        case secondary
        case ghost
        case destructive
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(
                        color: shadowColor,
                        radius: configuration.isPressed ? 4 : 8,
                        x: 0,
                        y: configuration.isPressed ? 2 : 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(RoutaAnimations.quickSpring, value: configuration.isPressed)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return .routaPrimary
        case .secondary: return .routaSecondary
        case .ghost: return .clear
        case .destructive: return .routaError
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .secondary, .destructive: return .white
        case .ghost: return .routaPrimary
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary: return .routaPrimary.opacity(0.3)
        case .secondary: return .routaSecondary.opacity(0.3)
        case .ghost: return .clear
        case .destructive: return .routaError.opacity(0.3)
        }
    }
}

// MARK: - View Extensions for Animations
extension View {
    func routaShake(amount: CGFloat = 10) -> some View {
        modifier(ShakeEffect(amount: amount, animatableData: 1))
    }
    
    func routaPulse(minScale: CGFloat = 0.95, maxScale: CGFloat = 1.05, duration: TimeInterval = 1.0) -> some View {
        modifier(PulseEffect(minScale: minScale, maxScale: maxScale, duration: duration))
    }
    
    func routaFloat(amplitude: CGFloat = 10, duration: TimeInterval = 2.0) -> some View {
        modifier(FloatingEffect(amplitude: amplitude, duration: duration))
    }
    
    func routaGlow(color: Color = .routaPrimary, radius: CGFloat = 10) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
    
    func routaRotatingGradient(duration: TimeInterval = 3.0) -> some View {
        modifier(RotatingGradientEffect(duration: duration))
    }
    
    func routaButtonStyle(_ style: RoutaButtonStyle.ButtonStyleType) -> some View {
        buttonStyle(RoutaButtonStyle(style: style))
    }
}

// MARK: - Animated Number Counter
struct AnimatedNumber: View {
    let value: Double
    let format: String
    @State private var displayValue: Double = 0
    
    init(value: Double, format: String = "%.0f") {
        self.value = value
        self.format = format
    }
    
    var body: some View {
        Text(String(format: format, displayValue))
            .onAppear {
                animateToValue()
            }
            .onChange(of: value) { _, newValue in
                animateToValue()
            }
    }
    
    private func animateToValue() {
        withAnimation(.easeOut(duration: 1.0)) {
            displayValue = value
        }
    }
}

// MARK: - Loading Animation
struct RoutaLoadingView: View {
    @State private var isAnimating = false
    let size: CGFloat
    
    init(size: CGFloat = 40) {
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(RoutaGradients.primaryGradient)
                    .frame(width: size / 4, height: size / 4)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}