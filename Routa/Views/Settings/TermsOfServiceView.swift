import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var themeManager = RoutaThemeManager.shared

    var body: some View {
        List {
            // Hero Section
            Section {
                VStack(spacing: RoutaSpacing.lg) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                            .routaShadow(.medium, style: .colored(.indigo))

                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    .padding(.top, RoutaSpacing.sm)

                    VStack(spacing: RoutaSpacing.xs) {
                        Text("Kullanım Koşulları")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.routaText)
                            .multilineTextAlignment(.center)

                        Text("Yürürlük tarihi: \(Date().formatted(date: .abbreviated, time: .omitted))")
                            .routaCaption1()
                            .foregroundColor(.routaTextSecondary)
                    }

                    Text("Routa'yı kullanarak bu koşulları kabul etmiş olursunuz")
                        .routaBody()
                        .foregroundColor(.routaTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, RoutaSpacing.sm)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }

            // General Terms Section
            Section {
                infoBlock(
                    title: "Genel Koşullar",
                    items: [
                        "Uygulama 13 yaş üstü kullanıcılar içindir",
                        "Hesap bilgilerinizin doğruluğundan siz sorumlusunuz",
                        "Uygulamayı yasal olmayan amaçlarla kullanamazsınız",
                        "İçeriğimizi izinsiz kopyalayamaz veya dağıtamazsınız"
                    ]
                )
            } header: {
                Text("GENEL KURALLAR")
                    .font(.routaCaption2())
                    .foregroundColor(.routaTextSecondary)
            }

            // User Responsibilities Section
            Section {
                infoBlock(
                    title: "Sorumluluklarınız",
                    items: [
                        "Hesap güvenliğinizi koruyun ve şifrenizi paylaşmayın",
                        "Yanlış veya yanıltıcı bilgi paylaşmayın",
                        "Diğer kullanıcılara saygı gösterin",
                        "Spam veya zararlı içerik göndermezsiniz",
                        "Seyahat planlarınızın sorumluluğu size aittir"
                    ]
                )

                VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                    HStack(spacing: RoutaSpacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.routaWarning)

                        Text("Bu kurallara uymayan hesaplar askıya alınabilir veya silinebilir.")
                            .routaCallout()
                            .foregroundColor(.routaText)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.vertical, RoutaSpacing.xs)
            } header: {
                Text("KULLANICI SORUMLULUKLARI")
                    .font(.routaCaption2())
                    .foregroundColor(.routaTextSecondary)
            }

            // Limitations Section
            Section {
                infoBlock(
                    title: "Sorumluluk Sınırları",
                    items: [
                        "Uygulama \"olduğu gibi\" sunulur, garanti verilmez",
                        "Seyahat önerileri sadece bilgilendirme amaçlıdır",
                        "Üçüncü taraf hizmetlerden sorumlu değiliz",
                        "Uygulama kesintileri yaşanabilir",
                        "Verilerinizi düzenli olarak yedeklemenizi öneririz"
                    ]
                )

                VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                    HStack(spacing: RoutaSpacing.sm) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.routaAccent)

                        Text("Seyahat kararlarınızı verirken güncel bilgileri kontrol etmek size aittir.")
                            .routaCallout()
                            .foregroundColor(.routaTextSecondary)
                            .italic()
                    }
                }
                .padding(.vertical, RoutaSpacing.xs)
            } header: {
                Text("SORUMLULUK SINIRLARI")
                    .font(.routaCaption2())
                    .foregroundColor(.routaTextSecondary)
            }

            // Updates and Contact Section
            Section {
                VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                    Text("Güncellemeler")
                        .routaHeadline()
                        .foregroundColor(.routaText)

                    Text("Bu kullanım koşulları zaman zaman güncellenebilir. Önemli değişiklikler hakkında bilgilendirileceksiniz.")
                        .routaBody()
                        .foregroundColor(.routaText)
                }
                .padding(.vertical, RoutaSpacing.xs)
            } header: {
                Text("GÜNCELLEMELER")
                    .font(.routaCaption2())
                    .foregroundColor(.routaTextSecondary)
            }

            // Contact Section
            Section {
                contactRow(icon: "envelope.fill", title: "E-posta", value: "legal@routa.app", color: .blue)
                contactRow(icon: "phone.fill", title: "Telefon", value: "+90 (212) 555-0123", color: .green)
                contactRow(icon: "building.2.fill", title: "Şirket", value: "Routa Teknoloji A.Ş.", color: .purple)
                contactRow(icon: "location.fill", title: "Adres", value: "Maslak, İstanbul", color: .orange)
            } header: {
                Text("İLETİŞİM")
                    .font(.routaCaption2())
                    .foregroundColor(.routaTextSecondary)
            }

            // Footer
            Section {
                VStack(spacing: RoutaSpacing.xs) {
                    Text("Son güncelleme tarihi:")
                        .routaCaption2()
                        .foregroundColor(.routaTextSecondary)

                    Text(Date().formatted(date: .complete, time: .omitted))
                        .routaCaption1()
                        .foregroundColor(.routaText)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, RoutaSpacing.sm)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Kullanım Koşulları")
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
                            .foregroundColor(.routaSecondary)
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

#Preview("Terms of Service - Light Mode") {
    NavigationStack {
        TermsOfServiceView()
    }
    .preferredColorScheme(.light)
}

#Preview("Terms of Service - Dark Mode") {
    NavigationStack {
        TermsOfServiceView()
    }
    .preferredColorScheme(.dark)
}
