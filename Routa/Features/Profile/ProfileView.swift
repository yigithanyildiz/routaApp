import SwiftUI
import PhotosUI
import StoreKit
import MessageUI

// MARK: - Modern ProfileView with New Design
struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @StateObject private var themeManager = RoutaThemeManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dependencyContainer: DependencyContainer

    @State private var showingSettings = false
    @State private var showingEditProfile = false
    @State private var showingImagePicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var isRefreshing = false
    @State private var isUploadingPhoto = false
    @State private var showingAuthView = false
    @State private var selectedAuthMode: AuthGatewayView.AuthMode = .login

    private let photoManager = ProfilePhotoManager.shared
    private let firestoreManager = ProfilePhotoFirestoreManager.shared

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                ScrollView {
                    HStack{
                        Spacer()
                        Button(action: {
                            RoutaHapticsManager.shared.buttonTap()
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.routaText)
                                .padding(RoutaSpacing.md)
                        }
                        .offset(y: 30)
                    }
                    .padding(.horizontal, RoutaSpacing.lg)

                    VStack(spacing: RoutaSpacing.xl) {
                     
                        // Profile Header
                        profileHeaderSection
                            .padding(.horizontal, RoutaSpacing.lg)

                        // Stats Cards
                        statsCardsSection
                            .padding(.horizontal, RoutaSpacing.lg)

                        // Achievements Section
                        achievementsSection
                    }
                    
                    .padding(.bottom, LayoutConstants.tabBarHeight + RoutaSpacing.sm)
                }
                .background(Color.routaBackground)
                .dynamicIslandBlur()
                .navigationBarTitleDisplayMode(.inline)

                // Fixed Settings Button at Top Right
            // Below dynamic island/notch
            }
            .refreshable {
                await refreshProfile()
            }
            .onAppear {
                // Load profile photo from Firebase (or cache)
                loadProfilePhoto()

                Task {
                    await viewModel.loadData()
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(authManager)
                    .environmentObject(dependencyContainer)
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
                    .environmentObject(authManager)
            }
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            await uploadProfilePhoto(uiImage)
                        }
                    }
                }
            }
            .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
                if isAuthenticated {
                    // User just logged in, load their photo
                    loadProfilePhoto()
                } else {
                    // User logged out, clear cache but keep photo in Firestore
                    firestoreManager.clearCache()
                    profileImage = nil
                }
            }
            .sheet(isPresented: $showingAuthView) {
                AuthView(mode: selectedAuthMode)
                    .environmentObject(authManager)
            }
        }
    }

    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        VStack(spacing: RoutaSpacing.lg) {
            // Profile Photo
            Group {
                if authManager.isAuthenticated {
                    Button(action: {
                        RoutaHapticsManager.shared.buttonTap()
                        showingImagePicker = true
                    }) {
                        profilePhotoView
                    }
                } else {
                    profilePhotoView
                }
            }
            .padding(.top, RoutaSpacing.lg)

            // Name and Bio
            VStack(spacing: RoutaSpacing.xs) {
                Text(authManager.isAuthenticated ? (authManager.user?.displayName ?? "Kullanıcı") : "Misafir Kullanıcı")
                    .routaTitle2()
                    .foregroundColor(.routaText)

                if authManager.isAuthenticated {
                    if let bio = authManager.user?.bio, !bio.isEmpty {
                        Text(bio)
                            .routaCaption1()
                            .foregroundColor(.routaTextSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    } else {
                        Text("Henüz biyografi eklenmedi")
                            .routaCaption1()
                            .foregroundColor(.routaTextSecondary.opacity(0.6))
                            .italic()
                    }
                }
            }

            // Auth Buttons
            if authManager.isAuthenticated {
                // Edit Profile Button (only for authenticated users)
                RoutaButton(
                    "Profili Düzenle",
                    icon: "pencil",
                    variant: .outline,
                    size: .medium
                ) {
                    RoutaHapticsManager.shared.buttonTap()
                    showingEditProfile = true
                }
            } else {
                // Login & Sign Up Buttons (for guest users)
                VStack(spacing: RoutaSpacing.sm) {
                    RoutaButton(
                        "Giriş Yap",
                        icon: "person.fill",
                        variant:.outline,
                        size: .small
                    ) {
                        RoutaHapticsManager.shared.buttonTap()
                        showingAuthView = true
                        selectedAuthMode = .login
                    }
                    .frame(maxWidth: .greatestFiniteMagnitude)

                    RoutaButton(
                        "Kayıt Ol  ",
                        icon: "person.badge.plus",
                        variant: .outline,
                        size: .small
                    ) {
                        RoutaHapticsManager.shared.buttonTap()
                        showingAuthView = true
                        selectedAuthMode = .signup
                    }
                    .frame(maxWidth: .greatestFiniteMagnitude)
                }
            }
        }
    }

    // MARK: - Profile Photo View
    private var profilePhotoView: some View {
        ZStack(alignment: .bottomTrailing) {
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.routaPrimary, .routaSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
            } else {
                ZStack {
                    Circle()
                        .fill(RoutaGradients.primaryGradient)
                        .frame(width: 120, height: 120)

                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.routaPrimary, .routaSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
            }

            // Camera Icon - Only show for authenticated users
            if authManager.isAuthenticated {
                ZStack {
                    Circle()
                        .fill(Color.routaPrimary)
                        .frame(width: 36, height: 36)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .routaShadow(.medium, style: .colored(.routaPrimary))
            }
        }
    }

    // MARK: - Stats Cards Section
    private var statsCardsSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.md) {
            Text("İstatistikler")
                .routaTitle3()
                .foregroundColor(.routaText)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: RoutaSpacing.md) {
                StatCard(
                    title: "Geziler",
                    value: "\(viewModel.visitedDestinationsCount)",
                    icon: "airplane",
                    gradient: RoutaGradients.primaryGradient
                )

                StatCard(
                    title: "Ülkeler",
                    value: "\(viewModel.visitedCountriesCount)",
                    icon: "globe",
                    gradient: RoutaGradients.accentGradient
                )

                StatCard(
                    title: "İncelemeler",
                    value: "\(viewModel.reviewsCount)",
                    icon: "star.fill",
                    gradient: RoutaGradients.warningGradient
                )

                StatCard(
                    title: "Rozetler",
                    value: "\(viewModel.badgesCount)",
                    icon: "medal.fill",
                    gradient: RoutaGradients.successGradient
                )
            }
        }
    }

    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.md) {
            HStack {
                Text("Başarılar")
                    .routaTitle3()
                    .foregroundColor(.routaText)

                Spacer()

                Text("\(viewModel.achievements.count) rozet")
                    .routaCaption1()
                    .foregroundColor(.routaTextSecondary)
            }
            .padding(.horizontal, RoutaSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: RoutaSpacing.md) {
                    ForEach(viewModel.achievements) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
                .padding(.horizontal, RoutaSpacing.lg)
            }
        }
    }

    // MARK: - Helper Methods
    private func refreshProfile() async {
        RoutaHapticsManager.shared.pullToRefresh()
        isRefreshing = true
        await viewModel.loadData()
        loadProfilePhoto()
        isRefreshing = false
    }

    private func loadProfilePhoto() {
        guard authManager.isAuthenticated else { return }

        firestoreManager.downloadProfilePhoto { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            case .failure(let error):
                // If error is "no photo found", that's okay - user hasn't uploaded one yet
                let nsError = error as NSError
                if nsError.code != -2 {
                    print("Error loading profile photo: \(error.localizedDescription)")
                }
            }
        }
    }

    private func uploadProfilePhoto(_ image: UIImage) async {
        isUploadingPhoto = true
        RoutaHapticsManager.shared.buttonTap()

        await withCheckedContinuation { continuation in
            firestoreManager.uploadProfilePhoto(image) { result in
                DispatchQueue.main.async {
                    self.isUploadingPhoto = false

                    switch result {
                    case .success:
                        self.profileImage = image
                        RoutaHapticsManager.shared.success()
                    case .failure(let error):
                        RoutaHapticsManager.shared.error()
                        print("Error uploading photo: \(error.localizedDescription)")
                    }

                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient

    var body: some View {
        RoutaCard(style: .glassmorphic, elevation: .medium) {
            VStack(spacing: RoutaSpacing.md) {
                ZStack {
                    Circle()
                        .fill(gradient)
                        .frame(width: 56, height: 56)
                        .routaShadow(.medium, style: .standard)

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(spacing: RoutaSpacing.xs) {
                    Text(value)
                        .routaTitle1()
                        .foregroundColor(.routaText)

                    Text(title)
                        .routaCaption1()
                        .foregroundColor(.routaTextSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, RoutaSpacing.lg)
        }
    }
}

// MARK: - Achievement Badge Component
struct AchievementBadge: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: RoutaSpacing.sm) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? RoutaGradients.primaryGradient : LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 80, height: 80)
                    .routaShadow(achievement.isUnlocked ? .high : .subtle, style: .standard)

                Text(achievement.icon)
                    .font(.system(size: 40))
                    .grayscale(achievement.isUnlocked ? 0 : 1)
            }

            VStack(spacing: RoutaSpacing.xs) {
                Text(achievement.title)
                    .routaCaption2()
                    .foregroundColor(.routaText)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(achievement.description)
                    .font(.system(size: 10))
                    .foregroundColor(.routaTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80)
        }
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let isUnlocked: Bool
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager = RoutaThemeManager.shared
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
    @State private var showingAuthView = false
    @State private var showingFavoritesList = false
    @State private var selectedAuthMode: AuthGatewayView.AuthMode = .login

    var body: some View {
        NavigationStack {
            List {
                // Appearance Section
                Section {
                    HStack(spacing: RoutaSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(colors: [.routaPrimary, .routaSecondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 32, height: 32)

                            Image(systemName: themeManager.isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Görünüm")
                                .routaCallout()
                                .foregroundColor(.routaText)
                            Text(themeManager.isDarkMode ? "Koyu Tema" : "Açık Tema")
                                .routaCaption2()
                                .foregroundColor(.routaTextSecondary)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { themeManager.isDarkMode },
                            set: { newValue in
                                RoutaHapticsManager.shared.selection()
                                themeManager.isDarkMode = newValue
                            }
                        ))
                        .labelsHidden()
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        RoutaHapticsManager.shared.selection()
                        themeManager.isDarkMode.toggle()
                    }
                } header: {
                    Text("TEMA")
                        .font(.routaCaption2())
                        .foregroundColor(.routaTextSecondary)
                }

                // Language Section
                Section {
                    Button(action: {
                        showingLanguageSelection = true
                        RoutaHapticsManager.shared.buttonTap()
                    }) {
                        HStack(spacing: RoutaSpacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(colors: [.routaAccent, .routaAccentDark], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 32, height: 32)

                                Image(systemName: "globe")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Dil")
                                    .routaCallout()
                                    .foregroundColor(.routaText)
                                Text(languageManager.currentLanguageInfo.displayName)
                                    .routaCaption2()
                                    .foregroundColor(.routaTextSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.routaTextSecondary)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        showingNotificationSettings = true
                        RoutaHapticsManager.shared.buttonTap()
                    }) {
                        HStack(spacing: RoutaSpacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(colors: [.routaWarning, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 32, height: 32)

                                Image(systemName: "bell.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text("Bildirimler")
                                .routaCallout()
                                .foregroundColor(.routaText)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.routaTextSecondary)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                } header: {
                    Text("UYGULAMA")
                        .font(.routaCaption2())
                        .foregroundColor(.routaTextSecondary)
                }

                // Support Section
                Section {
                    Button(action: {
                        requestAppReview()
                        RoutaHapticsManager.shared.success()
                    }) {
                        HStack(spacing: RoutaSpacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 32, height: 32)

                                Image(systemName: "star.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text("Uygulamayı Değerlendir")
                                .routaCallout()
                                .foregroundColor(.routaText)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.routaTextSecondary)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        if MFMailComposeViewController.canSendMail() {
                            showingMailComposer = true
                        } else {
                            openMailApp()
                        }
                        RoutaHapticsManager.shared.buttonTap()
                    }) {
                        HStack(spacing: RoutaSpacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 32, height: 32)

                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text("Geri Bildirim")
                                .routaCallout()
                                .foregroundColor(.routaText)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.routaTextSecondary)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                } header: {
                    Text("DESTEK")
                        .font(.routaCaption2())
                        .foregroundColor(.routaTextSecondary)
                }

                // About Section
                Section {
                    NavigationLink(destination: AboutView()) {
                        HStack(spacing: RoutaSpacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 32, height: 32)

                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text("Uygulama Hakkında")
                                .routaCallout()
                                .foregroundColor(.routaText)

                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }

                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack(spacing: RoutaSpacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 32, height: 32)

                                Image(systemName: "shield.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text("Gizlilik Politikası")
                                .routaCallout()
                                .foregroundColor(.routaText)

                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }

                    NavigationLink(destination: TermsOfServiceView()) {
                        HStack(spacing: RoutaSpacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 32, height: 32)

                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text("Kullanım Koşulları")
                                .routaCallout()
                                .foregroundColor(.routaText)

                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                } header: {
                    Text("HAKKINDA")
                        .font(.routaCaption2())
                        .foregroundColor(.routaTextSecondary)
                }

                // Account Section (only if authenticated)
                if authManager.isAuthenticated {
                    Section {
                        Button(action: {
                            handleLogout()
                        }) {
                            HStack(spacing: RoutaSpacing.md) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(LinearGradient(colors: [.routaError, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 32, height: 32)

                                    Image(systemName: "arrow.right.square.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }

                                Text("Çıkış Yap")
                                    .routaCallout()
                                    .foregroundColor(.routaError)

                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    } header: {
                        Text("HESAP")
                            .font(.routaCaption2())
                            .foregroundColor(.routaTextSecondary)
                    }
                }

                // App Version
                Section {
                    HStack {
                        Text("Versiyon")
                            .routaCallout()
                            .foregroundColor(.routaTextSecondary)
                        Spacer()
                        Text("1.0.0")
                            .routaCallout()
                            .foregroundColor(.routaText)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.routaTextSecondary)
                    }
                }
            }
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
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
            .alert("Hesabı Sil", isPresented: $showingDeleteConfirmation) {
                Button("İptal", role: .cancel) { }
                Button("Sil", role: .destructive) {
                    // Handle account deletion
                }
            } message: {
                Text("Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir.")
            }
        }
    }

    // MARK: - User Info Card
    private var userInfoCard: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.lg) {
            Text("Kullanıcı Bilgileri")
                .routaTitle3()

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
        }
    }

    // MARK: - Favorites Section
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.lg) {
            Text("Favoriler")
                .routaTitle3()

            NavigationLink(destination: FavoritesView()) {
                RoutaCard(style: .standard, elevation: .medium) {
                    HStack(spacing: RoutaSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(RoutaGradients.primaryGradient)
                                .frame(width: 44, height: 44)

                            Image(systemName: "heart.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                            Text("Favorilerim")
                                .routaHeadline()
                                .foregroundColor(.routaText)

                            Text("Beğendiğiniz destinasyonları görüntüleyin")
                                .routaCaption1()
                                .foregroundColor(.routaTextSecondary)
                        }

                        Spacer()

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
        }
    }

    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.lg) {
            Text("Ayarlar")
                .routaTitle3()

            VStack(spacing: RoutaSpacing.md) {
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
            }
        }
    }

    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.lg) {
            Text("Yasal")
                .routaTitle3()

            VStack(spacing: RoutaSpacing.md) {
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
        }
    }

    // MARK: - Account Management Section
    private var accountManagementSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.lg) {
            Text("Hesap Yönetimi")
                .routaTitle3()

            VStack(spacing: RoutaSpacing.md) {
                RoutaButton(
                    "Yedekleme ve Senkronizasyon",
                    icon: "icloud",
                    variant: .secondary,
                    size: .large
                ) {
                    RoutaHapticsManager.shared.buttonTap()
                }

                RoutaButton(
                    "Uygulamayı Değerlendir",
                    icon: "star.fill",
                    variant: .ghost,
                    size: .large
                ) {
                    requestAppReview()
                    RoutaHapticsManager.shared.success()
                }

                RoutaButton(
                    "Reset Onboarding",
                    icon: "arrow.clockwise",
                    variant: .ghost,
                    size: .large
                ) {
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    ImageCacheManager.shared.clearCache()
                    RoutaHapticsManager.shared.buttonTap()
                }

                Button(action: {
                    if MFMailComposeViewController.canSendMail() {
                        showingMailComposer = true
                    } else {
                        openMailApp()
                    }
                    RoutaHapticsManager.shared.buttonTap()
                }) {
                    RoutaButton(
                        "Geri Bildirim Gönder",
                        icon: "envelope.fill",
                        variant: .ghost,
                        size: .large
                    ) { }
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
                    ) { }
                }
            }
        }
    }

    // MARK: - Authentication Section
    private var authSection: some View {
        VStack(spacing: RoutaSpacing.lg) {
            if authManager.isAuthenticated {
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
                VStack(spacing: RoutaSpacing.md) {
                    RoutaGradientButton(
                        "Giriş Yap",
                        icon: "person.fill",
                        gradient: RoutaGradients.primaryGradient,
                        size: .large
                    ) {
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
    }

    // MARK: - Helper Methods
    private func handleLogout() {
        RoutaHapticsManager.shared.warning()
        authManager.signOut()
    }

    private func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func openMailApp() {
        if let url = URL(string: "mailto:support@routa.app?subject=Routa%20App%20-%20Geri%20Bildirim") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager

    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var showingImagePicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var isSaving = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isUploadingPhoto = false

    private let photoManager = ProfilePhotoManager.shared
    private let firestoreManager = ProfilePhotoFirestoreManager.shared

    var body: some View {
        NavigationStack {
            Form {
                Section("Profil Bilgileri") {
                    TextField("İsim Soyisim", text: $displayName)

                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Profil Fotoğrafı") {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Text("Fotoğraf Seç")
                            Spacer()
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "photo")
                            }
                        }
                    }

                    if profileImage != nil {
                        Button(role: .destructive) {
                            deleteProfilePhoto()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Fotoğrafı Kaldır")
                            }
                        }
                        .disabled(isUploadingPhoto)
                    }

                    if isUploadingPhoto {
                        HStack {
                            ProgressView()
                            Text("Yükleniyor...")
                                .font(.caption)
                                .foregroundColor(.routaTextSecondary)
                        }
                    }
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveProfile()
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Kaydet")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            await uploadProfilePhoto(uiImage)
                        }
                    }
                }
            }
            .onAppear {
                displayName = authManager.user?.displayName ?? ""
                bio = authManager.user?.bio ?? ""
                loadProfilePhoto()
            }
            .alert("Hata", isPresented: $showingError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func saveProfile() {
        isSaving = true
        RoutaHapticsManager.shared.buttonTap()

        // Note: Photo is already uploaded to Firestore when selected
        // Save display name and bio

        authManager.updateProfile(
            displayName: displayName.isEmpty ? nil : displayName,
            bio: bio.isEmpty ? nil : bio
        ) { result in
            isSaving = false

            switch result {
            case .success:
                RoutaHapticsManager.shared.success()
                dismiss()
            case .failure(let error):
                RoutaHapticsManager.shared.error()
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }

    private func loadProfilePhoto() {
        guard authManager.isAuthenticated else { return }

        firestoreManager.downloadProfilePhoto { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            case .failure:
                // No photo uploaded yet, that's okay
                break
            }
        }
    }

    private func uploadProfilePhoto(_ image: UIImage) async {
        isUploadingPhoto = true
        RoutaHapticsManager.shared.buttonTap()

        await withCheckedContinuation { continuation in
            firestoreManager.uploadProfilePhoto(image) { result in
                DispatchQueue.main.async {
                    self.isUploadingPhoto = false

                    switch result {
                    case .success:
                        self.profileImage = image
                        RoutaHapticsManager.shared.success()
                    case .failure(let error):
                        RoutaHapticsManager.shared.error()
                        self.errorMessage = "Fotoğraf yüklenemedi: \(error.localizedDescription)"
                        self.showingError = true
                    }

                    continuation.resume()
                }
            }
        }
    }

    private func deleteProfilePhoto() {
        RoutaHapticsManager.shared.buttonTap()

        firestoreManager.deleteProfilePhoto { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    withAnimation {
                        self.profileImage = nil
                    }
                    RoutaHapticsManager.shared.success()
                case .failure(let error):
                    RoutaHapticsManager.shared.error()
                    self.errorMessage = "Fotoğraf silinemedi: \(error.localizedDescription)"
                    self.showingError = true
                }
            }
        }
    }
}

// MARK: - Supporting Components

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
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                )
                .routaShadow(.subtle, style: .colored(color))

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

            trailing
        }
        .padding(.vertical, RoutaSpacing.xs)
    }
}

// MARK: - Supporting Views

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

// MARK: - ProfileViewModel

class ProfileViewModel: ObservableObject {
    @Published var favoriteDestinations: [Destination] = []
    @Published var visitedDestinationsCount: Int = 0
    @Published var visitedCountriesCount: Int = 0
    @Published var reviewsCount: Int = 0
    @Published var badgesCount: Int = 0
    @Published var savedRoutesCount: Int = 0
    @Published var achievements: [Achievement] = []

    private let destinationRepository: DestinationRepository
    private let routeRepository: RouteRepository

    init(destinationRepository: DestinationRepository, routeRepository: RouteRepository) {
        self.destinationRepository = destinationRepository
        self.routeRepository = routeRepository
        loadMockAchievements()
    }

    @MainActor
    func loadData() async {
        do {
            let savedRoutes = try await routeRepository.fetchSavedRoutes()
            savedRoutesCount = savedRoutes.count

            let allDestinations = try await destinationRepository.fetchAllDestinations()
            favoriteDestinations = Array(allDestinations.prefix(3))

            visitedDestinationsCount = Int.random(in: 5...25)
            visitedCountriesCount = Int.random(in: 2...15)
            reviewsCount = Int.random(in: 10...50)
            badgesCount = achievements.filter { $0.isUnlocked }.count
        } catch {
            print("Error loading profile data: \(error)")
        }
    }

    private func loadMockAchievements() {
        achievements = [
            Achievement(icon: "🌍", title: "Gezgin", description: "İlk seyahat", isUnlocked: true),
            Achievement(icon: "✈️", title: "Uçakta", description: "5 uçuş", isUnlocked: true),
            Achievement(icon: "📸", title: "Fotoğrafçı", description: "50 fotoğraf", isUnlocked: true),
            Achievement(icon: "🗺️", title: "Harita Uzmanı", description: "10 rota", isUnlocked: true),
            Achievement(icon: "⭐", title: "Yıldız", description: "100 puan", isUnlocked: false),
            Achievement(icon: "🏆", title: "Şampiyon", description: "Tüm rozetler", isUnlocked: false),
            Achievement(icon: "🎒", title: "Sırt Çantalı", description: "Solo seyahat", isUnlocked: true),
            Achievement(icon: "🌟", title: "Parlak Yıldız", description: "50 inceleme", isUnlocked: false)
        ]
    }
}

// MARK: - Previews

#Preview("Profile - Authenticated") {
    ProfileView(viewModel: ProfileViewModel(
        destinationRepository: MockDestinationRepository(),
        routeRepository: MockRouteRepository()
    ))
    .previewEnvironment(authenticated: true)
}

#Preview("Profile - Guest") {
    ProfileView(viewModel: ProfileViewModel(
        destinationRepository: MockDestinationRepository(),
        routeRepository: MockRouteRepository()
    ))
    .previewEnvironment(authenticated: false)
}

