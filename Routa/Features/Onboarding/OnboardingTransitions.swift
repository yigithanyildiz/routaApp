import SwiftUI

// MARK: - Custom Page Transition Effects
struct OnboardingPageTransition: ViewModifier {
    let currentPage: Int
    let pageIndex: Int
    let totalPages: Int
    
    private var offset: CGFloat {
        CGFloat(pageIndex - currentPage) * UIScreen.main.bounds.width
    }
    
    private var scale: CGFloat {
        let distance = abs(CGFloat(pageIndex - currentPage))
        return max(0.8, 1.0 - (distance * 0.1))
    }
    
    private var opacity: Double {
        let distance = abs(Double(pageIndex - currentPage))
        return max(0.3, 1.0 - (distance * 0.4))
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
    }
}

// MARK: - Parallax Background Effect
struct ParallaxBackground: View {
    let currentPage: Int
    let totalPages: Int
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let pageWidth = geometry.size.width
            let totalWidth = pageWidth * CGFloat(totalPages)
            
            // Background layers with different parallax speeds
            ZStack {
                // Layer 1 - Slowest (back layer)
                backgroundLayer1
                    .offset(x: -scrollOffset * 0.3)
                
                // Layer 2 - Medium speed
                backgroundLayer2
                    .offset(x: -scrollOffset * 0.5)
                
                // Layer 3 - Fastest (front layer)
                backgroundLayer3
                    .offset(x: -scrollOffset * 0.7)
            }
            .onReceive(NotificationCenter.default.publisher(for: .init("PageChanged"))) { _ in
                withAnimation(.easeOut(duration: 0.8)) {
                    scrollOffset = CGFloat(currentPage) * pageWidth * 0.5
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private var backgroundLayer1: some View {
        HStack(spacing: 0) {
            ForEach(0..<totalPages, id: \.self) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: getGradientColors(for: index),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(0.3)
                    .frame(width: UIScreen.main.bounds.width)
            }
        }
    }
    
    private var backgroundLayer2: some View {
        GeometryReader { geometry in
            ForEach(0..<totalPages * 3, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                getGradientColors(for: index % totalPages)[0].opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .position(
                        x: CGFloat(index) * (geometry.size.width / CGFloat(totalPages * 3)) + 100,
                        y: geometry.size.height * CGFloat.random(in: 0.2...0.8)
                    )
            }
        }
    }
    
    private var backgroundLayer3: some View {
        GeometryReader { geometry in
            ForEach(0..<totalPages * 2, id: \.self) { index in
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        getGradientColors(for: index % totalPages)[1].opacity(0.1)
                    )
                    .frame(width: 150, height: 100)
                    .rotationEffect(.degrees(Double(index) * 30))
                    .position(
                        x: CGFloat(index) * (geometry.size.width / CGFloat(totalPages * 2)) + 75,
                        y: geometry.size.height * CGFloat.random(in: 0.1...0.9)
                    )
            }
        }
    }
    
    private func getGradientColors(for index: Int) -> [Color] {
        switch index % 5 {
        case 0: return [.routaPrimary, .routaSecondary]
        case 1: return [.routaSecondary, .routaAccent]
        case 2: return [.routaAccent, .routaSuccess]
        case 3: return [.routaSuccess, .routaWarning]
        case 4: return [.routaWarning, .routaPrimary]
        default: return [.routaPrimary, .routaSecondary]
        }
    }
}

// MARK: - Interactive Progress Bar
struct InteractiveProgressBar: View {
    let currentPage: Int
    let totalPages: Int
    let onPageTap: (Int) -> Void
    
    @State private var dragProgress: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width
            let dotSize: CGFloat = 8
            let progressBarWidth = containerWidth
            let progressWidth = progressBarWidth * CGFloat(currentPage) / CGFloat(totalPages - 1)
            
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: progressBarWidth, height: 8)
                
                // Progress fill - moves 25% with each page (0%, 25%, 50%, 75%, 100%)
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.routaPrimary, .routaSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: progressWidth + dragProgress, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
        
                // Dots overlaid at exact percentage positions
                ForEach(0..<totalPages, id: \.self) { index in
                    let dotPosition = progressBarWidth * CGFloat(index) / CGFloat(totalPages - 1)
                    
                    Button(action: {
                        onPageTap(index)
                        RoutaHapticType.buttonTap.trigger()
                    }) {
                        Circle()
                            .fill(index <= currentPage ? Color.white : Color.white.opacity(0.5))
                            .frame(width: dotSize, height: dotSize)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                    .position(x: dotPosition, y: 4) // y: 4 centers dot on 8px high progress bar
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let maxDragWidth = progressBarWidth - progressWidth
                        dragProgress = max(0, min(maxDragWidth, value.translation.width))
                    }
                    .onEnded { value in
                        isDragging = false
                        let totalProgressWidth = progressWidth + value.translation.width
                        let progressPercentage = totalProgressWidth / progressBarWidth
                        let targetPage = min(totalPages - 1, max(0, Int(round(progressPercentage * CGFloat(totalPages - 1)))))
                        onPageTap(targetPage)
                        dragProgress = 0
                    }
            )
        }
        .frame(height: 40)
    }
}

// MARK: - Animated Skip Button
struct AnimatedSkipButton: View {
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            action()
            RoutaHapticType.buttonTap.trigger()
        }) {
            HStack(spacing: 8) {
                Text("Atla")
                    .routaCallout()
                    .foregroundColor(.white)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isHovered ? 45 : 0))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Success Celebration Animation
struct OnboardingSuccessAnimation: View {
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.1
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Success background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .routaSuccess.opacity(0.3),
                            .routaSuccess.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .scaleEffect(scale)
            
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.routaSuccess)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
            
            // Confetti particles
            if showConfetti {
                ForEach(0..<20, id: \.self) { index in
                    ConfettiParticle(
                        color: [.routaPrimary, .routaSecondary, .routaAccent, .routaSuccess, .routaWarning].randomElement() ?? .routaPrimary,
                        delay: Double(index) * 0.1
                    )
                }
            }
        }
        .opacity(opacity)
        .onAppear {
            startSuccessAnimation()
        }
    }
    
    private func startSuccessAnimation() {
        // Fade in
        withAnimation(.easeIn(duration: 0.3)) {
            opacity = 1.0
        }
        
        // Scale and rotate
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            scale = 1.0
            rotation = 360
        }
        
        // Show confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showConfetti = true
            RoutaHapticType.success.trigger()
        }
        
        // Complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onComplete()
        }
    }
}

// MARK: - Confetti Particle
struct ConfettiParticle: View {
    let color: Color
    let delay: Double
    
    @State private var position: CGPoint = CGPoint(x: 0, y: 0)
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 12, height: 12)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .position(position)
            .onAppear {
                animateParticle()
            }
    }
    
    private func animateParticle() {
        let startX = CGFloat.random(in: -50...50)
        let startY = CGFloat.random(in: -50...50)
        let endX = CGFloat.random(in: -200...200)
        let endY = CGFloat.random(in: 100...300)
        
        position = CGPoint(x: startX, y: startY)
        
        withAnimation(
            .easeOut(duration: 2.0)
            .delay(delay)
        ) {
            position = CGPoint(x: endX, y: endY)
            rotation = Double.random(in: 180...720)
            scale = 0.1
            opacity = 0.0
        }
    }
}

// MARK: - View Extension for Transitions
extension View {
    func onboardingPageTransition(currentPage: Int, pageIndex: Int, totalPages: Int) -> some View {
        modifier(OnboardingPageTransition(currentPage: currentPage, pageIndex: pageIndex, totalPages: totalPages))
    }
}

#Preview {
    VStack(spacing: 30) {
        // Test different page states to verify exact percentage alignment
        ForEach(0..<5) { currentPage in
            VStack {
                Text("Page \(currentPage) - \(currentPage * 25)% Progress")
                    .foregroundColor(.white)
                    .font(.caption)
                
                InteractiveProgressBar(currentPage: currentPage, totalPages: 5) { page in
                    print("Tapped page: \(page)")
                }
            }
        }
        
        Text("Dots at: 0%, 25%, 50%, 75%, 100%")
            .foregroundColor(.white.opacity(0.7))
            .font(.caption2)
        
        AnimatedSkipButton {
            print("Skip tapped")
        }
    }
    .padding()
    .background(.black)
    .routaDesignSystem()
}
