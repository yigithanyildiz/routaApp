import SwiftUI
import CoreLocation
import UserNotifications

// MARK: - Onboarding View
struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var dragOffset: CGSize = .zero
    @State private var animationOffset: CGFloat = 0
    @StateObject private var locationManager = LocationManager()
    @StateObject private var notificationManager = NotificationManager()
    
    let pages = OnboardingPage.samplePages
    var onComplete: () -> Void
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Enhanced Animated Background
                EnhancedOnboardingBackground(currentPage: currentPage, totalPages: pages.count)
                    .ignoresSafeArea()
                
                // Floating Elements
                OnboardingFloatingElements(currentPage: currentPage, geometry: geometry)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Navigation
                    topNavigationBar
                        .adaptiveTopPadding()
                    
                    // Main Content
                    TabView(selection: $currentPage) {
                        ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                            OnboardingPageView(
                                page: page,
                                pageIndex: index,
                                currentPage: currentPage,
                                geometry: geometry,
                                locationManager: locationManager,
                                notificationManager: notificationManager
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onAppear {
                        setupPageControlAppearance()
                    }
                    .onChange(of: currentPage) { _, newValue in
                        RoutaHapticType.swipeAction.trigger()
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            animationOffset = CGFloat(newValue) * 20
                        }
                    }
                    
                    // Bottom Navigation
                    bottomNavigationBar
                        .padding(.bottom, UIDevice.safeAreaInsets.bottom + 20)
                }
                
            }
        }
        .topScrollBlur(enableBlur: false) // Onboarding has special background
        .routaDesignSystem()
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                animationOffset = 360
            }
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        let currentPageGradient = pages[safe: currentPage]?.gradient ?? RoutaGradients.primaryGradient
        let nextPageGradient = pages[safe: currentPage + 1]?.gradient ?? currentPageGradient
        
        return LinearGradient(
            colors: [
               .routaPrimary,
               .routaSecondary
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.6)
        .animation(.easeInOut(duration: 0.8), value: currentPage)
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            // Progress Indicator
            HStack(spacing: 12) {
                ForEach(0..<pages.count, id: \.self) { index in
                    ProgressDot(
                        isActive: index == currentPage,
                        isPast: index < currentPage,
                        color: pages[safe: index]?.gradientColors.first ?? .routaPrimary
                    )
                }
            }
            
            Spacer()
            
            // Skip Button
            if currentPage < pages.count - 1 {
                AnimatedSkipButton {
                    skipOnboarding()
                }
            }
        }
        .padding(.horizontal, RoutaSpacing.lg)
        .padding(.vertical, RoutaSpacing.md)
    }
    
    // MARK: - Bottom Navigation Bar
    private var bottomNavigationBar: some View {
        VStack(spacing: RoutaSpacing.lg) {
            // Main Action Button
            if currentPage == pages.count - 1 {
                RoutaGradientButton(
                    "Maceraya Başla",
                    icon: "arrow.right",
                    gradient: pages[currentPage].gradient,
                    size: .large
                ) {
                    // Directly complete onboarding without delay
                    onComplete()
                }
                .routaFloat(amplitude: 5, duration: 3.0)
            } else {
                RoutaButton(
                    "Devam Et",
                    icon: "arrow.right",
                    variant: .primary,
                    size: .large
                ) {
                    nextPage()
                }
            }
            
            // Interactive Progress Bar
            InteractiveProgressBar(currentPage: currentPage, totalPages: pages.count) { targetPage in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    currentPage = targetPage
                }
            }
        }
        .padding(.horizontal, RoutaSpacing.lg)
    }
    
    // MARK: - Helper Methods
    private func nextPage() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if currentPage < pages.count - 1 {
                currentPage += 1
            }
        }
    }
    
    private func skipOnboarding() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentPage = pages.count - 1
        }
    }
    
    
    private func setupPageControlAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.white
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
    }
}

// MARK: - Individual Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    let currentPage: Int
    let geometry: GeometryProxy
    let locationManager: LocationManager
    let notificationManager: NotificationManager
    
    @State private var imageScale: CGFloat = 0.8
    @State private var titleOffset: CGFloat = 50
    @State private var contentOpacity: Double = 0
    @State private var cardOffset: CGFloat = 100
    
    var isCurrentPage: Bool {
        pageIndex == currentPage
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: RoutaSpacing.lg) {
                
                // Hero Section
                heroSection
                    .routaFloat(amplitude: isCurrentPage ? 15 : 0, duration: 4.0)
                
                // Content Card
                contentCard
                    .offset(y: cardOffset)
                    .opacity(contentOpacity)
                
                // Permission Buttons
                if page.requiresLocationPermission || page.requiresNotificationPermission {
                    permissionSection
                        .transition(.routaSlideIn)
                }
                
                // Extra spacing to ensure content extends below screen
                Spacer(minLength: 150)
            }
            .padding(.horizontal, RoutaSpacing.lg)
            .padding(.bottom, 50) // Reduce bottom padding to show content is cut off
        }
        .onAppear {
            animatePageEntry()
        }
        .onChange(of: isCurrentPage) { _, newValue in
            if newValue {
                animatePageEntry()
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: RoutaSpacing.lg) {
            // Hero Image/Icon
            ZStack {
                // Background Glow
                Circle()
                    .fill(page.gradient)
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)
                    .opacity(0)
                    .routaPulse(minScale: 0.8, maxScale: 1.2, duration: 2.0)
                
                // Main Image
                Image(systemName: page.imageName)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.white)
                    .frame(width: 120, height: 120)
                    .background(
                        Circle()
                            .fill(page.gradient)
                            .routaShadow(.high, style: .glow(.white))
                    )
                    .scaleEffect(imageScale)
            }
            
            // Title
            Text(page.title)
                .routaHeroTitle()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .offset(y: titleOffset)
        }
    }
    
    // MARK: - Content Card
    private var contentCard: some View {
        VStack(spacing: RoutaSpacing.md) {
            RoutaCard(style: .glassmorphic, elevation: .high) {
                VStack(spacing: RoutaSpacing.lg) {
                    Text(page.subtitle)
                        .routaTitle2()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(page.description)
                        .routaBody()
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(RoutaSpacing.lg)
            }
            .routaShadow(.floating, style: .glassmorphic)
            
            // Scroll indicator
         
        }
    }
    
    // MARK: - Permission Section
    private var permissionSection: some View {
        VStack(spacing: RoutaSpacing.md) {
            if page.requiresLocationPermission {
                PermissionButton(
                    title: "Konum İzni Ver",
                    icon: "location.fill",
                    description: "Size özel öneriler için",
                    gradient: RoutaGradients.accentGradient
                ) {
                    locationManager.requestLocationPermission()
                }
            }
            
            if page.requiresNotificationPermission {
                PermissionButton(
                    title: "Bildirim İzni Ver",
                    icon: "bell.fill",
                    description: "Güncel kalın",
                    gradient: RoutaGradients.secondaryGradient
                ) {
                    notificationManager.requestNotificationPermission()
                }
            }
        }
    }
    
    // MARK: - Animation Methods
    private func animatePageEntry() {
        // Reset all animations
        imageScale = 0.8
        titleOffset = 50
        contentOpacity = 0
        cardOffset = 100
        
        // Animate in sequence
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
            imageScale = 1.0
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
            titleOffset = 0
        }
        
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.5)) {
            contentOpacity = 1.0
            cardOffset = 0
        }
        
        // Add a subtle bounce to hint at scrollable content
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(1.5)) {
            cardOffset = -10
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(1.8)) {
            cardOffset = 0
        }
    }
}

// MARK: - Progress Dot Component
struct ProgressDot: View {
    let isActive: Bool
    let isPast: Bool
    let color: Color
    
    var body: some View {
        Circle()
            .fill(isActive || isPast ? color : Color.white.opacity(0.3))
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.6), lineWidth: isActive ? 2 : 0)
            )
            .scaleEffect(isActive ? 1.2 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isActive)
    }
}

// MARK: - Page Indicator Component
struct PageIndicatorView: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                    .frame(width: index == currentPage ? 10 : 6, height: index == currentPage ? 10 : 6)
                    .scaleEffect(index == currentPage ? 1.0 : 0.8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
        .padding(.vertical, RoutaSpacing.sm)
    }
}

// MARK: - Permission Button Component
struct PermissionButton: View {
    let title: String
    let icon: String
    let description: String
    let gradient: LinearGradient
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            RoutaHapticType.buttonPress.trigger()
            action()
        }) {
            HStack(spacing: RoutaSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(gradient)
                            .routaShadow(.medium, style: .glow(.white))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .routaCallout()
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .routaCaption1()
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(RoutaSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Supporting Managers
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
}

class NotificationManager: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.authorizationStatus = granted ? .authorized : .denied
            }
        }
    }
}

// MARK: - Array Extension for Safe Access
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(onComplete: {
        print("Onboarding completed!")
    })
}
