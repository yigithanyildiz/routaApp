import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RoutaSpacing.lg) {
                    headerSection
                    
                    VStack(spacing: RoutaSpacing.xl) {
                        termsSection
                        userResponsibilitiesSection
                        limitationsSection
                        updatesSection
                    }
                }
                .padding(.horizontal, RoutaSpacing.lg)
                .padding(.bottom, 90)
            }
            .navigationTitle("Kullanım Koşulları")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.routaBackground)
          
        }
    }
    
    private var headerSection: some View {
        RoutaCard(style: .glassmorphic, elevation: .medium) {
            VStack(spacing: RoutaSpacing.md) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.routaSecondary)
                
                Text("Kullanım Koşulları")
                    .routaTitle2()
                    .foregroundColor(.routaText)
                    .multilineTextAlignment(.center)
                
                Text("Yürürlük tarihi: \(Date().formatted(date: .abbreviated, time: .omitted))")
                    .routaCaption1()
                    .foregroundColor(.routaTextSecondary)
                    .padding(.horizontal, RoutaSpacing.md)
            }
            .padding(RoutaSpacing.lg)
        }
        .padding(.top, RoutaSpacing.md)
    }
    
    private var termsSection: some View {
        RoutaCard(style: .standard, elevation: .low) {
            VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                Text("Genel Koşullar")
                    .routaTitle3()
                    .foregroundColor(.routaText)
                
                VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                    Text("Bu kullanım koşulları, Routa mobil uygulamasını kullanımınızı düzenler. Uygulamayı kullanarak bu koşulları kabul etmiş sayılırsınız.")
                        .routaBody()
                        .foregroundColor(.routaText)
                    
                    VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                        bulletPoint("Uygulama 13 yaş üstü kullanıcılar içindir")
                        bulletPoint("Hesap bilgilerinizin doğruluğundan siz sorumlusunuz")
                        bulletPoint("Uygulamayı yasal olmayan amaçlarla kullanamazsınız")
                        bulletPoint("İçeriğimizi izinsiz kopyalayamaz veya dağıtamazsınız")
                    }
                }
            }
            .padding(RoutaSpacing.lg)
        }
    }
    
    private var userResponsibilitiesSection: some View {
        RoutaCard(style: .standard, elevation: .low) {
            VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                Text("Kullanıcı Sorumlulukları")
                    .routaTitle3()
                    .foregroundColor(.routaText)
                
                VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                    Text("Routa kullanırken aşağıdaki kurallara uymanız gerekmektedir:")
                        .routaBody()
                        .foregroundColor(.routaText)
                    
                    VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                        bulletPoint("Hesap güvenliğinizi koruyun ve şifrenizi paylaşmayın")
                        bulletPoint("Yanlış veya yanıltıcı bilgi paylaşmayın")
                        bulletPoint("Diğer kullanıcılara saygı gösterin")
                        bulletPoint("Spam veya zararlı içerik göndermezsiniz")
                        bulletPoint("Seyahat planlarınızın sorumluluğu size aittir")
                    }
                    
                    Text("Bu kurallara uymayan hesaplar askıya alınabilir veya silinebilir.")
                        .routaBodyEmphasized()
                        .foregroundColor(.routaWarning)
                        .padding(.top, RoutaSpacing.sm)
                }
            }
            .padding(RoutaSpacing.lg)
        }
    }
    
    private var limitationsSection: some View {
        RoutaCard(style: .standard, elevation: .low) {
            VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                Text("Sorumluluk Sınırları")
                    .routaTitle3()
                    .foregroundColor(.routaText)
                
                VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                    Text("Routa kullanımı sırasında aşağıdaki hususları göz önünde bulundurun:")
                        .routaBody()
                        .foregroundColor(.routaText)
                    
                    VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                        bulletPoint("Uygulama \"olduğu gibi\" sunulur, garanti verilmez")
                        bulletPoint("Seyahat önerileri sadece bilgilendirme amaçlıdır")
                        bulletPoint("Üçüncü taraf hizmetlerden sorumlu değiliz")
                        bulletPoint("Uygulama kesintileri yaşanabilir")
                        bulletPoint("Verilerinizi düzenli olarak yedeklemenizi öneririz")
                    }
                    
                    Text("Seyahat kararlarınızı verirken güncel bilgileri kontrol etmek size aittir.")
                        .routaCallout()
                        .foregroundColor(.routaTextSecondary)
                        .padding(.top, RoutaSpacing.sm)
                        .italic()
                }
            }
            .padding(RoutaSpacing.lg)
        }
    }
    
    private var updatesSection: some View {
        RoutaCard(style: .standard, elevation: .low) {
            VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                Text("Güncellemeler ve İletişim")
                    .routaTitle3()
                    .foregroundColor(.routaText)
                
                VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                    Text("Bu kullanım koşulları zaman zaman güncellenebilir. Önemli değişiklikler hakkında bilgilendirileceksiniz.")
                        .routaBody()
                        .foregroundColor(.routaText)
                    
                    Text("Sorularınız için bizimle iletişime geçebilirsiniz:")
                        .routaBody()
                        .foregroundColor(.routaText)
                        .padding(.top, RoutaSpacing.sm)
                    
                    VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                        contactRow(icon: "envelope.fill", text: "legal@routa.app")
                        contactRow(icon: "phone.fill", text: "+90 (212) 555-0123")
                        contactRow(icon: "building.2.fill", text: "Routa Teknoloji A.Ş.")
                        contactRow(icon: "location.fill", text: "Maslak, İstanbul")
                    }
                    .padding(.top, RoutaSpacing.sm)
                    
                    Text("Son güncelleme tarihi: \(Date().formatted(date: .complete, time: .omitted))")
                        .routaCaption2()
                        .foregroundColor(.routaTextSecondary)
                        .padding(.top, RoutaSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(RoutaSpacing.lg)
        }
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: RoutaSpacing.sm) {
            Text("•")
                .routaBody()
                .foregroundColor(.routaSecondary)
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
                .foregroundColor(.routaSecondary)
                .frame(width: 20, alignment: .leading)
            
            Text(text)
                .routaCallout()
                .foregroundColor(.routaTextSecondary)
        }
    }
}

#Preview {
    TermsOfServiceView()
        .previewEnvironment(authenticated: false)
}
