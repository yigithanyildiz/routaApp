import SwiftUI

// MARK: - Card Elevation System
enum RoutaCardElevation: CaseIterable {
    case flat
    case low
    case medium
    case high
    case floating
    
    var shadowRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 4
        case .medium: return 8
        case .high: return 16
        case .floating: return 24
        }
    }
    
    var shadowOffset: CGSize {
        switch self {
        case .flat: return .zero
        case .low: return CGSize(width: 0, height: 2)
        case .medium: return CGSize(width: 0, height: 4)
        case .high: return CGSize(width: 0, height: 8)
        case .floating: return CGSize(width: 0, height: 12)
        }
    }
    
    var shadowOpacity: Double {
        switch self {
        case .flat: return 0
        case .low: return 0.1
        case .medium: return 0.15
        case .high: return 0.2
        case .floating: return 0.25
        }
    }
}

// MARK: - Neumorphic Card
struct NeumorphicCard<Content: View>: View {
    let content: Content
    let elevation: RoutaCardElevation
    let cornerRadius: CGFloat
    let isPressed: Bool
    
    init(
        elevation: RoutaCardElevation = .medium,
        cornerRadius: CGFloat = 16,
        isPressed: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.elevation = elevation
        self.cornerRadius = cornerRadius
        self.isPressed = isPressed
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.routaSurface)
                    .shadow(
                        color: Color.black.opacity(isPressed ? 0.05 : elevation.shadowOpacity),
                        radius: isPressed ? elevation.shadowRadius / 2 : elevation.shadowRadius,
                        x: isPressed ? elevation.shadowOffset.width / 2 : elevation.shadowOffset.width,
                        y: isPressed ? elevation.shadowOffset.height / 2 : elevation.shadowOffset.height
                    )
                    .shadow(
                        color: Color.white.opacity(isPressed ? 0.3 : 0.6),
                        radius: isPressed ? elevation.shadowRadius / 3 : elevation.shadowRadius / 2,
                        x: isPressed ? -elevation.shadowOffset.width / 3 : -elevation.shadowOffset.width / 2,
                        y: isPressed ? -elevation.shadowOffset.height / 3 : -elevation.shadowOffset.height / 2
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
    }
}

// MARK: - Glassmorphic Card
struct GlassmorphicCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let blurRadius: CGFloat
    
    init(
        cornerRadius: CGFloat = 20,
        borderWidth: CGFloat = 1,
        blurRadius: CGFloat = 10,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.blurRadius = blurRadius
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(RoutaGradients.glassmorphicGradient)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: borderWidth
                            )
                    )
            )
    }
}

// MARK: - Modern Card with Dynamic Elevation
struct RoutaCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    let elevation: RoutaCardElevation
    let cornerRadius: CGFloat
    let padding: EdgeInsets
    @State private var isPressed = false
    
    enum CardStyle {
        case neumorphic
        case glassmorphic
        case standard
        case gradient
    }
    
    init(
        style: CardStyle = .standard,
        elevation: RoutaCardElevation = .medium,
        cornerRadius: CGFloat = 16,
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.style = style
        self.elevation = elevation
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    var body: some View {
        Group {
            switch style {
            case .neumorphic:
                NeumorphicCard(elevation: elevation, cornerRadius: cornerRadius, isPressed: isPressed) {
                    content
                        .padding(padding)
                }
                
            case .glassmorphic:
                GlassmorphicCard(cornerRadius: cornerRadius) {
                    content
                        .padding(padding)
                }
                
            case .standard:
                content
                    .padding(padding)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.routaCard)
                            .shadow(
                                color: Color.black.opacity(elevation.shadowOpacity),
                                radius: elevation.shadowRadius,
                                x: elevation.shadowOffset.width,
                                y: elevation.shadowOffset.height
                            )
                    )
                    .scaleEffect(isPressed ? 0.98 : 1.0)
                    
            case .gradient:
                content
                    .padding(padding)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(RoutaGradients.primaryGradient)
                            .shadow(
                                color: Color.routaPrimary.opacity(0.3),
                                radius: elevation.shadowRadius,
                                x: elevation.shadowOffset.width,
                                y: elevation.shadowOffset.height
                            )
                    )
                    .scaleEffect(isPressed ? 0.98 : 1.0)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
      /* .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        } */
    }
}

// MARK: - Floating Action Card
struct FloatingActionCard<Content: View>: View {
    let content: Content
    let size: CGFloat
    let action: () -> Void
    @State private var isPressed = false
    @State private var isHovered = false
    
    init(
        size: CGFloat = 56,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            content
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(RoutaGradients.primaryGradient)
                        .shadow(
                            color: Color.routaPrimary.opacity(isHovered ? 0.4 : 0.3),
                            radius: isPressed ? 8 : 16,
                            x: 0,
                            y: isPressed ? 4 : 8
                        )
                )
                .foregroundColor(.white)
                .scaleEffect(isPressed ? 0.9 : (isHovered ? 1.05 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isHovered)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Card with Animated Background
struct AnimatedBackgroundCard<Content: View>: View {
    let content: Content
    @State private var animationOffset: CGFloat = 0
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(RoutaGradients.animatedGradient(offset: animationOffset))
                    .opacity(0.8)
            )
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    animationOffset = 1
                }
            }
    }
}

// MARK: - Blur Card
struct BlurCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let material: Material
    
    init(
        cornerRadius: CGFloat = 16,
        material: Material = .regular,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.material = material
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.clear)
                    .background(material, in: RoundedRectangle(cornerRadius: cornerRadius))
            )
    }
}

// MARK: - Interactive Card
struct InteractiveCard<Content: View>: View {
    let content: Content
    let onTap: (() -> Void)?
    let onLongPress: (() -> Void)?
    @State private var isPressed = false
    @State private var dragOffset = CGSize.zero
    
    init(
        onTap: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.onTap = onTap
        self.onLongPress = onLongPress
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.routaCard)
                    .shadow(
                        color: Color.black.opacity(isPressed ? 0.1 : 0.15),
                        radius: isPressed ? 4 : 8,
                        x: 0,
                        y: isPressed ? 2 : 4
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .offset(dragOffset)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = CGSize(
                            width: value.translation.width * 0.1,
                            height: value.translation.height * 0.1
                        )
                    }
                    .onEnded { _ in
                        dragOffset = .zero
                    }
            )
            .onTapGesture {
                onTap?()
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
            }
            .onLongPressGesture {
                onLongPress?()
            }
    }
}
