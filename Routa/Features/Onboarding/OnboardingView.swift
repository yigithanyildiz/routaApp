import SwiftUI
import CoreLocation
import UserNotifications

// MARK: - Modern Onboarding View
struct OnboardingView: View {
    @State private var currentPage = 0
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
                // Dark background
                Color.black
                    .ignoresSafeArea()
                
                
                VStack(spacing: 0) {
                    // Logo Header
                    headerView
                        .padding(.top, geometry.safeAreaInsets.top - 80 )
                    
                    
                    // Main Content
                    TabView(selection: $currentPage) {
                        ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                            ModernOnboardingPageView(
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
                    .onChange(of: currentPage) { _, newValue in
                        RoutaHapticType.swipeAction.trigger()
                    }
                    
                    Spacer()
                    
                    // Page indicators
                    pageIndicators
                        .padding(.bottom, 30)

                    // CTA Button
                    ctaButton
                        .padding(.horizontal, 32)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 10)
                }
            }
                
            
        }
        
        .routaDesignSystem()
    }
    
    // MARK: - Header View
    private var headerView: some View {
        Text("Routa")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }

    // MARK: - Page Indicators
    private var pageIndicators: some View {
        HStack(spacing: 12) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? .routaPrimary : Color.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    // MARK: - CTA Button
    private var ctaButton: some View {
        Button(action: {
            if currentPage == pages.count - 1 {
                onComplete()
            } else {
                nextPage()
            }
        }) {
            Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [.routaPrimary, .routaSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Methods
    private func nextPage() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if currentPage < pages.count - 1 {
                currentPage += 1
            }
        }
    }
}

// MARK: - Modern Onboarding Page View
struct ModernOnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    let currentPage: Int
    let geometry: GeometryProxy
    let locationManager: LocationManager
    let notificationManager: NotificationManager

    @State private var contentOpacity: Double = 0
    @State private var imageScale: CGFloat = 0.9

    var isCurrentPage: Bool {
        pageIndex == currentPage
    }

    var body: some View {
        if page.requiresLocationPermission || page.requiresNotificationPermission {
            // Fixed hero image with scrollable content below for permission page
            
               

                // Scrollable content section
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer()
                        heroImageCard
                            .padding(.horizontal, 32)
                        // Content Section
                        contentSection
                            .padding(.horizontal, 32)


                        // Permission Buttons
                        permissionSection
                            .padding(.horizontal, 32)
                            .padding(.bottom, 100) // Extra space for scroll
                    }
            }
            .opacity(contentOpacity)
            .scaleEffect(imageScale)
            .onAppear {
                if isCurrentPage {
                    animateEntry()
                }
            }
            .onChange(of: isCurrentPage) { _, newValue in
                if newValue {
                    animateEntry()
                }
            }
        } else {
            // Non-scrollable content for other pages
            VStack(spacing: 32) {
                // Hero Image Card
                heroImageCard

                // Content Section
                contentSection
            }
            .padding(.horizontal, 32)
            .opacity(contentOpacity)
            .scaleEffect(imageScale)
            .onAppear {
                if isCurrentPage {
                    animateEntry()
                }
            }
            .onChange(of: isCurrentPage) { _, newValue in
                if newValue {
                    animateEntry()
                }
            }
        }
    }
    
    // MARK: - Hero Image Card
    private var heroImageCard: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.1))
            .frame(height: geometry.size.height * 0.35)
            .overlay(
                // Placeholder for hero image - can be replaced with actual image
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        Color.gray.opacity(0.2
                        )
                    )
                    .overlay(
                        OnboardingCachedAsyncImage(url: URL(string: page.imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width - 80, height: geometry.size.height * 0.35 - 16)
                                .clipped()
                                .cornerRadius(16)
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        }
                    )
                    .padding(8)
            )
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(spacing: 16) {
            Text(page.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(page.description)
                .font(.body)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Permission Section
    private var permissionSection: some View {
        VStack(spacing: 12) {
            if page.requiresLocationPermission {
                PermissionButton(
                    title: "Enable Location",
                    icon: "location.fill",
                    description: "For personalized recommendations"
                ) {
                    locationManager.requestLocationPermission()
                }
            }

            if page.requiresNotificationPermission {
                PermissionButton(
                    title: "Enable Notifications",
                    icon: "bell.fill",
                    description: "Stay updated with new routes"
                ) {
                    notificationManager.requestNotificationPermission()
                }
            }
        }
    }
    
    // MARK: - Animation Methods
    private func animateEntry() {
        // Reset animations
        contentOpacity = 0
        imageScale = 0.9

        // Animate in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
            contentOpacity = 1.0
            imageScale = 1.0
        }
    }
}


// MARK: - Permission Button Component
struct PermissionButton: View {
    let title: String
    let icon: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.routaPrimary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.callout)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
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
