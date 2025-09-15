import SwiftUI

// MARK: - Button Size System
enum RoutaButtonSize {
    case small
    case medium
    case large
    case xlarge
    
    var height: CGFloat {
        switch self {
        case .small: return 36
        case .medium: return 44
        case .large: return 52
        case .xlarge: return 60
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 20
        case .large: return 24
        case .xlarge: return 28
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        case .xlarge: return 20
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 18
        case .large: return 20
        case .xlarge: return 22
        }
    }
}

// MARK: - Button Variant System
enum RoutaButtonVariant {
    case primary
    case secondary
    case outline
    case ghost
    case destructive
    case success
    case warning
    
    func backgroundColor(isPressed: Bool = false) -> Color {
        let opacity: Double = isPressed ? 0.8 : 1.0
        switch self {
        case .primary: return .routaPrimary.opacity(opacity)
        case .secondary: return .routaSecondary.opacity(opacity)
        case .outline, .ghost: return .clear
        case .destructive: return .routaError.opacity(opacity)
        case .success: return .routaSuccess.opacity(opacity)
        case .warning: return .routaWarning.opacity(opacity)
        }
    }
    
    func foregroundColor(isPressed: Bool = false) -> Color {
        switch self {
        case .primary, .secondary, .destructive, .success, .warning:
            return .white
        case .outline:
            return isPressed ? .white : .routaPrimary
        case .ghost:
            return isPressed ? .routaPrimary.opacity(0.8) : .routaPrimary
        }
    }
    
    func borderColor(isPressed: Bool = false) -> Color {
        switch self {
        case .outline:
            return isPressed ? .routaPrimary : .routaPrimary
        default:
            return .clear
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .primary: return .routaPrimary.opacity(0.3)
        case .secondary: return .routaSecondary.opacity(0.3)
        case .destructive: return .routaError.opacity(0.3)
        case .success: return .routaSuccess.opacity(0.3)
        case .warning: return .routaWarning.opacity(0.3)
        case .outline, .ghost: return .clear
        }
    }
}

// MARK: - Micro-Interaction Button
struct RoutaButton: View {
    let title: String
    let icon: String?
    let variant: RoutaButtonVariant
    let size: RoutaButtonSize
    let isDisabled: Bool
    let isLoading: Bool
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    @State private var animationScale: CGFloat = 1.0
    @State private var hapticFeedback: UIImpactFeedbackGenerator
    
    init(
        _ title: String,
        icon: String? = nil,
        variant: RoutaButtonVariant = .primary,
        size: RoutaButtonSize = .medium,
        isDisabled: Bool = false,
        isLoading: Bool = false,
        hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.size = size
        self.isDisabled = isDisabled
        self.isLoading = isLoading
        self.hapticStyle = hapticStyle
        self.action = action
        self._hapticFeedback = State(initialValue: UIImpactFeedbackGenerator(style: hapticStyle))
    }
    
    var body: some View {
        Button(action: {
            if !isDisabled && !isLoading {
                hapticFeedback.impactOccurred()
                action()
                
                // Micro-interaction animation
                withAnimation(.easeInOut(duration: 0.1)) {
                    animationScale = 0.95
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        animationScale = 1.0
                    }
                }
            }
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: variant.foregroundColor(isPressed: isPressed)))
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }
                
                if !title.isEmpty {
                    Text(title)
                        .font(.system(size: size.fontSize, weight: .medium))
                }
            }
            .foregroundColor(variant.foregroundColor(isPressed: isPressed))
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: size.height / 2)
                    .fill(variant.backgroundColor(isPressed: isPressed))
                    .overlay(
                        RoundedRectangle(cornerRadius: size.height / 2)
                            .stroke(variant.borderColor(isPressed: isPressed), lineWidth: 1)
                    )
                    .shadow(
                        color: variant.shadowColor,
                        radius: isPressed ? 4 : 8,
                        x: 0,
                        y: isPressed ? 2 : 4
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
        .scaleEffect(animationScale)
        .scaleEffect(isPressed ? 0.96 : (isHovered ? 1.02 : 1.0))
        .animation(RoutaAnimations.quickSpring, value: isPressed)
        .animation(RoutaAnimations.smoothSpring, value: isHovered)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Icon Button
struct RoutaIconButton: View {
    let icon: String
    let variant: RoutaButtonVariant
    let size: RoutaButtonSize
    let isDisabled: Bool
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var hapticFeedback: UIImpactFeedbackGenerator
    @State private var rotationAngle: Double = 0
    
    init(
        icon: String,
        variant: RoutaButtonVariant = .primary,
        size: RoutaButtonSize = .medium,
        isDisabled: Bool = false,
        hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.variant = variant
        self.size = size
        self.isDisabled = isDisabled
        self.hapticStyle = hapticStyle
        self.action = action
        self._hapticFeedback = State(initialValue: UIImpactFeedbackGenerator(style: hapticStyle))
    }
    
    var body: some View {
        Button(action: {
            if !isDisabled {
                hapticFeedback.impactOccurred()
                action()
                
                // Rotation micro-interaction
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    rotationAngle += 360
                }
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .medium))
                .foregroundColor(variant.foregroundColor(isPressed: isPressed))
                .frame(width: size.height, height: size.height)
                .background(
                    Circle()
                        .fill(variant.backgroundColor(isPressed: isPressed))
                        .overlay(
                            Circle()
                                .stroke(variant.borderColor(isPressed: isPressed), lineWidth: 1)
                        )
                        .shadow(
                            color: variant.shadowColor,
                            radius: isPressed ? 4 : 8,
                            x: 0,
                            y: isPressed ? 2 : 4
                        )
                )
                .rotationEffect(.degrees(rotationAngle))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(RoutaAnimations.quickSpring, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Toggle Button
struct RoutaToggleButton: View {
    @Binding var isOn: Bool
    let onIcon: String
    let offIcon: String
    let size: RoutaButtonSize
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    let onToggle: ((Bool) -> Void)?
    
    @State private var hapticFeedback: UIImpactFeedbackGenerator
    @State private var bounceScale: CGFloat = 1.0
    
    init(
        isOn: Binding<Bool>,
        onIcon: String = "checkmark",
        offIcon: String = "multiply",
        size: RoutaButtonSize = .medium,
        hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light,
        onToggle: ((Bool) -> Void)? = nil
    ) {
        self._isOn = isOn
        self.onIcon = onIcon
        self.offIcon = offIcon
        self.size = size
        self.hapticStyle = hapticStyle
        self.onToggle = onToggle
        self._hapticFeedback = State(initialValue: UIImpactFeedbackGenerator(style: hapticStyle))
    }
    
    var body: some View {
        Button(action: {
            hapticFeedback.impactOccurred()
            
            withAnimation(RoutaAnimations.bounceSpring) {
                isOn.toggle()
                bounceScale = 1.2
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(RoutaAnimations.smoothSpring) {
                    bounceScale = 1.0
                }
            }
            
            onToggle?(isOn)
        }) {
            Image(systemName: isOn ? onIcon : offIcon)
                .font(.system(size: size.iconSize, weight: .bold))
                .foregroundColor(.white)
                .frame(width: size.height, height: size.height)
                .background(
                    Circle()
                        .fill(isOn ? AnyShapeStyle(RoutaGradients.primaryGradient) : AnyShapeStyle(Color.routaTextSecondary))
                        .shadow(
                            color: isOn ? Color.routaPrimary.opacity(0.3) : Color.black.opacity(0.2),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                )
                .scaleEffect(bounceScale)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(RoutaAnimations.smoothSpring, value: isOn)
    }
}

// MARK: - Gradient Button
struct RoutaGradientButton: View {
    let title: String
    let icon: String?
    let gradient: LinearGradient
    let size: RoutaButtonSize
    let isDisabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    @State private var shimmerOffset: CGFloat = -1
    
    init(
        _ title: String,
        icon: String? = nil,
        gradient: LinearGradient = RoutaGradients.primaryGradient,
        size: RoutaButtonSize = .medium,
        isDisabled: Bool = false,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.size = size
        self.isDisabled = isDisabled
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !isDisabled && !isLoading {
                hapticFeedback.impactOccurred()
                action()
                
                // Shimmer effect
                withAnimation(.linear(duration: 0.6)) {
                    shimmerOffset = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    shimmerOffset = -1
                }
            }
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }
                
                if !title.isEmpty {
                    Text(title)
                        .font(.system(size: size.fontSize, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(height: size.height)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: size.height / 2)
                    .fill(gradient)
                    .overlay(
                        // Shimmer effect
                        RoundedRectangle(cornerRadius: size.height / 2)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.3),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: shimmerOffset * 300)
                            .mask(RoundedRectangle(cornerRadius: size.height / 2))
                    )
                    .shadow(
                        color: .routaPrimary.opacity(0.4),
                        radius: isPressed ? 4 : 12,
                        x: 0,
                        y: isPressed ? 2 : 6
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(RoutaAnimations.quickSpring, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Floating Action Button
struct RoutaFloatingActionButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
    @State private var pulseScale: CGFloat = 1.0
    
    init(
        icon: String = "plus",
        size: CGFloat = 56,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            hapticFeedback.impactOccurred()
            action()
            
            // Pulse effect
            withAnimation(.easeOut(duration: 0.3)) {
                pulseScale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    pulseScale = 1.0
                }
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(RoutaGradients.accentGradient)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(
                            color: .routaAccent.opacity(isHovered ? 0.5 : 0.3),
                            radius: isPressed ? 8 : 20,
                            x: 0,
                            y: isPressed ? 4 : 10
                        )
                )
                .scaleEffect(pulseScale)
                .scaleEffect(isPressed ? 0.9 : (isHovered ? 1.05 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
        .animation(RoutaAnimations.quickSpring, value: isPressed)
        .animation(RoutaAnimations.smoothSpring, value: isHovered)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Button Group
struct RoutaButtonGroup: View {
    let buttons: [RoutaButtonGroupItem]
    @Binding var selectedIndex: Int
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    let onSelectionChanged: ((Int) -> Void)?
    
    @State private var hapticFeedback: UIImpactFeedbackGenerator
    
    struct RoutaButtonGroupItem {
        let title: String
        let icon: String?
        
        init(_ title: String, icon: String? = nil) {
            self.title = title
            self.icon = icon
        }
    }
    
    init(
        buttons: [RoutaButtonGroupItem],
        selectedIndex: Binding<Int>,
        hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light,
        onSelectionChanged: ((Int) -> Void)? = nil
    ) {
        self.buttons = buttons
        self._selectedIndex = selectedIndex
        self.hapticStyle = hapticStyle
        self.onSelectionChanged = onSelectionChanged
        self._hapticFeedback = State(initialValue: UIImpactFeedbackGenerator(style: hapticStyle))
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(buttons.enumerated()), id: \.offset) { index, button in
                Button(action: {
                    if selectedIndex != index {
                        hapticFeedback.impactOccurred()
                        selectedIndex = index
                        onSelectionChanged?(index)
                    }
                }) {
                    HStack(spacing: 6) {
                        if let icon = button.icon {
                            Image(systemName: icon)
                                .font(.system(size: 14, weight: .medium))
                        }
                        Text(button.title)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(selectedIndex == index ? .white : .routaPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedIndex == index ? Color.routaPrimary : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.routaSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.routaBorder, lineWidth: 1)
                )
        )
        .animation(RoutaAnimations.smoothSpring, value: selectedIndex)
    }
}