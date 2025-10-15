import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
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
                    // Load user data from Firestore
                    self?.loadUserFromFirestore(firebaseUser: firebaseUser)

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

    private func loadUserFromFirestore(firebaseUser: FirebaseAuth.User) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(firebaseUser.uid)

        userRef.getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    let bio = document.data()?["bio"] as? String
                    self?.user = User(
                        id: firebaseUser.uid,
                        email: firebaseUser.email ?? "",
                        displayName: firebaseUser.displayName,
                        bio: bio
                    )
                } else {
                    // No Firestore document yet, create basic user
                    self?.user = User(
                        id: firebaseUser.uid,
                        email: firebaseUser.email ?? "",
                        displayName: firebaseUser.displayName,
                        bio: nil
                    )
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

            // Note: Profile photo is NOT cleared - it persists across sessions
            // User can manually change it via Edit Profile

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

    // MARK: - Update Profile
    func updateProfile(displayName: String?, bio: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }

        let changeRequest = currentUser.createProfileChangeRequest()

        if let displayName = displayName {
            changeRequest.displayName = displayName
        }

        changeRequest.commitChanges { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            // Save bio to Firestore
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(currentUser.uid)

            var userData: [String: Any] = [:]
            if let bio = bio {
                userData["bio"] = bio
            }

            userRef.setData(userData, merge: true) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // Update local user object
                        if let firebaseUser = Auth.auth().currentUser {
                            self?.user = User(
                                id: firebaseUser.uid,
                                email: firebaseUser.email ?? "",
                                displayName: firebaseUser.displayName,
                                bio: bio
                            )
                        }
                        completion(.success(()))
                    }
                }
            }
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
