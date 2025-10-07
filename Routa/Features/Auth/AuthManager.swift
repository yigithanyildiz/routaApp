import Foundation
import FirebaseAuth
import FirebaseCore
import Combine
import GoogleSignIn

enum AppState {
    case onboarding
    case gateway
    case authenticated
    case guest
}

class AuthManager: ObservableObject {
    @Published var user: User? = nil
    @Published var isAuthenticated = false
    @Published var isGuest = false
    @Published var appState: AppState = .gateway

    // Favorites manager - always available, cleaned up on logout
    @Published var favoritesManager: FavoritesManager

    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Initialize favorites manager once and keep it alive
        favoritesManager = FavoritesManager()
        configureAuthStateListener()
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func configureAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            DispatchQueue.main.async {
                if let firebaseUser = firebaseUser {
                    self?.user = User(
                        id: firebaseUser.uid,
                        email: firebaseUser.email ?? "",
                        displayName: firebaseUser.displayName
                    )
                    self?.isAuthenticated = true
                    self?.isGuest = false
                    self?.appState = .authenticated

                    // Favorites manager is already initialized, it will handle user state automatically
                } else {
                    self?.user = nil
                    self?.isAuthenticated = false

                    // Clean up favorites manager when user logs out but keep instance alive
                    self?.favoritesManager.performCleanup()

                    if self?.isGuest == true {
                        self?.appState = .guest
                    } else {
                        self?.appState = .gateway
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func signUp(email: String, password: String, fullName: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let user = result?.user, let fullName = fullName, !fullName.isEmpty {
                    // Update the user's display name
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = fullName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func signOut() {
        do {
            // Clean up favorites manager before signing out
            favoritesManager.performCleanup()

            try Auth.auth().signOut()

            isGuest = false
            appState = .gateway
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    // MARK: - Favorites Manager
    // FavoritesManager is initialized once in init() and handles user state changes automatically

    func continueAsGuest(completion: (() -> Void)? = nil) {
        print("🟢 continueAsGuest() called")
        print("🟢 Before: isGuest=\(isGuest), isAuthenticated=\(isAuthenticated), appState=\(appState)")

        DispatchQueue.main.async { [weak self] in
            self?.isGuest = true
            self?.isAuthenticated = false
            self?.user = nil
            self?.appState = .guest

            print("🟢 After: isGuest=\(self?.isGuest ?? false), isAuthenticated=\(self?.isAuthenticated ?? false), appState=\(self?.appState ?? .gateway)")

            // Call completion handler to ensure state is updated
            completion?()
        }
    }

    // MARK: - Google Sign-In
    func signInWithGoogle(presenting: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase clientID not found"])))
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get Google credentials"])))
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
