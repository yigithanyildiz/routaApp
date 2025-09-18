import Foundation
import Firebase

class FirebasePlaceRepository: PlaceRepository {
    private let db = Firestore.firestore()
    private let placesCollection = "places"

    func fetchPlaces(for destinationId: String) async throws -> [Place] {
        do {
            let snapshot = try await db.collection(placesCollection)
                .whereField("cityId", isEqualTo: destinationId)
                .getDocuments()

            var places: [Place] = []

            for document in snapshot.documents {
                if let place = convertToPlace(from: document) {
                    places.append(place)
                }
            }

            return places
        } catch {
            throw RepositoryError.networkError(error.localizedDescription)
        }
    }

    func fetchPlaceDetails(_ placeId: String) async throws -> Place {
        do {
            let snapshot = try await db.collection(placesCollection)
                .whereField("placeId", isEqualTo: placeId)
                .getDocuments()

            guard let document = snapshot.documents.first else {
                throw RepositoryError.destinationNotFound
            }

            guard let place = convertToPlace(from: document) else {
                throw RepositoryError.decodingError
            }

            return place
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.networkError(error.localizedDescription)
        }
    }

    func searchPlaces(in destinationId: String, query: String) async throws -> [Place] {
        do {
            let snapshot = try await db.collection(placesCollection)
                .whereField("cityId", isEqualTo: destinationId)
                .getDocuments()

            var places: [Place] = []
            let lowercasedQuery = query.lowercased()

            for document in snapshot.documents {
                if let place = convertToPlace(from: document) {
                    if place.name.lowercased().contains(lowercasedQuery) ||
                       place.description.lowercased().contains(lowercasedQuery) {
                        places.append(place)
                    }
                }
            }

            return places
        } catch {
            throw RepositoryError.networkError(error.localizedDescription)
        }
    }

    // MARK: - Private Helper Methods

    private func convertToPlace(from document: QueryDocumentSnapshot) -> Place? {
        let data = document.data()

        guard let placeId = data["placeId"] as? String,
              let name = data["name"] as? String,
              let description = data["description"] as? String else {
            return nil
        }

        // Parse coordinates
        let coordinates: Place.Coordinates
        if let geoPoint = data["coordinates"] as? GeoPoint {
            coordinates = Place.Coordinates(
                latitude: geoPoint.latitude,
                longitude: geoPoint.longitude
            )
        } else if let coordsDict = data["coordinates"] as? [String: Any],
                  let lat = coordsDict["latitude"] as? Double,
                  let lng = coordsDict["longitude"] as? Double {
            coordinates = Place.Coordinates(latitude: lat, longitude: lng)
        } else {
            return nil
        }

        // Parse place type from category field
        let typeString = data["category"] as? String ?? "historical"
        let placeType = Place.PlaceType(rawValue: typeString) ?? .historical

        // Optional fields
        let address = data["address"] as? String ?? ""
        let visitDuration = data["visitDuration"] as? Int ?? 60 // Default 60 minutes
        let entranceFee = data["entranceFee"] as? Double
        let rating = data["rating"] as? Double
        let imageURL = data["imageURL"] as? String
        let tips = data["tips"] as? [String] ?? []

        return Place(
            id: placeId,
            name: name,
            type: placeType,
            description: description,
            address: address,
            coordinates: coordinates,
            visitDuration: visitDuration,
            entranceFee: entranceFee,
            rating: rating,
            imageURL: imageURL,
            tips: tips
        )
    }
}
