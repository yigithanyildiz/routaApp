import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
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
    @Environment(\.dismiss) var dismiss
    
    let mode: AuthGatewayView.AuthMode
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case fullName, email, password
    }
    
    init(mode: AuthGatewayView.AuthMode = .login) {
        self.mode = mode
    }
    
    var isSignUp: Bool {
        mode == .signup
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Dynamic background based on mode
                    backgroundView
                    
                    // Success overlay
                    if showSuccess {
                        successOverlay
                    } else {
                        // Main content
                        ScrollView {
                            VStack(spacing: 0) {
                                // Header section
                                headerSection
                                    .padding(.top, 40)
                                
                                // Form section
                                formSection
                                    .padding(.top, 30)
                                
                                Spacer(minLength: 100)
                            }
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                    
                    // Loading overlay
                    if isLoading {
                        loadingOverlay
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(isSignUp ? .white : .routaPrimary)
                }
            }
        }
        .alert("Hata", isPresented: $showAlert) {
            Button("Tamam") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            // Auto-focus first field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = isSignUp ? .fullName : .email
            }
        }
    }
    
    // MARK: - Background Views
    @ViewBuilder
    private var backgroundView: some View {
        if isSignUp {
            // Colorful gradient for signup
            LinearGradient(
                colors: [
                    Color.routaSecondary,
                    Color.routaPrimary,
                    Color.routaAccent.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .routaRotatingGradient()
        } else {
            // Clean minimal background for login
            Color.routaBackground
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 24) {
            // Icon/Image
            ZStack {
                if isSignUp {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .routaGlow(color: .white)
                } else {
                    Circle()
                        .fill(RoutaGradients.primaryGradient)
                        .frame(width: 100, height: 100)
                        .routaGlow(color: .routaPrimary)
                }
                
                Image(systemName: isSignUp ? "star.circle.fill" : "person.circle.fill")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.white)
            }
            
            // Title and subtitle
            VStack(spacing: 8) {
                Text(isSignUp ? "Maceraya Başla!" : "Tekrar Hoş Geldin!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(isSignUp ? .white : .routaPrimary)
                    .multilineTextAlignment(.center)
                
                Text(isSignUp ? "Routa ailesine katıl ve dünyanın harikalarını keşfet" : "Hesabına giriş yaparak rotalarına devam et")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSignUp ? .white.opacity(0.9) : .routaTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Form Section
    @ViewBuilder
    private var formSection: some View {
        RoutaCard(
            style: .glassmorphic,
            elevation: .floating
        ) {
            VStack(spacing: 24) {
                VStack(spacing: 20) {
                    // Full Name field (only for signup)
                    if isSignUp {
                        AuthTextField(
                            title: "Ad Soyad",
                            text: $fullName,
                            placeholder: "Adınızı ve soyadınızı girin",
                            icon: "person.fill",
                            focused: focusedField == .fullName,
                            error: fieldErrors["fullName"],
                            shake: shakeFieldName == "fullName"
                        )
                        .focused($focusedField, equals: .fullName)
                        .onSubmit {
                            focusedField = .email
                        }
                    }
                    
                    // Email field
                    AuthTextField(
                        title: "E-posta",
                        text: $email,
                        placeholder: "ornek@email.com",
                        icon: "envelope.fill",
                        keyboardType: .emailAddress,
                        focused: focusedField == .email,
                        error: fieldErrors["email"],
                        shake: shakeFieldName == "email"
                    )
                    .focused($focusedField, equals: .email)
                    .onSubmit {
                        focusedField = .password
                    }
                    
                    // Password field
                    AuthPasswordField(
                        title: "Şifre",
                        text: $password,
                        placeholder: isSignUp ? "En az 6 karakter" : "Şifrenizi girin",
                        showPassword: $showPassword,
                        focused: focusedField == .password,
                        error: fieldErrors["password"],
                        shake: shakeFieldName == "password"
                    )
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        handleAuth()
                    }
                }
                
                // Terms acceptance (only for signup)
                if isSignUp {
                    HStack {
                        RoutaToggleButton(
                            isOn: $acceptTerms,
                            onIcon: "checkmark.circle.fill",
                            offIcon: "circle",
                            size: .small
                        )
                        
                        Text("Kullanım Koşulları ve Gizlilik Politikası'nı kabul ediyorum")
                            .font(.caption)
                            .foregroundColor(.routaTextSecondary)
                        
                        Spacer()
                    }
                }
                
                // Action Button
                RoutaGradientButton(
                    isSignUp ? "Hesap Oluştur" : "Giriş Yap",
                    icon: isSignUp ? "person.badge.plus" : "arrow.right.circle.fill",
                    gradient: isSignUp ? RoutaGradients.secondaryGradient : RoutaGradients.primaryGradient,
                    size: .large,
                    isDisabled: !isFormValid,
                    isLoading: isLoading
                ) {
                    handleAuth()
                }
                
                // Forgot password (only for login)
                if !isSignUp {
                    Button("Şifremi Unuttum") {
                        // Handle forgot password
                    }
                    .font(.callout)
                    .foregroundColor(.routaPrimary)
                }
                
                // Social login buttons (prepared but inactive)
                if !isSignUp {
                    VStack(spacing: 12) {
                        HStack {
                            Rectangle()
                                .fill(Color.routaBorder)
                                .frame(height: 1)
                            Text("veya")
                                .font(.caption)
                                .foregroundColor(.routaTextSecondary)
                            Rectangle()
                                .fill(Color.routaBorder)
                                .frame(height: 1)
                        }
                        
                        HStack(spacing: 16) {
                            SocialLoginButton(icon: "applelogo", title: "Apple", color: .black)
                            SocialLoginButton(icon: "globe", title: "Google", color: .routaSecondary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Success Overlay
    @ViewBuilder
    private var successOverlay: some View {
        ZStack {
            Color.routaBackground
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Success animation
                ZStack {
                    Circle()
                        .fill(RoutaGradients.primaryGradient)
                        .frame(width: 120, height: 120)
                        .routaGlow(color: .routaSuccess, radius: 30)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .routaPulse(minScale: 0.95, maxScale: 1.05, duration: 1.0)
                }
                
                VStack(spacing: 8) {
                    Text("Başarıyla " + (isSignUp ? "kayıt oldunuz!" : "giriş yapıldı!"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.routaSuccess)
                    
                    Text(isSignUp ? "Routa'ya hoş geldiniz!" : "Rotalarınıza devam edebilirsiniz")
                        .font(.body)
                        .foregroundColor(.routaTextSecondary)
                }
            }
        }
    }
    
    // MARK: - Loading Overlay
    @ViewBuilder
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            RoutaCard(style: .glassmorphic) {
                VStack(spacing: 16) {
                    RoutaLoadingView(size: 60)
                    Text(isSignUp ? "Hesabınız oluşturuluyor..." : "Giriş yapılıyor...")
                        .font(.callout)
                        .foregroundColor(.routaTextSecondary)
                }
            }
            .frame(width: 200, height: 120)
        }
    }
    
    // MARK: - Helper Properties
    private var isFormValid: Bool {
        if isSignUp {
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
        
        if isSignUp && fullName.isEmpty {
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
        
        if isSignUp && !acceptTerms {
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
                    
                    // Auto dismiss after success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                    
                case .failure(let error):
                    RoutaHapticsManager.shared.error()
                    handleAuthError(error)
                }
            }
        }
        
        if isSignUp {
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
            alertMessage = isSignUp ? "Hesap oluşturma hatası: \(errorMessage)" : "Giriş hatası: \(errorMessage)"
            showAlert = true
        }
    }
}

// MARK: - Supporting Views

struct AuthTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    let focused: Bool
    let error: String?
    let shake: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.routaPrimary)
            
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(error != nil ? .routaError : (focused ? .routaPrimary : .routaTextSecondary))
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .font(.body)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.routaSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                error != nil ? Color.routaError : (focused ? Color.routaPrimary : Color.routaBorder),
                                lineWidth: error != nil ? 2 : (focused ? 2 : 1)
                            )
                    )
            )
            .routaShake(amount: shake ? 10 : 0)
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.routaError)
            }
        }
    }
}

struct AuthPasswordField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    @Binding var showPassword: Bool
    let focused: Bool
    let error: String?
    let shake: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.routaPrimary)
            
            HStack {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(error != nil ? .routaError : (focused ? .routaPrimary : .routaTextSecondary))
                    .frame(width: 20)
                
                Group {
                    if showPassword {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .font(.body)
                
                Button(action: {
                    showPassword.toggle()
                    RoutaHapticsManager.shared.buttonTap()
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.routaTextSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.routaSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                error != nil ? Color.routaError : (focused ? Color.routaPrimary : Color.routaBorder),
                                lineWidth: error != nil ? 2 : (focused ? 2 : 1)
                            )
                    )
            )
            .routaShake(amount: shake ? 10 : 0)
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.routaError)
            }
        }
    }
}

struct SocialLoginButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Social login action - placeholder
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.callout)
                    .fontWeight(.medium)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(true) // Disabled for now
        .opacity(0.6)
    }
}

#Preview {
    AuthView(mode: .login)
        .environmentObject(AuthManager())
}
