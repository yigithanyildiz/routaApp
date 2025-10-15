import Foundation
import UIKit

// MARK: - UserDefaults Keys
extension UserDefaults {
    private enum Keys {
        static let profilePhotoData = "profilePhotoData"
    }

    // MARK: - Profile Photo
    var profilePhoto: UIImage? {
        get {
            guard let data = data(forKey: Keys.profilePhotoData) else { return nil }
            return UIImage(data: data)
        }
        set {
            if let image = newValue {
                // Compress image before saving
                if let data = image.jpegData(compressionQuality: 0.8) {
                    set(data, forKey: Keys.profilePhotoData)
                }
            } else {
                removeObject(forKey: Keys.profilePhotoData)
            }
        }
    }

    func clearProfilePhoto() {
        removeObject(forKey: Keys.profilePhotoData)
    }
}

// MARK: - Profile Photo Manager
class ProfilePhotoManager {
    static let shared = ProfilePhotoManager()

    private init() {}

    func saveProfilePhoto(_ image: UIImage) {
        UserDefaults.standard.profilePhoto = image
    }

    func loadProfilePhoto() -> UIImage? {
        return UserDefaults.standard.profilePhoto
    }

    func deleteProfilePhoto() {
        UserDefaults.standard.clearProfilePhoto()
    }

    // Resize image to save space
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }
}
