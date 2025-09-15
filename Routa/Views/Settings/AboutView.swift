import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RoutaSpacing.xl) {
                    appLogoSection
                    appInfoSection
                    developerInfoSection
                    acknowledgmentsSection
                }
                .padding(.horizontal, RoutaSpacing.lg)
                .padding(.bottom, 90)
            }
            .navigationTitle("Hakkında")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.routaBackground)
           
        }
    }
    
    private var appLogoSection: some View {
        RoutaCard(style: .glassmorphic, elevation: .high) {
            VStack(spacing: RoutaSpacing.lg) {
                // App Logo/Icon
                ZStack {
                    Circle()
                        .fill(RoutaGradients.primaryGradient)
                        .frame(width: 120, height: 120)
                        .routaShadow(.high, style: .colored(.routaPrimary))
                    
                    Image(systemName: "map.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: RoutaSpacing.sm) {
                    Text("Routa")
                        .routaTitle1()
                        .foregroundColor(.routaText)
                    
                    Text("Sürüm \(appVersion) (\(buildNumber))")
                        .routaCallout()
                        .foregroundColor(.routaTextSecondary)
                }
            }
            .padding(RoutaSpacing.xl)
        }
        .padding(.top, RoutaSpacing.md)
    }
    
    private var appInfoSection: some View {
        RoutaCard(style: .standard, elevation: .medium) {
            VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                Text("Uygulama Hakkında")
                    .routaTitle3()
                    .foregroundColor(.routaText)
                
                Text("Routa, dünya genelindeki harika destinasyonları keşfetmenizi ve kişiselleştirilmiş seyahat rotaları oluşturmanızı sağlayan akıllı bir seyahat uygulamasıdır.")
                    .routaBody()
                    .foregroundColor(.routaText)
                    .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                    featurePoint("🗺️ Kişiselleştirilmiş rota önerileri")
                    featurePoint("❤️ Favori destinasyonları kaydetme")
                    featurePoint("💰 Bütçe dostu seyahat planları")
                    featurePoint("📱 Modern ve kullanıcı dostu arayüz")
                    featurePoint("🌍 Dünya genelinde binlerce destinasyon")
                }
                .padding(.top, RoutaSpacing.sm)
                
                Text("Bütçenize ve tercihlerinize uygun rotalar oluşturun, favori destinasyonlarınızı kaydedin ve unutulmaz seyahatler planlayın.")
                    .routaCallout()
                    .foregroundColor(.routaTextSecondary)
                    .italic()
                    .padding(.top, RoutaSpacing.sm)
            }
            .padding(RoutaSpacing.lg)
        }
    }
    
    private var developerInfoSection: some View {
        RoutaCard(style: .standard, elevation: .medium) {
            VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                Text("Geliştirici Bilgileri")
                    .routaTitle3()
                    .foregroundColor(.routaText)
                
                VStack(spacing: RoutaSpacing.md) {
                    developerRow(
                        icon: "building.2.fill",
                        title: "Şirket",
                        value: "Routa Teknoloji A.Ş.",
                        color: .routaPrimary
                    )
                    
                    Divider().background(Color.routaBorder)
                    
                    developerRow(
                        icon: "location.fill",
                        title: "Lokasyon",
                        value: "İstanbul, Türkiye",
                        color: .routaSecondary
                    )
                    
                    Divider().background(Color.routaBorder)
                    
                    developerRow(
                        icon: "envelope.fill",
                        title: "İletişim",
                        value: "info@routa.app",
                        color: .routaAccent
                    )
                    
                    Divider().background(Color.routaBorder)
                    
                    developerRow(
                        icon: "globe",
                        title: "Website",
                        value: "www.routa.app",
                        color: .routaWarning
                    )
                }
            }
            .padding(RoutaSpacing.lg)
        }
    }
    
    private var acknowledgmentsSection: some View {
        RoutaCard(style: .standard, elevation: .low) {
            VStack(spacing: RoutaSpacing.md) {
                Text("Made with ❤️ in Istanbul")
                    .routaHeadline()
                    .foregroundColor(.routaPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Seyahat tutkunları tarafından, seyahat tutkunları için geliştirildi.")
                    .routaCallout()
                    .foregroundColor(.routaTextSecondary)
                    .multilineTextAlignment(.center)
                
                Divider()
                    .background(Color.routaBorder)
                    .padding(.vertical, RoutaSpacing.sm)
                
                VStack(spacing: RoutaSpacing.xs) {
                    Text("© 2024 Routa Teknoloji A.Ş.")
                        .routaCaption1()
                        .foregroundColor(.routaTextSecondary)
                    
                    Text("Tüm hakları saklıdır.")
                        .routaCaption2()
                        .foregroundColor(.routaTextSecondary)
                }
            }
            .padding(RoutaSpacing.lg)
        }
    }
    
    private func featurePoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: RoutaSpacing.sm) {
            Text("•")
                .routaBody()
                .foregroundColor(.routaPrimary)
                .frame(width: 12, alignment: .leading)
            
            Text(text)
                .routaCallout()
                .foregroundColor(.routaText)
        }
    }
    
    private func developerRow(
        icon: String,
        title: String,
        value: String,
        color: Color
    ) -> some View {
        HStack(spacing: RoutaSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(color)
                )
                .routaShadow(.subtle, style: .colored(color))
            
            VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                Text(title)
                    .routaCaption1()
                    .foregroundColor(.routaTextSecondary)
                
                Text(value)
                    .routaCallout()
                    .foregroundColor(.routaText)
            }
            
            Spacer()
        }
    }
}

#Preview {
    AboutView()
        .previewEnvironment(authenticated: false)
}
