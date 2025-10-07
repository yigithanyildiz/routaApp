import SwiftUI

struct AuthGatewayView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var authMode: AuthMode = .login
    @State private var animateEntrance = false
    @State private var isGuestLoading = false
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showPassword = false
    @State private var acceptTerms = false
    @State private var showSuccess = false
    @State private var fieldErrors: [String: String] = [:]
    @State private var shakeFieldName: String? = nil
    @State private var isShaking = false
    @State private var showingTermsOfService = false
    @State private var showingPrivacyPolicy = false

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case fullName, email, password
    }
    
    enum AuthMode {
        case login
        case signup
    }
    
    var body: some View {
        ZStack {
            // Dark gradient background matching design
            RoutaGradients.darkBackgroundGradient
                .ignoresSafeArea()
            
            
                VStack(spacing: 24) {
                        Spacer(minLength: 40)

                        // Hero Card with mountain image aesthetic - reduced height
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.25, green: 0.35, blue: 0.45).opacity(0.8),
                                            Color(red: 0.15, green: 0.25, blue: 0.35).opacity(0.9)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 160)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 15, y: 8)

                            VStack(spacing: 8) {
                                Text("Routa")
                                    .font(.system(size: 42, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .white.opacity(0.9)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 6, y: 3)

                                Text("Your smart travel companion")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }
                        .scaleEffect(animateEntrance ? 1.0 : 0.95)
                        .opacity(animateEntrance ? 1.0 : 0.0)
                        .padding(.horizontal, 24)
                    
                    // Tab Selector with modern design
                    HStack(spacing: 0) {
                        TabButton(
                            title: "Login",
                            isSelected: authMode == .login,
                            action: { authMode = .login }
                        )
                        
                        TabButton(
                            title: "Sign Up",
                            isSelected: authMode == .signup,
                            action: { authMode = .signup }
                        )
                    }
                    .frame(height: 50)
                    .padding(.horizontal, 24)
                    .scaleEffect(animateEntrance ? 1.0 : 0.95)
                    .opacity(animateEntrance ? 1.0 : 0.0)
                    
                    // Auth Form
                    VStack(spacing: 16) {
                        // Full Name field (only for signup)
                        if authMode == .signup {
                            VStack(alignment: .leading, spacing: 3) {
                                CustomTextField(
                                    icon: "person.fill",
                                    placeholder: "Ad Soyad",
                                    text: $fullName
                                )
                                .focused($focusedField, equals: .fullName)
                                .onSubmit {
                                    focusedField = .email
                                }
                                .offset(x: shakeFieldName == "fullName" ? (isShaking ? 5 : 0) : 0)

                                if let error = fieldErrors["fullName"] {
                                    Text(error)
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                        .padding(.leading, 16)
                                }
                            }
                        }

                        // Email field
                        VStack(alignment: .leading, spacing: 3) {
                            CustomTextField(
                                icon: "envelope.fill",
                                placeholder: "E-posta",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            .focused($focusedField, equals: .email)
                            .onSubmit {
                                focusedField = .password
                            }
                            .offset(x: shakeFieldName == "email" ? (isShaking ? 5 : 0) : 0)

                            if let error = fieldErrors["email"] {
                                Text(error)
                                    .font(.caption2)
                                    .foregroundColor(.red)
                                    .padding(.leading, 16)
                            }
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 3) {
                            CustomSecureField(
                                icon: "lock.fill",
                                placeholder: authMode == .login ? "Şifre" : "En az 6 karakter",
                                text: $password
                            )
                            .focused($focusedField, equals: .password)
                            .onSubmit {
                                handleAuth()
                            }
                            .offset(x: shakeFieldName == "password" ? (isShaking ? 5 : 0) : 0)

                            if let error = fieldErrors["password"] {
                                Text(error)
                                    .font(.caption2)
                                    .foregroundColor(.red)
                                    .padding(.leading, 16)
                            }
                        }

                        // Terms acceptance (only for signup)
                        if authMode == .signup {
                            HStack(alignment: .top, spacing: 8) {
                                Button(action: {
                                    acceptTerms.toggle()
                                    RoutaHapticsManager.shared.buttonTap()
                                }) {
                                    Image(systemName: acceptTerms ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(acceptTerms ? Color(red: 0.13, green: 0.59, blue: 0.95) : .white.opacity(0.6))
                                        .font(.system(size: 18))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 4) {
                                        Button(action: {
                                            showingTermsOfService = true
                                            RoutaHapticsManager.shared.buttonTap()
                                        }) {
                                            Text("Kullanım Koşulları")
                                                .font(.caption)
                                                .foregroundColor(Color(red: 0.13, green: 0.59, blue: 0.95))
                                                .underline()
                                        }

                                        Text("ve")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))

                                        Button(action: {
                                            showingPrivacyPolicy = true
                                            RoutaHapticsManager.shared.buttonTap()
                                        }) {
                                            Text("Gizlilik Politikası")
                                                .font(.caption)
                                                .foregroundColor(Color(red: 0.13, green: 0.59, blue: 0.95))
                                                .underline()
                                        }
                                    }

                                    Button(action: {
                                        acceptTerms.toggle()
                                        RoutaHapticsManager.shared.buttonTap()
                                    }) {
                                        Text("'nı kabul ediyorum")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }

                                Spacer()
                            }
                        }

                        // Auth Button
                        Button(action: {
                            handleAuth()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(authMode == .login ? "Giriş Yap" : "Hesap Oluştur")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.13, green: 0.59, blue: 0.95),
                                        Color(red: 0.1, green: 0.47, blue: 0.82)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color(red: 0.13, green: 0.59, blue: 0.95).opacity(0.4), radius: 12, y: 6)
                        }
                        .disabled(isLoading || !isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .scaleEffect(animateEntrance ? 1.0 : 0.95)
                    .opacity(animateEntrance ? 1.0 : 0.0)
                    
                    // Divider
                    Text("Or continue with")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.vertical, 12)
                        .scaleEffect(animateEntrance ? 1.0 : 0.95)
                        .opacity(animateEntrance ? 0.8 : 0.0)
                    
                    // Social Login Buttons
                    HStack(spacing: 16) {
                        SocialButton(icon: "apple.logo", title: "Apple") {
                            // Apple Sign-In will be implemented later
                        }
                        SocialButton(icon: "ios_light", title: "Google") {
                            handleGoogleSignIn()
                        }
                    }
                    .padding(.horizontal, 24)
                    .scaleEffect(animateEntrance ? 1.0 : 0.95)
                    .opacity(animateEntrance ? 1.0 : 0.0)
                    
                    // Guest Button
                    Button(action: {
                        RoutaHapticsManager.shared.buttonTap()
                        isGuestLoading = true
                        
                        authManager.continueAsGuest {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isGuestLoading = false
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            if isGuestLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.7)))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "person.slash")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            Text("Misafir Olarak Devam Et")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.vertical, 16)
                    }
                    .disabled(isGuestLoading)
                    .scaleEffect(animateEntrance ? 1.0 : 0.95)
                    .opacity(animateEntrance ? 0.7 : 0.0)
                    
                    Spacer(minLength: 20)
                }
            
        }
        .alert("Hata", isPresented: $showAlert) {
            Button("Tamam") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingTermsOfService) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                animateEntrance = true
            }

            // Auto-focus first field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                focusedField = authMode == .signup ? .fullName : .email
            }
        }
    }

    // MARK: - Helper Properties
    private var isFormValid: Bool {
        if authMode == .signup {
            return !fullName.isEmpty && isValidEmail(email) && password.count >= 6 && acceptTerms
        } else {
            return isValidEmail(email) && !password.isEmpty
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }

    // MARK: - Actions
    private func handleAuth() {
        // Clear previous errors
        fieldErrors.removeAll()

        // Validate fields
        var hasErrors = false

        if authMode == .signup && fullName.isEmpty {
            fieldErrors["fullName"] = "Ad soyad gerekli"
            triggerShakeAnimation("fullName")
            hasErrors = true
        }

        if !isValidEmail(email) {
            fieldErrors["email"] = "Geçerli bir e-posta adresi girin"
            triggerShakeAnimation("email")
            hasErrors = true
        }

        if password.count < 6 {
            fieldErrors["password"] = "Şifre en az 6 karakter olmalı"
            triggerShakeAnimation("password")
            hasErrors = true
        }

        if authMode == .signup && !acceptTerms {
            // Show alert for terms
            alertMessage = "Lütfen kullanım koşullarını kabul edin"
            showAlert = true
            return
        }

        if hasErrors {
            RoutaHapticsManager.shared.error()
            return
        }

        // Proceed with authentication
        isLoading = true
        focusedField = nil

        let completion: (Result<Void, Error>) -> Void = { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    RoutaHapticsManager.shared.success()
                    showSuccess = true

                case .failure(let error):
                    RoutaHapticsManager.shared.error()
                    handleAuthError(error)
                }
            }
        }

        if authMode == .signup {
            authManager.signUp(email: email, password: password, fullName: fullName, completion: completion)
        } else {
            authManager.signIn(email: email, password: password, completion: completion)
        }
    }

    private func triggerShakeAnimation(_ fieldName: String) {
        withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
            shakeFieldName = fieldName
            isShaking = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            shakeFieldName = nil
            isShaking = false
        }
    }

    private func handleAuthError(_ error: Error) {
        let errorMessage = error.localizedDescription

        if errorMessage.contains("email") {
            if errorMessage.contains("already") {
                fieldErrors["email"] = "Bu e-posta zaten kayıtlı"
                triggerShakeAnimation("email")
            } else {
                fieldErrors["email"] = "E-posta hatalı"
                triggerShakeAnimation("email")
            }
        } else if errorMessage.contains("password") {
            fieldErrors["password"] = "Şifre hatalı"
            triggerShakeAnimation("password")
        } else {
            alertMessage = authMode == .signup ? "Hesap oluşturma hatası: \(errorMessage)" : "Giriş hatası: \(errorMessage)"
            showAlert = true
        }
    }

    // MARK: - Google Sign-In
    private func handleGoogleSignIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            alertMessage = "Google ile giriş yapılamadı. Lütfen tekrar deneyin."
            showAlert = true
            return
        }

        isLoading = true

        authManager.signInWithGoogle(presenting: rootViewController) { [self] result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    RoutaHapticsManager.shared.success()
                    showSuccess = true
                case .failure(let error):
                    RoutaHapticsManager.shared.error()
                    alertMessage = "Google ile giriş hatası: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [
                                    Color(red: 0.13, green: 0.59, blue: 0.95),
                                    Color(red: 0.1, green: 0.47, blue: 0.82)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        } else {
                            Color.clear
                        }
                    }
                )
                .cornerRadius(12)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Social Button Component
struct SocialButton: View {
    let icon: String
    let title: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            RoutaHapticsManager.shared.buttonTap()
            action?()
        }) {
            HStack(spacing: 10) {
                Group {
                    if icon.contains("apple") {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .medium))
                    } else {
                        Image(icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 23, height: 23)
                    }
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
        }
    }
}


// MARK: - Custom TextField
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 20)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 16))
                }
                TextField("", text: $text)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .autocapitalization(.none)
                    .keyboardType(keyboardType)
                    .tint(Color(red: 0.13, green: 0.59, blue: 0.95))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

// MARK: - Custom SecureField
struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 20)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 16))
                }
                SecureField("", text: $text)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .tint(Color(red: 0.13, green: 0.59, blue: 0.95))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
#Preview {
    AuthGatewayView()
        .environmentObject(AuthManager())
}
