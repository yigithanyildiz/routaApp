import Foundation
import Firebase
import FirebaseFirestore
// MARK: - Firestore Timestamp Extensions
extension Timestamp {
    /// Convert Firestore Timestamp to Date
    var dateValue: Date {
        return self.dateValue()
    }
}

// MARK: - Date Extensions for Firestore
extension Date {
    /// Convert Date to Firestore Timestamp
    var firestoreTimestamp: Timestamp {
        return Timestamp(date: self)
    }
}

// MARK: - GeoPoint Extensions
extension GeoPoint {
    /// Convert GeoPoint to Destination.Coordinates
    var destinationCoordinates: Destination.Coordinates {
        return Destination.Coordinates(latitude: self.latitude, longitude: self.longitude)
    }

    /// Convert GeoPoint to PopularPlace.Coordinates
    var popularPlaceCoordinates: PopularPlace.Coordinates {
        return PopularPlace.Coordinates(latitude: self.latitude, longitude: self.longitude)
    }

    /// Convert GeoPoint to Place.Coordinates
    var placeCoordinates: Place.Coordinates {
        return Place.Coordinates(latitude: self.latitude, longitude: self.longitude)
    }
}

// MARK: - Coordinates Extensions for Firestore
extension Destination.Coordinates {
    /// Convert Destination.Coordinates to GeoPoint
    var geoPoint: GeoPoint {
        return GeoPoint(latitude: self.latitude, longitude: self.longitude)
    }
}

extension PopularPlace.Coordinates {
    /// Convert PopularPlace.Coordinates to GeoPoint
    var geoPoint: GeoPoint {
        return GeoPoint(latitude: self.latitude, longitude: self.longitude)
    }
}

extension Place.Coordinates {
    /// Convert Place.Coordinates to GeoPoint
    var geoPoint: GeoPoint {
        return GeoPoint(latitude: self.latitude, longitude: self.longitude)
    }
}

// MARK: - Firestore Error Handling
extension Error {
    /// Convert general Error to RepositoryError
    var repositoryError: RepositoryError {
        if let repositoryError = self as? RepositoryError {
            return repositoryError
        }

        if let firestoreError = self as NSError? {
            switch firestoreError.code {
            case FirestoreErrorCode.notFound.rawValue:
                return .dataNotFound
            case FirestoreErrorCode.permissionDenied.rawValue:
                return .firebaseError("İzin hatası")
            case FirestoreErrorCode.unavailable.rawValue:
                return .networkError("Firestore hizmeti kullanılamıyor")
            case FirestoreErrorCode.deadlineExceeded.rawValue:
                return .networkError("Zaman aşımı")
            default:
                return .firebaseError(firestoreError.localizedDescription)
            }
        }

        return .networkError(self.localizedDescription)
    }
}

// MARK: - Safe Data Extraction
extension [String: Any] {
    /// Safely extract string value with key
    func safeString(_ key: String, default defaultValue: String = "") -> String {
        return self[key] as? String ?? defaultValue
    }

    /// Safely extract double value with key
    func safeDouble(_ key: String, default defaultValue: Double = 0.0) -> Double {
        return self[key] as? Double ?? defaultValue
    }

    /// Safely extract int value with key
    func safeInt(_ key: String, default defaultValue: Int = 0) -> Int {
        return self[key] as? Int ?? defaultValue
    }

    /// Safely extract array of strings
    func safeStringArray(_ key: String) -> [String] {
        return self[key] as? [String] ?? []
    }

    /// Safely extract nested dictionary
    func safeDictionary(_ key: String) -> [String: Any] {
        return self[key] as? [String: Any] ?? [:]
    }

    /// Safely extract GeoPoint
    func safeGeoPoint(_ key: String) -> GeoPoint? {
        return self[key] as? GeoPoint
    }

    /// Safely extract Timestamp
    func safeTimestamp(_ key: String) -> Timestamp? {
        return self[key] as? Timestamp
    }
}
