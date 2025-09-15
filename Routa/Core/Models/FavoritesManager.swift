import Foundation
import FirebaseAuth
import Combine

class FavoritesManager: ObservableObject {
    @Published var favoriteIds: Set<String> = []
    @Published var isLoading = false

    // For now, use UserDefaults until Firestore is properly configured
    private let userDefaults = UserDefaults.standard
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupAuthStateListener()
    }

    deinit {
        Task { @MainActor in
            self.cleanup()
        }
    }

    // MARK: - Auth State Management

    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    await self?.setupFavoritesListener(for: user.uid)
                } else {
                    self?.cleanup()
                    self?.favoriteIds.removeAll()
                }
            }
        }
    }

    private func cleanup() {
        // Remove Firebase listeners
        if let authListener = authStateListener {
            Auth.auth().removeStateDidChangeListener(authListener)
            authStateListener = nil
        }

        // Clear Combine cancellables
        cancellables.removeAll()

        // Clear favorite IDs
        favoriteIds.removeAll()

        // Reset loading state
        isLoading = false

        print("🟢 FavoritesManager cleaned up successfully")
    }

    // Public cleanup method for external calls
    func performCleanup() {
        cleanup()
    }

    // MARK: - Local Storage Operations (Temporary)

    private func setupFavoritesListener(for userId: String) async {
        print("🟢 Setting up favorites listener for user: \(userId)")

        // Load favorites from UserDefaults for this user
        let favoritesKey = "favorites_\(userId)"
        if let favoritesData = userDefaults.data(forKey: favoritesKey),
           let favoritesList = try? JSONDecoder().decode([String].self, from: favoritesData) {
            favoriteIds = Set(favoritesList)
            print("🟢 Loaded \(favoriteIds.count) favorites from UserDefaults: \(favoriteIds)")
        } else {
            favoriteIds = []
            print("🟢 No saved favorites found for user")
        }
    }

    func addFavorite(destinationId: String) async {
        guard let user = Auth.auth().currentUser else {
            print("🔴 Cannot add favorite: user not authenticated")
            return
        }

        print("🟢 Adding favorite: \(destinationId)")
        isLoading = true

        // Add to local set
        favoriteIds.insert(destinationId)

        // Save to UserDefaults
        saveFavoritesToUserDefaults(userId: user.uid)

        print("🟢 Successfully added favorite: \(destinationId)")
        RoutaHapticsManager.shared.success()

        isLoading = false
    }

    func removeFavorite(destinationId: String) async {
        guard let user = Auth.auth().currentUser else {
            print("🔴 Cannot remove favorite: user not authenticated")
            return
        }

        print("🟢 Removing favorite: \(destinationId)")
        isLoading = true

        // Remove from local set
        favoriteIds.remove(destinationId)

        // Save to UserDefaults
        saveFavoritesToUserDefaults(userId: user.uid)

        print("🟢 Successfully removed favorite: \(destinationId)")
        RoutaHapticsManager.shared.buttonTap()

        isLoading = false
    }

    // MARK: - Helper Methods

    func isFavorite(destinationId: String) -> Bool {
        // Only return true if user is authenticated and destination is favorited
        guard Auth.auth().currentUser != nil else { return false }
        return favoriteIds.contains(destinationId)
    }

    func toggleFavorite(destinationId: String) async {
        if isFavorite(destinationId: destinationId) {
            await removeFavorite(destinationId: destinationId)
        } else {
            await addFavorite(destinationId: destinationId)
        }
    }

    var favoritesCount: Int {
        // Only return count if user is authenticated
        guard Auth.auth().currentUser != nil else { return 0 }
        return favoriteIds.count
    }

    func getFavoriteDestinations() async -> [Destination] {
        // This method would fetch the actual destination objects
        // For now, return empty array as we'd need to implement
        // a proper way to fetch destinations by IDs
        return []
    }

    // MARK: - UserDefaults Helper

    private func saveFavoritesToUserDefaults(userId: String) {
        // Double check user is still authenticated before saving
        guard Auth.auth().currentUser?.uid == userId else {
            print("🔴 User mismatch or not authenticated, skipping save")
            return
        }

        let favoritesKey = "favorites_\(userId)"
        let favoritesList = Array(favoriteIds)

        if let favoritesData = try? JSONEncoder().encode(favoritesList) {
            userDefaults.set(favoritesData, forKey: favoritesKey)
            print("🟢 Saved \(favoritesList.count) favorites to UserDefaults")
        } else {
            print("🔴 Failed to encode favorites for UserDefaults")
        }
    }
}