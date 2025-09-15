import SwiftUI

// MARK: - Animated Background Particle System
struct OnboardingParticleView: View {
    let particleCount: Int
    let colors: [Color]
    
    @State private var particles: [Particle] = []
    
    init(particleCount: Int = 15, colors: [Color] = [.routaPrimary, .routaSecondary, .routaAccent]) {
        self.particleCount = particleCount
        self.colors = colors
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles.indices, id: \.self) { index in
                    let particle = particles[index]
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    particle.color.opacity(0.6),
                                    particle.color.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: particle.size / 2
                            )
                        )
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                        .blur(radius: particle.blur)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
                startAnimation()
            }
        }
        .allowsHitTesting(false)
    }
    
    private func generateParticles(in size: CGSize) {
        particles = (0..<particleCount).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                color: colors.randomElement() ?? .routaPrimary,
                size: CGFloat.random(in: 20...80),
                opacity: Double.random(in: 0.3...0.8),
                blur: CGFloat.random(in: 0...10),
                velocity: CGPoint(
                    x: CGFloat.random(in: -0.5...0.5),
                    y: CGFloat.random(in: -0.8...0.2)
                )
            )
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateParticles()
        }
    }
    
    private func updateParticles() {
        withAnimation(.linear(duration: 0.1)) {
            for index in particles.indices {
                particles[index].position.x += particles[index].velocity.x
                particles[index].position.y += particles[index].velocity.y
                
                // Wrap around screen
                if particles[index].position.x < -50 {
                    particles[index].position.x = UIScreen.main.bounds.width + 50
                }
                if particles[index].position.x > UIScreen.main.bounds.width + 50 {
                    particles[index].position.x = -50
                }
                if particles[index].position.y < -50 {
                    particles[index].position.y = UIScreen.main.bounds.height + 50
                }
                if particles[index].position.y > UIScreen.main.bounds.height + 50 {
                    particles[index].position.y = -50
                }
            }
        }
    }
}

// MARK: - Particle Model
struct Particle {
    var position: CGPoint
    let color: Color
    let size: CGFloat
    let opacity: Double
    let blur: CGFloat
    let velocity: CGPoint
}

// MARK: - Enhanced Onboarding Background
struct EnhancedOnboardingBackground: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        ZStack {
            // Base gradient background
            backgroundGradient
            
            // Particle system
            OnboardingParticleView(
                particleCount: 12,
                colors: currentPageColors
            )
            
            // Overlay patterns
            GeometryReader { geometry in
                Path { path in
                    // Create flowing curves
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    path.move(to: CGPoint(x: 0, y: height * 0.7))
                    path.addCurve(
                        to: CGPoint(x: width, y: height * 0.5),
                        control1: CGPoint(x: width * 0.3, y: height * 0.8),
                        control2: CGPoint(x: width * 0.7, y: height * 0.3)
                    )
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 3)
            }
        }
        .animation(.easeInOut(duration: 1.0), value: currentPage)
    }
    
    private var backgroundGradient: LinearGradient {
        let colors = currentPageColors
        return LinearGradient(
            colors: [
                colors[0].opacity(0.8),
                colors[1].opacity(0.6),
                colors[2].opacity(0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var currentPageColors: [Color] {
        switch currentPage {
        case 0: return [.routaPrimary, .routaSecondary, .routaAccent]
        case 1: return [.routaSecondary, .routaAccent, .routaSuccess]
        case 2: return [.routaAccent, .routaSuccess, .routaWarning]
        case 3: return [.routaSuccess, .routaWarning, .routaPrimary]
        case 4: return [.routaWarning, .routaPrimary, .routaSecondary]
        default: return [.routaPrimary, .routaSecondary, .routaAccent]
        }
    }
}

// MARK: - Floating Element Component
struct FloatingElement: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let position: CGPoint
    let animationDelay: Double
    
    @State private var isAnimating = false
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size, weight: .ultraLight))
            .foregroundColor(color.opacity(0.6))
            .rotationEffect(.degrees(rotation))
            .scaleEffect(isAnimating ? 1.2 : 0.8)
            .opacity(isAnimating ? 0.8 : 0.3)
            .position(position)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true)
                    .delay(animationDelay)
                ) {
                    isAnimating.toggle()
                }
                
                withAnimation(
                    .linear(duration: 20.0)
                    .repeatForever(autoreverses: false)
                    .delay(animationDelay)
                ) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Page-specific Floating Elements
struct OnboardingFloatingElements: View {
    let currentPage: Int
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            switch currentPage {
            case 0:
                welcomePageElements
            case 1:
                discoverPageElements
            case 2:
                trackingPageElements
            case 3:
                locationPageElements
            case 4:
                finalPageElements
            default:
                EmptyView()
            }
        }
    }
    
    private var welcomePageElements: some View {
        Group {
            FloatingElement(
                icon: "airplane",
                color: .routaAccent,
                size: 30,
                position: CGPoint(x: geometry.size.width * 0.2, y: geometry.size.height * 0.3),
                animationDelay: 0.0
            )
            
            FloatingElement(
                icon: "location",
                color: .routaSecondary,
                size: 25,
                position: CGPoint(x: geometry.size.width * 0.8, y: geometry.size.height * 0.4),
                animationDelay: 0.5
            )
            
            FloatingElement(
                icon: "star",
                color: .routaPrimary,
                size: 20,
                position: CGPoint(x: geometry.size.width * 0.1, y: geometry.size.height * 0.6),
                animationDelay: 1.0
            )
        }
    }
    
    private var discoverPageElements: some View {
        Group {
            FloatingElement(
                icon: "map",
                color: .routaSuccess,
                size: 35,
                position: CGPoint(x: geometry.size.width * 0.15, y: geometry.size.height * 0.25),
                animationDelay: 0.2
            )
            
            FloatingElement(
                icon: "compass",
                color: .routaAccent,
                size: 28,
                position: CGPoint(x: geometry.size.width * 0.85, y: geometry.size.height * 0.35),
                animationDelay: 0.7
            )
        }
    }
    
    private var trackingPageElements: some View {
        Group {
            FloatingElement(
                icon: "chart.bar",
                color: .routaWarning,
                size: 32,
                position: CGPoint(x: geometry.size.width * 0.25, y: geometry.size.height * 0.28),
                animationDelay: 0.3
            )
            
            FloatingElement(
                icon: "trophy",
                color: .routaSuccess,
                size: 26,
                position: CGPoint(x: geometry.size.width * 0.75, y: geometry.size.height * 0.45),
                animationDelay: 0.8
            )
        }
    }
    
    private var locationPageElements: some View {
        Group {
            FloatingElement(
                icon: "location.circle",
                color: .routaPrimary,
                size: 38,
                position: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.2),
                animationDelay: 0.1
            )
            
            FloatingElement(
                icon: "safari",
                color: .routaSecondary,
                size: 24,
                position: CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.5),
                animationDelay: 0.6
            )
        }
    }
    
    private var finalPageElements: some View {
        Group {
            FloatingElement(
                icon: "party.popper",
                color: .routaAccent,
                size: 40,
                position: CGPoint(x: geometry.size.width * 0.2, y: geometry.size.height * 0.2),
                animationDelay: 0.0
            )
            
            FloatingElement(
                icon: "sparkles",
                color: .routaWarning,
                size: 30,
                position: CGPoint(x: geometry.size.width * 0.8, y: geometry.size.height * 0.3),
                animationDelay: 0.4
            )
            
            FloatingElement(
                icon: "heart",
                color: .routaSecondary,
                size: 22,
                position: CGPoint(x: geometry.size.width * 0.1, y: geometry.size.height * 0.5),
                animationDelay: 0.9
            )
        }
    }
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            EnhancedOnboardingBackground(currentPage: 0, totalPages: 5)
            
            OnboardingFloatingElements(currentPage: 0, geometry: geometry)
        }
    }
    .routaDesignSystem()
}