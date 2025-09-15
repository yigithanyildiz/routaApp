import SwiftUI

struct LoginPromptSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var showAuthView = false
    @State private var selectedAuthMode: AuthGatewayView.AuthMode = .login
    
    let title: String
    let message: String
    let primaryActionTitle: String
    let onContinueAsGuest: (() -> Void)?
    
    init(
        title: String = "Giriş Gerekli",
        message: String = "Bu özelliği kullanmak için giriş yapmalısınız.",
        primaryActionTitle: String = "Giriş Yap",
        onContinueAsGuest: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryActionTitle = primaryActionTitle
        self.onContinueAsGuest = onContinueAsGuest
    }
    
    var body: some View {
        NavigationView {
            RoutaCard(style: .glassmorphic, elevation: .floating) {
                VStack(spacing: RoutaSpacing.xl) {
                    // Header Section
                    VStack(spacing: RoutaSpacing.md) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(RoutaGradients.primaryGradient)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        // Title
                        Text(title)
                            .routaTitle2()
                            .foregroundColor(.routaText)
                            .multilineTextAlignment(.center)
                        
                        // Message
                        Text(message)
                            .routaBody()
                            .foregroundColor(.routaTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, RoutaSpacing.md)
                    }
                    
                    // Action Buttons
                    VStack(spacing: RoutaSpacing.md) {
                        // Login Button
                        RoutaGradientButton(
                            primaryActionTitle,
                            icon: "person.circle.fill",
                            gradient: RoutaGradients.primaryGradient,
                            size: .large
                        ) {
                            RoutaHapticsManager.shared.buttonTap()
                            selectedAuthMode = .login
                            showAuthView = true
                        }
                        
                        // Sign Up Button
                        RoutaButton(
                            "Hesap Oluştur",
                            icon: "person.badge.plus",
                            variant: .secondary,
                            size: .large
                        ) {
                            RoutaHapticsManager.shared.buttonTap()
                            selectedAuthMode = .signup
                            showAuthView = true
                        }
                        
                        // Continue as Guest (if provided)
                        if let onContinueAsGuest = onContinueAsGuest {
                            Button(action: {
                                RoutaHapticsManager.shared.buttonTap()
                                onContinueAsGuest()
                                dismiss()
                            }) {
                                HStack(spacing: RoutaSpacing.sm) {
                                    Image(systemName: "person.slash")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Misafir Olarak Devam Et")
                                        .routaCallout()
                                }
                                .foregroundColor(.routaTextSecondary)
                                .padding(.vertical, RoutaSpacing.sm)
                            }
                        }
                        
                        // Cancel Button
                        Button("İptal") {
                            RoutaHapticsManager.shared.buttonTap()
                            dismiss()
                        }
                        .font(.routaCallout())
                        .foregroundColor(Color.routaTextSecondary)
                        .padding(.top, RoutaSpacing.sm)
                    }
                }
                .padding(RoutaSpacing.xl)
            }
            .padding(RoutaSpacing.lg)
            .background(Color.routaBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.routaPrimary)
                }
            }
        }
        .sheet(isPresented: $showAuthView) {
            AuthView(mode: selectedAuthMode)
                .environmentObject(authManager)
        }
        .onChange(of: authManager.user) { _, newUser in
            if newUser != nil {
                // Delay dismissal by 0.5 seconds to show success state
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Convenience Initializers

extension LoginPromptSheet {
    static func favoritePrompt(onContinueAsGuest: (() -> Void)? = nil) -> LoginPromptSheet {
        LoginPromptSheet(
            title: "Favorilere Ekle",
            message: "Favori destinasyonlarını kaydetmek ve tüm cihazlarında senkronize etmek için giriş yap.",
            primaryActionTitle: "Giriş Yap",
            onContinueAsGuest: onContinueAsGuest
        )
    }
    
    static func routeSavePrompt(onContinueAsGuest: (() -> Void)? = nil) -> LoginPromptSheet {
        LoginPromptSheet(
            title: "Rotayı Kaydet",
            message: "Rotalarını kaydetmek ve daha sonra erişmek için giriş yap.",
            primaryActionTitle: "Giriş Yap",
            onContinueAsGuest: onContinueAsGuest
        )
    }
    
    static func profilePrompt() -> LoginPromptSheet {
        LoginPromptSheet(
            title: "Profil Özellikleri",
            message: "Profil özelliklerini kullanmak için giriş yapmalısın.",
            primaryActionTitle: "Giriş Yap",
            onContinueAsGuest: nil
        )
    }
}

#Preview {
    LoginPromptSheet.favoritePrompt()
        .previewEnvironment(authenticated: false)
}
