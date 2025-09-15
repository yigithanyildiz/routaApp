import SwiftUI

// MARK: - Onboarding Page Model
struct OnboardingPage: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let gradientColors: [Color]
    let requiresLocationPermission: Bool
    let requiresNotificationPermission: Bool
    
    init(
        title: String,
        subtitle: String,
        description: String,
        imageName: String,
        gradientColors: [Color],
        requiresLocationPermission: Bool = false,
        requiresNotificationPermission: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.imageName = imageName
        self.gradientColors = gradientColors
        self.requiresLocationPermission = requiresLocationPermission
        self.requiresNotificationPermission = requiresNotificationPermission
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Sample Onboarding Pages
extension OnboardingPage {
    static let samplePages: [OnboardingPage] = [
        OnboardingPage(
            title: "Routa'ya Hoş Geldiniz",
            subtitle: "Dünyayı Keşfetmenin Yeni Yolu",
            description: "Kişiselleştirilmiş seyahat rotaları oluşturun, harika destinasyonları keşfedin ve unutulmaz anılar biriktirin.",
            imageName: "globe.europe.africa.fill",
            gradientColors: [.routaPrimary, .routaSecondary]
        ),
        
        OnboardingPage(
            title: "Rotaları Keşfedin",
            subtitle: "Size Özel Seyahat Planları",
            description: "Yapay zeka destekli algoritmamız, tercihlerinizi ve bütçenizi göz önünde bulundurarak mükemmel rotalar oluşturur.",
            imageName: "map.fill",
            gradientColors: [.routaSecondary, .routaAccent]
        ),
        
        OnboardingPage(
            title: "İlerlemenizi Takip Edin",
            subtitle: "Seyahat Maceranızı Kaydedin",
            description: "Ziyaret ettiğiniz yerleri, tamamladığınız rotaları ve favori destinasyonlarınızı kolayca takip edin.",
            imageName: "chart.line.uptrend.xyaxis",
            gradientColors: [.routaAccent, .routaSuccess]
        ),
        
        OnboardingPage(
            title: "Konumunuzu Paylaşın",
            subtitle: "Daha İyi Öneriler İçin",
            description: "Konumunuza erişim vererek size en yakın destinasyonları ve kişiselleştirilmiş önerileri alabilirsiniz.",
            imageName: "location.fill",
            gradientColors: [.routaSuccess, .routaWarning],
            requiresLocationPermission: true
        ),
        
        OnboardingPage(
            title: "Maceranız Başlasın!",
            subtitle: "Bildirimlerle Güncel Kalın",
            description: "Yeni rota önerileri, seyahat fırsatları ve özel etkinlikler hakkında bildirim alın. Şimdi dünyayı keşfetmeye başlayın!",
            imageName: "airplane.departure",
            gradientColors: [.routaWarning, .routaPrimary],
            requiresNotificationPermission: true
        )
    ]
}