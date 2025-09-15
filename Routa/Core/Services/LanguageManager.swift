import SwiftUI
import Foundation

// MARK: - Language Manager for In-App Language Switching
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: String = "tr" {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
        }
    }
    
    // Available languages with their details
    let supportedLanguages: [Language] = [
        Language(code: "tr", name: "Türkçe", englishName: "Turkish", flag: "🇹🇷"),
        Language(code: "en", name: "English", englishName: "English", flag: "🇬🇧")
    ]
    
    private init() {
        // Load saved language preference or default to Turkish
        self.currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "tr"
    }
    
    // MARK: - Language Management
    func setLanguage(_ code: String) {
        guard supportedLanguages.contains(where: { $0.code == code }) else {
            return
        }
        currentLanguage = code
    }
    
    // Get current language details
    var currentLanguageInfo: Language {
        return supportedLanguages.first { $0.code == currentLanguage } ?? supportedLanguages[0]
    }
}

// MARK: - Language Model
struct Language: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let name: String
    let englishName: String
    let flag: String
    
    var displayName: String {
        return "\(flag) \(name)"
    }
}

// MARK: - View Modifier for Language Change Detection
struct LanguageChangeModifier: ViewModifier {
    @ObservedObject private var languageManager = LanguageManager.shared
    
    func body(content: Content) -> some View {
        content
            .environment(\.locale, Locale(identifier: languageManager.currentLanguage))
            .id(languageManager.currentLanguage)
    }
}

extension View {
    func detectLanguageChange() -> some View {
        modifier(LanguageChangeModifier())
    }
}