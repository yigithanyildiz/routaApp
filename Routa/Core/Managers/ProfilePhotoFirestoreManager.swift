import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - Firestore Profile Photo Manager
class ProfilePhotoFirestoreManager {
    static let shared = ProfilePhotoFirestoreManager()

    private let db = Firestore.firestore()
    private let photoManager = ProfilePhotoManager.shared

    private init() {}

    // MARK: - Upload Profile Photo to Firestore
    func uploadProfilePhoto(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "ProfilePhotoFirestoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }

        // Resize image to reduce size
        let resizedImage = photoManager.resizeImage(image, targetSize: CGSize(width: 400, height: 400))

        // Convert to JPEG with compression
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "ProfilePhotoFirestoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }

        // Convert to Base64 string
        let base64String = imageData.base64EncodedString()

        // Save to Firestore
        let userRef = db.collection("users").document(userId)
        userRef.setData([
            "profilePhotoBase64": base64String,
            "profilePhotoUpdatedAt": FieldValue.serverTimestamp()
        ], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Also save to local cache
                self.photoManager.saveProfilePhoto(resizedImage)
                completion(.success(()))
            }
        }
    }

    // MARK: - Download Profile Photo from Firestore
    func downloadProfilePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "ProfilePhotoFirestoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }

        // First try to load from cache
        if let cachedPhoto = photoManager.loadProfilePhoto() {
            completion(.success(cachedPhoto))

            // Still check Firestore in background for updates
            checkForUpdates(userId: userId, cachedPhoto: cachedPhoto)
            return
        }

        // If not in cache, download from Firestore
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "ProfilePhotoFirestoreManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "No profile photo found"])))
                return
            }

            guard let base64String = document.data()?["profilePhotoBase64"] as? String else {
                completion(.failure(NSError(domain: "ProfilePhotoFirestoreManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "No profile photo found"])))
                return
            }

            // Convert Base64 to image
            guard let imageData = Data(base64Encoded: base64String),
                  let image = UIImage(data: imageData) else {
                completion(.failure(NSError(domain: "ProfilePhotoFirestoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode image"])))
                return
            }

            // Save to cache
            self.photoManager.saveProfilePhoto(image)
            completion(.success(image))
        }
    }

    // MARK: - Delete Profile Photo
    func deleteProfilePhoto(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "ProfilePhotoFirestoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])))
            return
        }

        let userRef = db.collection("users").document(userId)
        userRef.updateData([
            "profilePhotoBase64": FieldValue.delete(),
            "profilePhotoUpdatedAt": FieldValue.delete()
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Also delete from cache
                self.photoManager.deleteProfilePhoto()
                completion(.success(()))
            }
        }
    }

    // MARK: - Clear Cache (on logout)
    func clearCache() {
        photoManager.deleteProfilePhoto()
    }

    // MARK: - Check for updates in background
    private func checkForUpdates(userId: String, cachedPhoto: UIImage) {
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            guard let document = document,
                  document.exists,
                  let base64String = document.data()?["profilePhotoBase64"] as? String,
                  let imageData = Data(base64Encoded: base64String),
                  let newImage = UIImage(data: imageData) else {
                return
            }

            // Compare with cached version (simple check: data size)
            if let cachedData = cachedPhoto.jpegData(compressionQuality: 0.7),
               cachedData.count != imageData.count {
                // Update cache with new version
                self.photoManager.saveProfilePhoto(newImage)
            }
        }
    }

    // MARK: - Real-time listener for profile photo changes
    func listenToProfilePhotoChanges(completion: @escaping (UIImage?) -> Void) -> ListenerRegistration? {
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }

        let userRef = db.collection("users").document(userId)

        return userRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            guard let base64String = document.data()?["profilePhotoBase64"] as? String,
                  let imageData = Data(base64Encoded: base64String),
                  let image = UIImage(data: imageData) else {
                completion(nil)
                return
            }

            // Update cache
            self.photoManager.saveProfilePhoto(image)
            completion(image)
        }
    }
}
