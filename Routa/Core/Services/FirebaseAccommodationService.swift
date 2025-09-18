import Foundation
import Firebase

class FirebaseAccommodationService {
    private let db = Firestore.firestore()
    private let accommodationsCollection = "accommodations"

    func fetchAccommodations(for cityId: String) async throws -> [Accommodation] {
        do {
            // For İstanbul, use specific document IDs as mentioned
            if cityId == "istanbul" {
                let accommodationIds = ["blue_house", "four_seasons", "sultan_hostel"]
                var accommodations: [Accommodation] = []

                for accommodationId in accommodationIds {
                    do {
                        let document = try await db.collection(accommodationsCollection)
                            .document(accommodationId)
                            .getDocument()

                        if document.exists, let accommodation = convertToAccommodation(from: document) {
                            accommodations.append(accommodation)
                        }
                    } catch {
                        // Continue with other accommodations if one fails
                        print("Failed to fetch accommodation \(accommodationId): \(error)")
                    }
                }

                return accommodations
            } else {
                // For other cities, fetch all accommodations with cityId filter
                let snapshot = try await db.collection(accommodationsCollection)
                    .whereField("cityId", isEqualTo: cityId)
                    .getDocuments()

                var accommodations: [Accommodation] = []

                for document in snapshot.documents {
                    if let accommodation = convertToAccommodation(from: document) {
                        accommodations.append(accommodation)
                    }
                }

                return accommodations
            }
        } catch {
            throw RepositoryError.networkError(error.localizedDescription)
        }
    }

    func fetchAccommodation(by id: String) async throws -> Accommodation {
        do {
            let document = try await db.collection(accommodationsCollection)
                .document(id)
                .getDocument()

            guard document.exists else {
                throw RepositoryError.destinationNotFound
            }

            guard let accommodation = convertToAccommodation(from: document) else {
                throw RepositoryError.decodingError
            }

            return accommodation
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.networkError(error.localizedDescription)
        }
    }

    func fetchAccommodationsByType(_ type: Accommodation.AccommodationType, for cityId: String) async throws -> [Accommodation] {
        do {
            let accommodations = try await fetchAccommodations(for: cityId)
            return accommodations.filter { $0.type == type }
        } catch {
            throw error
        }
    }

    func fetchAccommodationsByPriceRange(minPrice: Double, maxPrice: Double, for cityId: String) async throws -> [Accommodation] {
        do {
            let accommodations = try await fetchAccommodations(for: cityId)
            return accommodations.filter { accommodation in
                accommodation.pricePerNight >= minPrice && accommodation.pricePerNight <= maxPrice
            }
        } catch {
            throw error
        }
    }

    // MARK: - Private Helper Methods

    private func convertToAccommodation(from document: DocumentSnapshot) -> Accommodation? {
        let data = document.data()

        guard let data = data,
              let name = data["name"] as? String,
              let pricePerNight = data["pricePerNight"] as? Double else {
            return nil
        }

        // Parse accommodation type
        let typeString = data["type"] as? String ?? "hotel"
        let accommodationType = Accommodation.AccommodationType(rawValue: typeString) ?? .hotel

        // Optional fields
        let rating = data["rating"] as? Double
        let address = data["address"] as? String ?? ""
        let amenities = data["amenities"] as? [String] ?? []

        return Accommodation(
            id: document.documentID,
            name: name,
            type: accommodationType,
            pricePerNight: pricePerNight,
            rating: rating,
            address: address,
            amenities: amenities
        )
    }
}
