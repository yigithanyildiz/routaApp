import SwiftUI
import UIKit

// MARK: - Haptic Feedback Manager
class RoutaHapticsManager: ObservableObject {
    static let shared = RoutaHapticsManager()
    
    @Published var isHapticsEnabled: Bool = true
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    private init() {
        // Prepare haptic generators for better performance
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationFeedback.prepare()
        selectionFeedback.prepare()
    }
    
    // MARK: - Impact Feedback
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticsEnabled else { return }
        
        switch style {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        case .rigid:
            impactHeavy.impactOccurred()
        case .soft:
            impactLight.impactOccurred()
        @unknown default:
            impactMedium.impactOccurred()
        }
    }
    
    // MARK: - Notification Feedback
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticsEnabled else { return }
        notificationFeedback.notificationOccurred(type)
    }
    
    // MARK: - Selection Feedback
    func selection() {
        guard isHapticsEnabled else { return }
        selectionFeedback.selectionChanged()
    }
    
    // MARK: - Convenience Methods
    func lightImpact() {
        impact(.light)
    }
    
    func mediumImpact() {
        impact(.medium)
    }
    
    func heavyImpact() {
        impact(.heavy)
    }
    
    func success() {
        notification(.success)
    }
    
    func warning() {
        notification(.warning)
    }
    
    func error() {
        notification(.error)
    }
    
    // MARK: - Custom Haptic Patterns
    func buttonTap() {
        impact(.light)
    }
    
    func buttonPress() {
        impact(.medium)
    }
    
    func toggleSwitch() {
        selection()
    }
    
    func cardFlip() {
        impact(.medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impact(.light)
        }
    }
    
    func swipeAction() {
        selection()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.impact(.light)
        }
    }
    
    func dragStart() {
        impact(.light)
    }
    
    func dragEnd() {
        impact(.medium)
    }
    
    func pullToRefresh() {
        impact(.medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selection()
        }
    }
    
    func navigationTransition() {
        selection()
    }
    
    func tabChange() {
        selection()
    }
    
    func modalPresent() {
        impact(.light)
    }
    
    func modalDismiss() {
        impact(.light)
    }
    
    func longPress() {
        impact(.heavy)
    }
    
    func contextMenuOpen() {
        impact(.medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selection()
        }
    }
    
    func shake() {
        impact(.heavy)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impact(.medium)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impact(.light)
        }
    }
}

// MARK: - Haptic Feedback Types
enum RoutaHapticType {
    case buttonTap
    case buttonPress
    case toggleSwitch
    case cardFlip
    case swipeAction
    case dragStart
    case dragEnd
    case pullToRefresh
    case navigationTransition
    case tabChange
    case modalPresent
    case modalDismiss
    case longPress
    case contextMenuOpen
    case success
    case warning
    case error
    case shake
    case custom(UIImpactFeedbackGenerator.FeedbackStyle)
    
    func trigger() {
        let haptics = RoutaHapticsManager.shared
        
        switch self {
        case .buttonTap: haptics.buttonTap()
        case .buttonPress: haptics.buttonPress()
        case .toggleSwitch: haptics.toggleSwitch()
        case .cardFlip: haptics.cardFlip()
        case .swipeAction: haptics.swipeAction()
        case .dragStart: haptics.dragStart()
        case .dragEnd: haptics.dragEnd()
        case .pullToRefresh: haptics.pullToRefresh()
        case .navigationTransition: haptics.navigationTransition()
        case .tabChange: haptics.tabChange()
        case .modalPresent: haptics.modalPresent()
        case .modalDismiss: haptics.modalDismiss()
        case .longPress: haptics.longPress()
        case .contextMenuOpen: haptics.contextMenuOpen()
        case .success: haptics.success()
        case .warning: haptics.warning()
        case .error: haptics.error()
        case .shake: haptics.shake()
        case .custom(let style): haptics.impact(style)
        }
    }
}

// MARK: - Haptic View Modifier
struct HapticFeedbackModifier: ViewModifier {
    let hapticType: RoutaHapticType
    let trigger: AnyHashable?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, _ in
                hapticType.trigger()
            }
    }
}

// MARK: - View Extensions for Haptics
extension View {
    func hapticFeedback(_ type: RoutaHapticType, trigger: AnyHashable? = nil) -> some View {
        modifier(HapticFeedbackModifier(hapticType: type, trigger: trigger))
    }
    
    func onTapHaptic(_ type: RoutaHapticType = .buttonTap, perform action: @escaping () -> Void) -> some View {
        onTapGesture {
            type.trigger()
            action()
        }
    }
    
    func onLongPressHaptic(_ type: RoutaHapticType = .longPress, perform action: @escaping () -> Void) -> some View {
        onLongPressGesture {
            type.trigger()
            action()
        }
    }
}

// MARK: - Haptic Button Style
struct HapticButtonStyle: ButtonStyle {
    let hapticType: RoutaHapticType
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    hapticType.trigger()
                }
            }
    }
}

// MARK: - Haptic Gesture Recognizers
struct HapticDragGesture: ViewModifier {
    let onChanged: ((DragGesture.Value) -> Void)?
    let onEnded: ((DragGesture.Value) -> Void)?
    
    @State private var hasTriggeredStart = false
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !hasTriggeredStart {
                            RoutaHapticType.dragStart.trigger()
                            hasTriggeredStart = true
                        }
                        onChanged?(value)
                    }
                    .onEnded { value in
                        RoutaHapticType.dragEnd.trigger()
                        hasTriggeredStart = false
                        onEnded?(value)
                    }
            )
    }
}

extension View {
    func hapticDrag(
        onChanged: ((DragGesture.Value) -> Void)? = nil,
        onEnded: ((DragGesture.Value) -> Void)? = nil
    ) -> some View {
        modifier(HapticDragGesture(onChanged: onChanged, onEnded: onEnded))
    }
}

// MARK: - Custom Haptic Patterns
struct RoutaHapticPattern {
    let steps: [(RoutaHapticType, TimeInterval)]
    
    static let celebration = RoutaHapticPattern(steps: [
        (.success, 0),
        (.buttonTap, 0.1),
        (.buttonTap, 0.2),
        (.buttonTap, 0.3)
    ])
    
    static let notification = RoutaHapticPattern(steps: [
        (.buttonPress, 0),
        (.buttonTap, 0.1)
    ])
    
    static let swipeComplete = RoutaHapticPattern(steps: [
        (.swipeAction, 0),
        (.success, 0.2)
    ])
    
    static let error = RoutaHapticPattern(steps: [
        (.error, 0),
        (.shake, 0.3)
    ])
    
    func play() {
        for (index, step) in steps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + step.1) {
                step.0.trigger()
            }
        }
    }
}

// MARK: - Haptic Settings
struct RoutaHapticSettings: View {
    @ObservedObject private var haptics = RoutaHapticsManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Toggle("Enable Haptic Feedback", isOn: $haptics.isHapticsEnabled)
                .toggleStyle(SwitchToggleStyle())
                .hapticFeedback(.toggleSwitch, trigger: haptics.isHapticsEnabled)
            
            if haptics.isHapticsEnabled {
                VStack(spacing: 12) {
                    Text("Test Haptic Feedback")
                        .routaHeadline()
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        HapticTestButton(title: "Light", haptic: .custom(.light))
                        HapticTestButton(title: "Medium", haptic: .custom(.medium))
                        HapticTestButton(title: "Heavy", haptic: .custom(.heavy))
                        HapticTestButton(title: "Success", haptic: .success)
                        HapticTestButton(title: "Warning", haptic: .warning)
                        HapticTestButton(title: "Error", haptic: .error)
                    }
                }
                .transition(.routaScale)
            }
        }
        .animation(.spring(), value: haptics.isHapticsEnabled)
    }
}

struct HapticTestButton: View {
    let title: String
    let haptic: RoutaHapticType
    
    var body: some View {
        Button(title) {
            haptic.trigger()
        }
        .buttonStyle(.bordered)
    }
}

// MARK: - Haptic Environment
struct HapticEnvironmentKey: EnvironmentKey {
    static let defaultValue = RoutaHapticsManager.shared
}

extension EnvironmentValues {
    var haptics: RoutaHapticsManager {
        get { self[HapticEnvironmentKey.self] }
        set { self[HapticEnvironmentKey.self] = newValue }
    }
}