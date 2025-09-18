import SwiftUI
import StoreKit
import MessageUI

// MARK: - Modern ProfileView with RoutaDesignSystem
struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @StateObject private var themeManager = RoutaThemeManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dependencyContainer: DependencyContainer
    
    @State private var showingAbout = false
    @State private var showingNotificationSettings = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingHelp = false
    @State private var showingLanguageSelection = false
    @State private var showingMailComposer = false
    @State private var showingDeleteConfirmation = false
    @State private var isRefreshing = false
    @State private var showingAuthView = false
    @State private var showingGuestPrompt = false
    @State private var showingFavoritesList = false
    @State private var selectedAuthMode: AuthGatewayView.AuthMode = .login
    
    var body: some View {
        ScrollView {
            VStack(spacing: RoutaSpacing.xl) {
                heroHeaderSection
                if authManager.isAuthenticated {
                    userInfoCard
                    favoritesSection
                }
                settingsSection
                legalSection
                accountManagementSection
                authSection
            }
            .padding(.bottom, LayoutConstants.tabBarHeight)
        }
        .background(Color.routaBackground)
        .dynamicIslandBlur()
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await refreshProfile()
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingTermsOfService) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
        .sheet(isPresented: $showingLanguageSelection) {
            LanguageSelectionView()
        }
        .sheet(isPresented: $showingMailComposer) {
            MailComposerView()
        }
        .sheet(isPresented: $showingAuthView) {
            AuthView(mode: selectedAuthMode)
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingFavoritesList) {
            FavoritesView()
                .environmentObject(authManager)
                .environmentObject(dependencyContainer)
        }
        .overlay {
            if showingGuestPrompt {
                GuestPromptView(isPresented: $showingGuestPrompt)
            }
        }
        .alert("Hesabı Sil", isPresented: $showingDeleteConfirmation) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                // Handle account deletion
            }
        } message: {
            Text("Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.")
        }
        .detectLanguageChange() // Force UI refresh on language change
    }
    
    // MARK: - Hero Header Section
    private var heroHeaderSection: some View {
        RoutaCard(style: .glassmorphic, elevation: .high) {
            ZStack {
                // Background gradient
                RoutaGradients.heroGradient
                    .mask(RoundedRectangle(cornerRadius: 16))
                    .opacity(0.6)
                
                VStack(spacing: RoutaSpacing.lg) {
                    // User Avatar with gradient background
                    ZStack {
                        Circle()
                            .fill(RoutaGradients.primaryGradient)
                            .frame(width: 120, height: 120)
                            .routaShadow(.medium, style: .colored(.routaPrimary))
                        
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                    }
                    
                    
                    VStack(spacing: RoutaSpacing.sm) {
                        Text(authManager.isAuthenticated ? (authManager.user?.displayName ?? authManager.user?.email ?? "Kullanıcı") : "Misafir Kullanıcı")
                            .routaTitle2()
                            .foregroundColor(.white)
                        
                        Text(authManager.isAuthenticated ? "Routa ile dünyayı keşfet" : "Giriş yapın ve dünyayı keşfedin")
                            .routaCallout()
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    // User Stats
                    HStack(spacing: RoutaSpacing.xl) {
                        UserStatView(
                            title: "Ziyaret",
                            value: "\(viewModel.visitedDestinationsCount)",
                            icon: "location.fill"
                        )
                        
                        UserStatView(
                            title: "Rota",
                            value: "\(viewModel.savedRoutesCount)",
                            icon: "map.fill"
                        )
                        
                        Button(action: {
                            if authManager.isAuthenticated {
                                RoutaHapticsManager.shared.buttonTap()
                                showingFavoritesList = true
                            }
                        }) {
                            UserStatView(
                                title: "Favori",
                                value: "\(authManager.favoritesManager.favoritesCount)",
                                icon: "heart.fill"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(!authManager.isAuthenticated)
                    }
                }
                .padding(RoutaSpacing.xl)
            }
        }
        .padding(.top, RoutaSpacing.lg)
        .padding(.horizontal, RoutaSpacing.lg)
    }
    
    // MARK: - User Info Card
    private var userInfoCard: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.lg) {
            Text("Kullanıcı Bilgileri")
                .routaTitle3()
                .padding(.horizontal, RoutaSpacing.lg)
            
            RoutaCard(style: .standard, elevation: .medium) {
                VStack(spacing: RoutaSpacing.md) {
                    UserInfoRow(
                        icon: "person.fill",
                        title: "Ad Soyad",
                        value: authManager.user?.displayName ?? "Belirtilmemiş",
                        color: .routaPrimary
                    )
                    
                    Divider()
                        .background(Color.routaBorder)
                    
                    UserInfoRow(
                        icon: "envelope.fill",
                        title: "E-posta",
                        value: authManager.user?.email ?? "Belirtilmemiş",
                        color: .routaSecondary
                    )
                    
                    Divider()
                        .background(Color.routaBorder)
                    
                    UserInfoRow(
                        icon: "calendar",
                        title: "Üyelik Tarihi",
                        value: authManager.user?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "Belirtilmemiş",
                        color: .routaAccent
                    )
                }
            }
            .padding(.horizontal, RoutaSpacing.lg)
        }
    }
    
    // MARK: - Favorites Section
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.lg) {
            Text("Favoriler")
                .routaTitle3()
                .padding(.horizontal, RoutaSpacing.lg)
            
            NavigationLink(destination: FavoritesView()) {
                RoutaCard(style: .standard, elevation: .medium) {
                    HStack(spacing: RoutaSpacing.md) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(RoutaGradients.primaryGradient)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                            Text("Favorilerim")
                                .routaHeadline()
                                .foregroundColor(.routaText)
                            
                            Text("Beğendiğiniz destinasyonları görüntüleyin")
                                .routaCaption1()
                                .foregroundColor(.routaTextSecondary)
                        }
                        
                        Spacer()
                        
                        // Badge and arrow
                        HStack(spacing: RoutaSpacing.sm) {
                            let favoritesCount = authManager.favoritesManager.favoritesCount
                            if favoritesCount > 0 {
                                Text("\(favoritesCount)")
                                    .font(.routaCaption2())
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.routaError)
                                    )
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.routaTextSecondary)
                        }
                    }
                    .padding(RoutaSpacing.md)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, RoutaSpacing.lg)
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.lg) {
            Text("Ayarlar")
                .routaTitle3()
                .padding(.horizontal, RoutaSpacing.lg)
            
            VStack(spacing: RoutaSpacing.md) {
                // Dark Mode Toggle
                Button(action: {
                    RoutaHapticsManager.shared.selection()
                    themeManager.toggleDarkMode()
                }) {
                    RoutaCard(style: .standard, elevation: .low) {
                        ModernSettingsRow(
                            icon: "moon.fill",
                            title: "Karanlık Mod",
                            subtitle: "Tema tercihini değiştir",
                            color: .routaPrimary,
                            trailing: {
                                RoutaToggleButton(
                                    isOn: $themeManager.isDarkMode,
                                    onIcon: "moon.stars.fill",
                                    offIcon: "sun.max.fill"
                                ) { isEnabled in
                                    // Toggle action handled by parent button
                                }
                            }
                        )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Language Selection
                Button(action: {
                    showingLanguageSelection = true
                    RoutaHapticsManager.shared.buttonTap()
                }) {
                    RoutaCard(style: .standard, elevation: .low) {
                        ModernSettingsRow(
                            icon: "globe",
                            title: languageManager.currentLanguage == "tr" ? "Dil" : "Language",
                            subtitle: languageManager.currentLanguageInfo.displayName,
                            color: .routaSecondary,
                            trailing: {
                                Image(systemName: "chevron.right")
                                    .font(.routaCaption1())
                                    .foregroundColor(.routaTextSecondary)
                            }
                        )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Notifications
                Button(action: {
                    showingNotificationSettings = true
                    RoutaHapticsManager.shared.buttonTap()
                }) {
                    RoutaCard(style: .standard, elevation: .low) {
                        ModernSettingsRow(
                            icon: "bell.fill",
                            title: "Bildirimler",
                            subtitle: "Bildirim tercihlerini yönet",
                            color: .routaWarning,
                            trailing: {
                                Image(systemName: "chevron.right")
                                    .font(.routaCaption1())
                                    .foregroundColor(.routaTextSecondary)
                            }
                        )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Privacy

            }
            .padding(.horizontal, RoutaSpacing.lg)
        }
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.lg) {
            Text("Yasal")
                .routaTitle3()
                .padding(.horizontal, RoutaSpacing.lg)
            
            VStack(spacing: RoutaSpacing.md) {
                // Privacy Policy
                NavigationLink(destination: PrivacyPolicyView()) {
                    RoutaCard(style: .standard, elevation: .low) {
                        ModernSettingsRow(
                            icon: "shield.fill",
                            title: "Gizlilik Politikası",
                            subtitle: "Veri koruma ve gizlilik",
                            color: .routaPrimary,
                            trailing: {
                                Image(systemName: "chevron.right")
                                    .font(.routaCaption1())
                                    .foregroundColor(.routaTextSecondary)
                            }
                        )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Terms of Service
                NavigationLink(destination: TermsOfServiceView()) {
                    RoutaCard(style: .standard, elevation: .low) {
                        ModernSettingsRow(
                            icon: "doc.text.fill",
                            title: "Kullanım Koşulları",
                            subtitle: "Hizmet şartları ve kurallar",
                            color: .routaSecondary,
                            trailing: {
                                Image(systemName: "chevron.right")
                                    .font(.routaCaption1())
                                    .foregroundColor(.routaTextSecondary)
                            }
                        )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // About
                NavigationLink(destination: AboutView()) {
                    RoutaCard(style: .standard, elevation: .low) {
                        ModernSettingsRow(
                            icon: "info.circle.fill",
                            title: "Uygulama Hakkında",
                            subtitle: "Versiyon bilgisi ve geliştirici",
                            color: .routaAccent,
                            trailing: {
                                Image(systemName: "chevron.right")
                                    .font(.routaCaption1())
                                    .foregroundColor(.routaTextSecondary)
                            }
                        )
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, RoutaSpacing.lg)
        }
    }
    
    // MARK: - Account Management Section
    private var accountManagementSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.lg) {
            Text("Hesap Yönetimi")
                .routaTitle3()
                .padding(.horizontal, RoutaSpacing.lg)
            
            VStack(spacing: RoutaSpacing.md) {
                RoutaButton(
                    "Profili Düzenle",
                    icon: "pencil",
                    variant: .outline,
                    size: .large
                ) {
                    // Handle profile edit
                    RoutaHapticsManager.shared.buttonTap()
                }
                
                RoutaButton(
                    "Yedekleme ve Senkronizasyon",
                    icon: "icloud",
                    variant: .secondary,
                    size: .large
                ) {
                    // Handle backup
                    RoutaHapticsManager.shared.buttonTap()
                }
                
                RoutaButton(
                    "Uygulamayı Değerlendir",
                    icon: "star.fill",
                    variant: .ghost,
                    size: .large
                ) {
                    viewModel.requestAppReview()
                    RoutaHapticsManager.shared.success()
                }
                
                RoutaButton(
                    "Reset Onboarding",
                    icon: "arrow.clockwise",
                    variant: .ghost,
                    size: .large
                ) {
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    RoutaHapticsManager.shared.buttonTap()
                }
                
                Button(action: {
                    if viewModel.canSendMail {
                        showingMailComposer = true
                    } else {
                        viewModel.openMailApp()
                    }
                    RoutaHapticsManager.shared.buttonTap()
                }) {
                    RoutaButton(
                        "Geri Bildirim Gönder",
                        icon: "envelope.fill",
                        variant: .ghost,
                        size: .large
                    ) {
                        // Action handled in parent button
                    }
                }
                
                Button(action: {
                    showingHelp = true
                    RoutaHapticsManager.shared.buttonTap()
                }) {
                    RoutaButton(
                        "Yardım ve Destek",
                        icon: "questionmark.circle.fill",
                        variant: .ghost,
                        size: .large
                    ) {
                        // Action handled in parent button
                    }
                }
            }
            .padding(.horizontal, RoutaSpacing.lg)
        }
    }
    
    // MARK: - Authentication Section
    private var authSection: some View {
        VStack(spacing: RoutaSpacing.lg) {
            if authManager.isAuthenticated {
                // Logout Button
                RoutaGradientButton(
                    "Çıkış Yap",
                    icon: "arrow.right.square",
                    gradient: LinearGradient(
                        colors: [Color.routaError, Color.routaError.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    size: .large
                ) {
                    handleLogout()
                }
                
                // Delete Account Button
                Button(action: {
                    showingDeleteConfirmation = true
                    RoutaHapticsManager.shared.warning()
                }) {
                    Text("Hesabı Sil")
                        .routaCallout()
                        .foregroundColor(.routaError)
                        .underline()
                }
            } else {
                // Login and Signup Buttons for guests
                VStack(spacing: RoutaSpacing.md) {
                    RoutaGradientButton(
                        "Giriş Yap",
                        icon: "person.fill",
                        gradient: RoutaGradients.primaryGradient,
                        size: .large
                    ) {
                        print("🔴 Login button tapped")
                        RoutaHapticsManager.shared.buttonTap()
                        selectedAuthMode = .login
                        showingAuthView = true
                    }
                    
                    RoutaButton(
                        "Hesap Oluştur",
                        icon: "person.badge.plus",
                        variant: .secondary,
                        size: .large
                    ) {
                        print("🔴 Signup button tapped")
                        RoutaHapticsManager.shared.buttonTap()
                        selectedAuthMode = .signup
                        showingAuthView = true
                    }
                }
                
                Text("Tüm özellikleri kullanmak için giriş yapın")
                    .routaCaption1()
                    .foregroundColor(.routaTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // App Info
            VStack(spacing: RoutaSpacing.sm) {
                Text("Routa v1.0.0")
                    .routaCaption2()
                    .foregroundColor(.routaTextSecondary)
                
                Button(action: {
                    showingAbout = true
                    RoutaHapticsManager.shared.buttonTap()
                }) {
                    Text("Uygulama Hakkında")
                        .routaCaption2()
                        .foregroundColor(.routaPrimary)
                        .underline()
                }
            }
        }
        .padding(.horizontal, RoutaSpacing.lg)
        .padding(.bottom, RoutaSpacing.xl)
    }
    
    // MARK: - Helper Methods
    private func refreshProfile() async {
        RoutaHapticsManager.shared.pullToRefresh()
        isRefreshing = true
        await viewModel.loadData()
        isRefreshing = false
    }
    
    private func handleLogout() {
        RoutaHapticsManager.shared.warning()
        authManager.signOut()
    }

}

// MARK: - Supporting Components

struct UserStatView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: RoutaSpacing.xs) {
            HStack(spacing: RoutaSpacing.xs) {
                Image(systemName: icon)
                    .font(.routaCaption1())
                    .foregroundColor(.white.opacity(0.8))
                
                Text(value)
                    .routaTitle3()
                    .foregroundColor(.white)
            }
            
            Text(title)
                .routaCaption2()
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct UserInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: RoutaSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(color)
                )
            
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

struct ModernSettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let trailing: Trailing
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack(spacing: RoutaSpacing.md) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                )
                .routaShadow(.subtle, style: .colored(color))
            
            // Content
            VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                Text(title)
                    .routaCallout()
                    .foregroundColor(.routaText)
                
                Text(subtitle)
                    .routaCaption2()
                    .foregroundColor(.routaTextSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Trailing content
            trailing
        }
        .padding(.vertical, RoutaSpacing.xs)
    }
}

// MARK: - Supporting Views (Keep existing implementations)

struct BudgetTypeSelectionView: View {
    @Binding var selectedBudgetType: TravelPlan.BudgetType
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(TravelPlan.BudgetType.allCases, id: \.self) { type in
                Button(action: {
                    selectedBudgetType = type
                }) {
                    VStack(spacing: 4) {
                        Text(type.icon)
                            .font(.title3)
                        
                        Text(type.displayName)
                            .font(.caption2)
                            .fontWeight(selectedBudgetType == type ? .semibold : .regular)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        selectedBudgetType == type ? Color.green.opacity(0.2) : Color(.systemGray5)
                    )
                    .foregroundColor(selectedBudgetType == type ? .green : .primary)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct TravelStyleSelectionView: View {
    @Binding var selectedTravelStyle: TravelStyle
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(TravelStyle.allCases, id: \.self) { style in
                HStack {
                    Text(style.icon)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(style.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(style.description)
                            .font(.caption)
                            .foregroundColor(.routaTextSecondary)
                    }
                    
                    Spacer()
                    
                    if selectedTravelStyle == style {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.routaPrimary)
                    } else {
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTravelStyle = style
                }
            }
        }
    }
}

struct CurrencySelectionView: View {
    @Binding var selectedCurrency: String
    let currencies = ["TRY", "USD", "EUR", "GBP"]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(currencies, id: \.self) { currency in
                Button(currency) {
                    selectedCurrency = currency
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    selectedCurrency == currency ? Color.orange.opacity(0.2) : Color(.systemGray5)
                )
                .foregroundColor(selectedCurrency == currency ? .orange : .primary)
                .cornerRadius(8)
            }
        }
    }
}


struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var pushNotifications = true
    @State private var emailNotifications = false
    @State private var routeReminders = true
    @State private var destinationUpdates = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Bildirim Türleri") {
                    Toggle("Push Bildirimleri", isOn: $pushNotifications)
                    Toggle("E-posta Bildirimleri", isOn: $emailNotifications)
                }
                
                Section("İçerik Bildirimleri") {
                    Toggle("Rota Hatırlatıcıları", isOn: $routeReminders)
                    Toggle("Destinasyon Güncellemeleri", isOn: $destinationUpdates)
                }
            }
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

enum TravelStyle: String, CaseIterable {
    case adventurous = "adventurous"
    case cultural = "cultural"
    case relaxed = "relaxed"
    case luxury = "luxury"
    case budget = "budget"
    
    var displayName: String {
        switch self {
        case .adventurous: return "Maceracı"
        case .cultural: return "Kültürel"
        case .relaxed: return "Sakin"
        case .luxury: return "Lüks"
        case .budget: return "Ekonomik"
        }
    }
    
    var icon: String {
        switch self {
        case .adventurous: return "🏔️"
        case .cultural: return "🏛️"
        case .relaxed: return "🏖️"
        case .luxury: return "👑"
        case .budget: return "🎒"
        }
    }
    
    var description: String {
        switch self {
        case .adventurous: return "Macera dolu aktiviteler"
        case .cultural: return "Müze ve tarihi yerler"
        case .relaxed: return "Huzurlu ve sakin"
        case .luxury: return "En iyi hizmet ve konfor"
        case .budget: return "Uygun fiyatlı seçenekler"
        }
    }
}


struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.routaAccent)
                        
                        Text("Yardım & Destek")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Routa uygulamasını kullanırken ihtiyacınız olan her şey")
                            .font(.subheadline)
                            .foregroundColor(.routaTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Yardım")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}


struct MailComposerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(["support@routa.app"])
        composer.setSubject("Routa App - Geri Bildirim")
        
        let deviceInfo = """
        
        ---
        Cihaz Bilgileri:
        Model: \(UIDevice.current.model)
        Sistem: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
        Uygulama Sürümü: 1.0.0
        """
        
        composer.setMessageBody("Merhaba Routa ekibi,\n\n\(deviceInfo)", isHTML: false)
        
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerView
        
        init(_ parent: MailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

class ProfileViewModel: ObservableObject {
    @Published var preferredBudgetType: TravelPlan.BudgetType = .standard {
        didSet { saveUserPreferences() }
    }
    @Published var travelStyle: TravelStyle = .cultural {
        didSet { saveUserPreferences() }
    }
    @Published var preferredCurrency: String = "TRY" {
        didSet { saveUserPreferences() }
    }
    @Published var selectedLanguage: String = "Türkçe" {
        didSet { saveUserPreferences() }
    }
    @Published var favoriteDestinations: [Destination] = []
    @Published var visitedDestinationsCount: Int = 0
    @Published var savedRoutesCount: Int = 0
    
    var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    private let destinationRepository: DestinationRepository
    private let routeRepository: RouteRepository
    private var isInitializing = true
    
    init(destinationRepository: DestinationRepository, routeRepository: RouteRepository) {
        self.destinationRepository = destinationRepository
        self.routeRepository = routeRepository
        loadUserPreferences()
        isInitializing = false
    }
    
    @MainActor
    func loadData() async {
        do {
            let savedRoutes = try await routeRepository.fetchSavedRoutes()
            savedRoutesCount = savedRoutes.count
            
            let allDestinations = try await destinationRepository.fetchAllDestinations()
            favoriteDestinations = Array(allDestinations.prefix(3))
            
            visitedDestinationsCount = Int.random(in: 2...8)
        } catch {
            print("Error loading profile data: \(error)")
        }
    }
    
    private func loadUserPreferences() {
        if let budgetRawValue = UserDefaults.standard.object(forKey: "preferredBudgetType") as? String,
           let budgetType = TravelPlan.BudgetType(rawValue: budgetRawValue) {
            preferredBudgetType = budgetType
        }
        
        if let styleRawValue = UserDefaults.standard.object(forKey: "travelStyle") as? String,
           let style = TravelStyle(rawValue: styleRawValue) {
            travelStyle = style
        }
        
        preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "TRY"
        selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "Türkçe"
    }
    
    private func saveUserPreferences() {
        guard !isInitializing else { return }
        UserDefaults.standard.set(preferredBudgetType.rawValue, forKey: "preferredBudgetType")
        UserDefaults.standard.set(travelStyle.rawValue, forKey: "travelStyle")
        UserDefaults.standard.set(preferredCurrency, forKey: "preferredCurrency")
        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
    }
    
    func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func openMailApp() {
        if let url = URL(string: "mailto:support@routa.app?subject=Routa%20App%20-%20Geri%20Bildirim") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Spacing Constants moved to RoutaDesignSystem.swift

#Preview {
    NavigationStack {
        ProfileView(viewModel: ProfileViewModel(
            destinationRepository: MockDestinationRepository(),
            routeRepository: MockRouteRepository()
        ))
        .previewEnvironment(authenticated: true)
    }
}
