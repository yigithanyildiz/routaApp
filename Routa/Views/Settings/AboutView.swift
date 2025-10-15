import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var themeManager = RoutaThemeManager.shared

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        List {
            // Hero Section
            Section {
                VStack(spacing: RoutaSpacing.lg) {
                    ZStack {
                        Circle()
                            .fill(RoutaGradients.primaryGradient)
                            .frame(width: 100, height: 100)
                            .routaShadow(.high, style: .colored(.routaPrimary))

                        Image(systemName: "map.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    .padding(.top, RoutaSpacing.md)

                    VStack(spacing: RoutaSpacing.xs) {
                        Text("Routa")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.routaText)

                        Text("Sürüm \(appVersion)")
                            .routaCallout()
                            .foregroundColor(.routaTextSecondary)
                    }

                    Text("Dünyayı keşfetmenin en akıllı yolu")
                        .routaBody()
                        .foregroundColor(.routaTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, RoutaSpacing.sm)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }

            // Features Section
            Section {
                featureRow(icon: "map.fill", title: "Akıllı Rotalar", description: "Kişiselleştirilmiş seyahat rotaları", color: .routaPrimary)
                featureRow(icon: "heart.fill", title: "Favori Yerler", description: "Beğendiğiniz destinasyonları kaydedin", color: .routaError)
                featureRow(icon: "dollarsign.circle.fill", title: "Bütçe Dostu", description: "Bütçenize uygun planlar", color: .routaSuccess)
                featureRow(icon: "sparkles", title: "Modern Tasarım", description: "Kullanıcı dostu arayüz", color: .routaAccent)
            } header: {
                Text("ÖZELLİKLER")
                    .font(.routaCaption2())
                    .foregroundColor(.routaTextSecondary)
            }

            // Company Info Section
            Section {
                infoRow(icon: "building.2.fill", title: "Şirket", value: "Routa Teknoloji A.Ş.", color: .routaPrimary)
                infoRow(icon: "location.fill", title: "Lokasyon", value: "İstanbul, Türkiye", color: .routaSecondary)
                infoRow(icon: "envelope.fill", title: "E-posta", value: "info@routa.app", color: .routaAccent)
                infoRow(icon: "globe", title: "Website", value: "www.routa.app", color: .routaWarning)
            } header: {
                Text("İLETİŞİM")
                    .font(.routaCaption2())
                    .foregroundColor(.routaTextSecondary)
            }

            // Footer Section
            Section {
                VStack(spacing: RoutaSpacing.md) {
                    Text("Made with ❤️ in Istanbul")
                        .routaHeadline()
                        .foregroundColor(.routaPrimary)

                    Text("Seyahat tutkunları tarafından, seyahat tutkunları için geliştirildi.")
                        .routaCallout()
                        .foregroundColor(.routaTextSecondary)
                        .multilineTextAlignment(.center)

                    Divider()
                        .padding(.vertical, RoutaSpacing.xs)

                    VStack(spacing: RoutaSpacing.xs) {
                        Text("© 2024 Routa Teknoloji A.Ş.")
                            .routaCaption1()
                            .foregroundColor(.routaTextSecondary)

                        Text("Tüm hakları saklıdır.")
                            .routaCaption2()
                            .foregroundColor(.routaTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Hakkında")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }


    private func featureRow(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: RoutaSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .routaCallout()
                    .foregroundColor(.routaText)

                Text(description)
                    .routaCaption2()
                    .foregroundColor(.routaTextSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func infoRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: RoutaSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .routaCaption1()
                    .foregroundColor(.routaTextSecondary)

                Text(value)
                    .routaCallout()
                    .foregroundColor(.routaText)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview("About - Light Mode") {
    NavigationStack {
        AboutView()
    }
    .preferredColorScheme(.light)
}

#Preview("About - Dark Mode") {
    NavigationStack {
        AboutView()
    }
    .preferredColorScheme(.dark)
}
