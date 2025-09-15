import SwiftUI

struct LanguageSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var languageManager = LanguageManager.shared
    @State private var selectedLanguage: Language
    @State private var showingConfirmation = false
    
    init() {
        self._selectedLanguage = State(initialValue: LanguageManager.shared.currentLanguageInfo)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RoutaSpacing.lg) {
                    headerSection
                    languageOptionsSection
                }
                .padding(.horizontal, RoutaSpacing.lg)
                .padding(.bottom, 90)
            }
            .navigationTitle(getCurrentLocalizedTitle())
            .navigationBarTitleDisplayMode(.large)
            .background(Color.routaBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(getCurrentLocalizedCancel()) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(getCurrentLocalizedSave()) {
                        saveLanguageSelection()
                    }
                    .disabled(selectedLanguage.code == languageManager.currentLanguage)
                    .foregroundColor(selectedLanguage.code == languageManager.currentLanguage ? .routaTextSecondary : .routaPrimary)
                }
            }
        }
        .id(languageManager.currentLanguage) // Force refresh when language changes
    }
    
    private var headerSection: some View {
        RoutaCard(style: .glassmorphic, elevation: .medium) {
            VStack(spacing: RoutaSpacing.md) {
                Image(systemName: "globe")
                    .font(.system(size: 60))
                    .foregroundColor(.routaPrimary)
                
                Text(getCurrentLocalizedTitle())
                    .routaTitle2()
                    .foregroundColor(.routaText)
                    .multilineTextAlignment(.center)
                
                Text(getCurrentLocalizedSubtitle())
                    .routaCallout()
                    .foregroundColor(.routaTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RoutaSpacing.md)
            }
            .padding(RoutaSpacing.lg)
        }
        .padding(.top, RoutaSpacing.md)
    }
    
    private var languageOptionsSection: some View {
        VStack(spacing: RoutaSpacing.md) {
            ForEach(languageManager.supportedLanguages, id: \.code) { language in
                LanguageOptionRow(
                    language: language,
                    isSelected: selectedLanguage.code == language.code,
                    isCurrent: language.code == languageManager.currentLanguage
                ) {
                    selectedLanguage = language
                }
            }
        }
    }
    
    private func saveLanguageSelection() {
        languageManager.setLanguage(selectedLanguage.code)
        
        // Small delay to let the UI update before dismissing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismiss()
        }
    }
    
    // MARK: - Localized Strings
    private func getCurrentLocalizedTitle() -> String {
        switch languageManager.currentLanguage {
        case "tr": return "Dil Seçimi"
        case "en": return "Language Selection"
        default: return "Language Selection"
        }
    }
    
    private func getCurrentLocalizedSubtitle() -> String {
        switch languageManager.currentLanguage {
        case "tr": return "Uygulamanın dilini değiştirin. Değişiklik anında uygulanır."
        case "en": return "Change the app language. Changes apply instantly."
        default: return "Change the app language. Changes apply instantly."
        }
    }
    
    private func getCurrentLocalizedCancel() -> String {
        switch languageManager.currentLanguage {
        case "tr": return "İptal"
        case "en": return "Cancel"
        default: return "Cancel"
        }
    }
    
    private func getCurrentLocalizedSave() -> String {
        switch languageManager.currentLanguage {
        case "tr": return "Kaydet"
        case "en": return "Save"
        default: return "Save"
        }
    }
}

// MARK: - Language Option Row
struct LanguageOptionRow: View {
    let language: Language
    let isSelected: Bool
    let isCurrent: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoutaCard(style: .standard, elevation: isSelected ? .medium : .low) {
                HStack(spacing: RoutaSpacing.md) {
                    // Flag and Language
                    HStack(spacing: RoutaSpacing.sm) {
                        Text(language.flag)
                            .font(.system(size: 28))
                        
                        VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                            Text(language.name)
                                .routaHeadline()
                                .foregroundColor(.routaText)
                            
                            Text(language.englishName)
                                .routaCaption1()
                                .foregroundColor(.routaTextSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Status indicators
                    HStack(spacing: RoutaSpacing.sm) {
                        if isCurrent {
                            Text(getCurrentCurrentLabel())
                                .routaCaption2()
                                .foregroundColor(.routaSuccess)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.routaSuccess.opacity(0.2))
                                )
                        }
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.routaPrimary)
                        } else {
                            Image(systemName: "circle")
                                .font(.system(size: 20))
                                .foregroundColor(.routaTextSecondary)
                        }
                    }
                }
                .padding(RoutaSpacing.md)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func getCurrentCurrentLabel() -> String {
        switch LanguageManager.shared.currentLanguage {
        case "tr": return "Mevcut"
        case "en": return "Current"
        default: return "Current"
        }
    }
}

#Preview {
    LanguageSelectionView()
        .previewEnvironment(authenticated: false)
}