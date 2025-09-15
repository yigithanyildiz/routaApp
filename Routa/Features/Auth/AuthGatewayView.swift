import SwiftUI

struct AuthGatewayView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showAuthView = false
    @State private var authMode: AuthMode = .login
    @State private var animateEntrance = false
    @State private var isGuestLoading = false
    
    enum AuthMode {
        case login
        case signup
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Beautiful gradient background
                LinearGradient(
                    colors: [
                        Color.routaPrimary.opacity(0.8),
                        Color.routaSecondary.opacity(0.6),
                        Color.routaAccent.opacity(0.4),
                        Color.routaPrimary.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .routaRotatingGradient(duration: 8.0)
                
                // Blur overlay for depth
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                // Floating particles background
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: CGFloat.random(in: 20...60))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .routaFloat(
                            amplitude: CGFloat.random(in: 10...30),
                            duration: Double.random(in: 3...6)
                        )
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo and Hero Section
                    VStack(spacing: 32) {
                        // App Logo
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(RoutaGradients.primaryGradient)
                                    .frame(width: 120, height: 120)
                                    .routaGlow(color: .routaPrimary, radius: 20)
                                    .scaleEffect(animateEntrance ? 1.0 : 0.8)
                                    .opacity(animateEntrance ? 1.0 : 0.0)
                                
                                Image(systemName: "map.circle.fill")
                                    .font(.system(size: 60, weight: .light))
                                    .foregroundColor(.white)
                                    .scaleEffect(animateEntrance ? 1.0 : 0.5)
                                    .rotationEffect(.degrees(animateEntrance ? 0 : 180))
                            }
                            
                            VStack(spacing: 8) {
                                Text("Routa")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .white.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .scaleEffect(animateEntrance ? 1.0 : 0.8)
                                    .opacity(animateEntrance ? 1.0 : 0.0)
                                
                                Text("Rotalarını Keşfet")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color.routaAccentLight,
                                                Color.routaSecondaryLight
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .routaGlow(color: .routaAccent, radius: 8)
                                    .offset(y: animateEntrance ? 0 : 20)
                                    .opacity(animateEntrance ? 1.0 : 0.0)
                            }
                        }
                        
                        // Feature highlights
                        VStack(spacing: 12) {
                            FeatureHighlight(icon: "location.fill", text: "Kişiselleştirilmiş rotalar")
                            FeatureHighlight(icon: "heart.fill", text: "Favori destinasyonlar")
                            FeatureHighlight(icon: "map.fill", text: "Detaylı haritalar")
                        }
                        .offset(y: animateEntrance ? 0 : 30)
                        .opacity(animateEntrance ? 1.0 : 0.0)
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        // Login Button
                        RoutaGradientButton(
                            "Giriş Yap",
                            icon: "person.circle.fill",
                            gradient: RoutaGradients.primaryGradient,
                            size: .large
                        ) {
                            authMode = .login
                            showAuthView = true
                        }
                        .scaleEffect(animateEntrance ? 1.0 : 0.9)
                        .opacity(animateEntrance ? 1.0 : 0.0)
                        
                        // Sign Up Button
                        RoutaButton(
                            "Hesap Oluştur",
                            icon: "person.badge.plus",
                            variant: .secondary,
                            size: .large
                        ) {
                            authMode = .signup
                            showAuthView = true
                        }
                        .scaleEffect(animateEntrance ? 1.0 : 0.9)
                        .opacity(animateEntrance ? 1.0 : 0.0)
                        
                        // Guest Button
                        Button(action: {
                            print("🔴 Guest button tapped")
                            RoutaHapticsManager.shared.buttonTap()
                            isGuestLoading = true
                            
                            // Continue as guest with completion handler
                            authManager.continueAsGuest {
                                print("🔴 Guest state set - navigation should occur now")
                                // Small delay to ensure UI updates
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isGuestLoading = false
                                }
                            }
                        }) {
                            HStack(spacing: 8) {
                                if isGuestLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "person.slash")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                Text("Misafir Olarak Devam Et")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.vertical, 12)
                        }
                        .disabled(isGuestLoading)
                        .scaleEffect(animateEntrance ? 1.0 : 0.9)
                        .opacity(animateEntrance ? 0.8 : 0.0)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                }
            }
        }
        .sheet(isPresented: $showAuthView) {
            AuthView(mode: authMode)
        }
        .onAppear {
            withAnimation(RoutaAnimations.smoothSpring.delay(0.3)) {
                animateEntrance = true
            }
        }
    }
}

struct FeatureHighlight: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.routaAccentLight)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    AuthGatewayView()
        .environmentObject(AuthManager())
}