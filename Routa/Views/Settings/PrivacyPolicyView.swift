import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RoutaSpacing.lg) {
                    headerSection
                    
                    VStack(spacing: RoutaSpacing.xl) {
                        dataCollectionSection
                        dataUsageSection
                        dataProtectionSection
                        contactInfoSection
                    }
                }
                .padding(.horizontal, RoutaSpacing.lg)
                .padding(.bottom, 90)
            }
            .navigationTitle("Gizlilik Politikası")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.routaBackground)
          
        }
    }
    
    private var headerSection: some View {
        RoutaCard(style: .glassmorphic, elevation: .medium) {
            VStack(spacing: RoutaSpacing.md) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.routaPrimary)
                
                Text("Gizlilik Politikası")
                    .routaTitle2()
                    .foregroundColor(.routaText)
                    .multilineTextAlignment(.center)
                
                Text("Son güncellenme: \(Date().formatted(date: .abbreviated, time: .omitted))")
                    .routaCaption1()
                    .foregroundColor(.routaTextSecondary)
                    .padding(.horizontal, RoutaSpacing.md)
            }
            .padding(RoutaSpacing.lg)
        }
        .padding(.top, RoutaSpacing.md)
    }
    
    private var dataCollectionSection: some View {
        RoutaCard(style: .standard, elevation: .low) {
            VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                Text("Veri Toplama")
                    .routaTitle3()
                    .foregroundColor(.routaText)
                
                VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                    Text("Routa olarak, size daha iyi hizmet verebilmek için aşağıdaki verileri topluyoruz:")
                        .routaBody()
                        .foregroundColor(.routaText)
                    
                    VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                        bulletPoint("Hesap bilgileriniz (ad, e-posta)")
                        bulletPoint("Seyahat tercihleriniz ve favori destinasyonlar")
                        bulletPoint("Uygulama kullanım istatistikleri")
                        bulletPoint("Cihaz bilgileri (model, işletim sistemi)")
                    }
                }
            }
            .padding(RoutaSpacing.lg)
        }
    }
    
    private var dataUsageSection: some View {
        RoutaCard(style: .standard, elevation: .low) {
            VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                Text("Veri Kullanımı")
                    .routaTitle3()
                    .foregroundColor(.routaText)
                
                VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                    Text("Topladığımız veriler yalnızca şu amaçlarla kullanılır:")
                        .routaBody()
                        .foregroundColor(.routaText)
                    
                    VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                        bulletPoint("Kişiselleştirilmiş seyahat önerileri sunmak")
                        bulletPoint("Uygulama performansını iyileştirmek")
                        bulletPoint("Müşteri desteği sağlamak")
                        bulletPoint("Güvenlik ve dolandırıcılık önleme")
                    }
                    
                    Text("Verilerinizi üçüncü taraflarla paylaşmıyoruz veya satmıyoruz.")
                        .routaBodyEmphasized()
                        .foregroundColor(.routaPrimary)
                        .padding(.top, RoutaSpacing.sm)
                }
            }
            .padding(RoutaSpacing.lg)
        }
    }
    
    private var dataProtectionSection: some View {
        RoutaCard(style: .standard, elevation: .low) {
            VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                Text("Veri Koruması")
                    .routaTitle3()
                    .foregroundColor(.routaText)
                
                VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                    Text("Verilerinizin güvenliği bizim için önceliklidir:")
                        .routaBody()
                        .foregroundColor(.routaText)
                    
                    VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                        bulletPoint("Veriler şifrelenmiş olarak saklanır")
                        bulletPoint("Güvenli sunucularda barındırılır")
                        bulletPoint("Düzenli güvenlik denetimleri yapılır")
                        bulletPoint("GDPR ve KVKK uyumlu veri işleme")
                    }
                    
                    Text("Hesabınızı silmeniz durumunda tüm kişisel verileriniz kalıcı olarak silinir.")
                        .routaCallout()
                        .foregroundColor(.routaTextSecondary)
                        .padding(.top, RoutaSpacing.sm)
                        .italic()
                }
            }
            .padding(RoutaSpacing.lg)
        }
    }
    
    private var contactInfoSection: some View {
        RoutaCard(style: .standard, elevation: .low) {
            VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                Text("İletişim")
                    .routaTitle3()
                    .foregroundColor(.routaText)
                
                VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                    Text("Gizlilik politikamız hakkında sorularınız varsa bizimle iletişime geçebilirsiniz:")
                        .routaBody()
                        .foregroundColor(.routaText)
                    
                    VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                        contactRow(icon: "envelope.fill", text: "privacy@routa.app")
                        contactRow(icon: "globe", text: "www.routa.app/privacy")
                        contactRow(icon: "location.fill", text: "İstanbul, Türkiye")
                    }
                    .padding(.top, RoutaSpacing.sm)
                }
            }
            .padding(RoutaSpacing.lg)
        }
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: RoutaSpacing.sm) {
            Text("•")
                .routaBody()
                .foregroundColor(.routaPrimary)
                .frame(width: 12, alignment: .leading)
            
            Text(text)
                .routaBody()
                .foregroundColor(.routaText)
        }
    }
    
    private func contactRow(icon: String, text: String) -> some View {
        HStack(spacing: RoutaSpacing.sm) {
            Image(systemName: icon)
                .font(.routaCaption1())
                .foregroundColor(.routaPrimary)
                .frame(width: 20, alignment: .leading)
            
            Text(text)
                .routaCallout()
                .foregroundColor(.routaTextSecondary)
        }
    }
}

#Preview {
    PrivacyPolicyView()
        .previewEnvironment(authenticated: false)
}
