import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var themeManager = RoutaThemeManager.shared

    var body: some View {
        List {
            // Hero Section
            Section {
                VStack(spacing: RoutaSpacing.lg) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                            .routaShadow(.medium, style: .colored(.green))

                        Image(systemName: "shield.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    .padding(.top, RoutaSpacing.sm)

                    VStack(spacing: RoutaSpacing.xs) {
                        Text("Gizlilik Politikası")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.routaText)
                            .multilineTextAlignment(.center)

                        Text("Son güncelleme: \(Date().formatted(date: .abbreviated, time: .omitted))")
                            .routaCaption1()
                            .foregroundColor(.routaTextSecondary)
                    }

                    Text("Verilerinizin gizliliği bizim için önceliklidir")
                        .routaBody()
                        .foregroundColor(.routaTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, RoutaSpacing.sm)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }

            // Data Collection Section
            Section {
                infoBlock(
                    title: "Toplanan Veriler",
                    items: [
                        "Hesap bilgileriniz (ad, e-posta)",
                        "Seyahat tercihleriniz ve favoriler",
                        "Uygulama kullanım istatistikleri",
                        "Cihaz bilgileri (model, işletim sistemi)"
                    ]
                )
            } header: {
                Text("VERİ TOPLAMA")
                    .font(.routaCaption2())
                    .foregroundColor(.routaTextSecondary)
            }

            // Data Usage Section
            Section {
                infoBlock(
                    title: "Kullanım Amaçları",
                    items: [
                        "Kişiselleştirilmiş seyahat önerileri",
                        "Uygulama performansını iyileştirme",
                        "Müşteri desteği sağlama",
                        "Güvenlik ve dolandırıcılık önleme"
                    ]
                )

                VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                    HStack(spacing: RoutaSpacing.sm) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.routaSuccess)

                        Text("Verilerinizi üçüncü taraflarla paylaşmıyoruz veya satmıyoruz.")
                            .routaCallout()
                            .foregroundColor(.routaText)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.vertical, RoutaSpacing.xs)
            } header: {
                Text("VERİ KULLANIMI")
                    .font(.routaCaption2())
                    .foregroundColor(.routaTextSecondary)
            }

            // Data Protection Section
            Section {
                infoBlock(
                    title: "Güvenlik Önlemleri",
                    items: [
                        "Veriler şifrelenmiş olarak saklanır",
                        "Güvenli sunucularda barındırılır",
                        "Düzenli güvenlik denetimleri",
                        "GDPR ve KVKK uyumlu veri işleme"
                    ]
                )

                VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                    HStack(spacing: RoutaSpacing.sm) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.routaAccent)

                        Text("Hesabınızı silmeniz durumunda tüm kişisel verileriniz kalıcı olarak silinir.")
                            .routaCallout()
                            .foregroundColor(.routaTextSecondary)
                            .italic()
                    }
                }
                .padding(.vertical, RoutaSpacing.xs)
            } header: {
                Text("VERİ KORUMASI")
                    .font(.routaCaption2())
                    .foregroundColor(.routaTextSecondary)
            }

            // Contact Section
            Section {
                contactRow(icon: "envelope.fill", title: "E-posta", value: "privacy@routa.app", color: .blue)
                contactRow(icon: "globe", title: "Website", value: "www.routa.app/privacy", color: .purple)
                contactRow(icon: "location.fill", title: "Adres", value: "İstanbul, Türkiye", color: .orange)
            } header: {
                Text("İLETİŞİM")
                    .font(.routaCaption2())
                    .foregroundColor(.routaTextSecondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Gizlilik Politikası")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }


    private func infoBlock(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.md) {
            Text(title)
                .routaHeadline()
                .foregroundColor(.routaText)

            VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: RoutaSpacing.sm) {
                        Text("•")
                            .routaBody()
                            .foregroundColor(.routaPrimary)
                            .frame(width: 12, alignment: .leading)

                        Text(item)
                            .routaBody()
                            .foregroundColor(.routaText)
                    }
                }
            }
        }
        .padding(.vertical, RoutaSpacing.xs)
    }

    private func contactRow(icon: String, title: String, value: String, color: Color) -> some View {
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

#Preview("Privacy Policy - Light Mode") {
    NavigationStack {
        PrivacyPolicyView()
    }
    .preferredColorScheme(.light)
}

#Preview("Privacy Policy - Dark Mode") {
    NavigationStack {
        PrivacyPolicyView()
    }
    .preferredColorScheme(.dark)
}
