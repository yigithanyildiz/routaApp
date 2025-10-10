import Foundation
import Firebase
import FirebaseAuth

class FirebaseDestinationRepository: DestinationRepository {
    private let db = Firestore.firestore()
    private let citiesCollection = "cities"
    private let placesCollection = "places"

    func fetchAllDestinations() async throws -> [Destination] {
        do {
            // Cache'den önce deneme
            let snapshot = try await db.collection(citiesCollection)
                .getDocuments(source: .default) // Cache-first stratejisi

            // Paralel olarak tüm destinasyonları ve places'leri çek
            let destinations = try await withThrowingTaskGroup(of: Destination?.self) { group in
                for document in snapshot.documents {
                    group.addTask {
                        return try await self.convertToDestination(from: document)
                    }
                }

                var results: [Destination] = []
                for try await destination in group {
                    if let destination = destination {
                        results.append(destination)
                    }
                }
                return results
            }

            return destinations
        } catch {
            throw RepositoryError.networkError(error.localizedDescription)
        }
    }

    func fetchDestination(by id: String) async throws -> Destination {
        do {
            let documentSnapshot = try await db.collection(citiesCollection)
                .whereField("id", isEqualTo: id)
                .getDocuments()

            guard let document = documentSnapshot.documents.first else {
                throw RepositoryError.destinationNotFound
            }

            guard let destination = try await convertToDestination(from: document) else {
                throw RepositoryError.decodingError
            }

            return destination
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.networkError(error.localizedDescription)
        }
    }

    func searchDestinations(query: String) async throws -> [Destination] {
        do {
            let snapshot = try await db.collection(citiesCollection).getDocuments()

            var destinations: [Destination] = []
            let lowercasedQuery = query.lowercased()

            for document in snapshot.documents {
                if let destination = try await convertToDestination(from: document) {
                    if destination.name.lowercased().contains(lowercasedQuery) ||
                       destination.country.lowercased().contains(lowercasedQuery) {
                        destinations.append(destination)
                    }
                }
            }

            return destinations
        } catch {
            throw RepositoryError.networkError(error.localizedDescription)
        }
    }

    func fetchPopularDestinations() async throws -> [Destination] {
        // Cache kullanarak optimize et - popüler destinasyonları önce cache'den al
        do {
            let snapshot = try await db.collection(citiesCollection)
                .limit(to: 5) // Popüler destinasyonlar için limit
                .getDocuments(source: .cache) // Önce cache'den dene

            if !snapshot.documents.isEmpty {
                // Cache'den geldi, paralel parse et
                let destinations = try await withThrowingTaskGroup(of: Destination?.self) { group in
                    for document in snapshot.documents {
                        group.addTask {
                            return try await self.convertToDestination(from: document)
                        }
                    }

                    var results: [Destination] = []
                    for try await destination in group {
                        if let destination = destination {
                            results.append(destination)
                        }
                    }
                    return results
                }
                return destinations
            }
        } catch {
            // Cache yoksa normal fetch
        }

        // Cache yoksa normal fetch
        return try await fetchAllDestinations()
    }

    // MARK: - Private Helper Methods

    private func convertToDestination(from document: QueryDocumentSnapshot) async throws -> Destination? {
        let data = document.data()

        guard let cityId = data["id"] as? String,
              let name = data["name"] as? String,
              let country = data["country"] as? String,
              let description = data["description"] as? String,
              let imageURL = data["imageURL"] as? String,
              let currency = data["currency"] as? String,
              let language = data["language"] as? String,
              let address = data["address"] as? String else {
            return nil
        }

        // Parse coordinates
        let coordinates: Destination.Coordinates
        if let geoPoint = data["coordinates"] as? GeoPoint {
            coordinates = Destination.Coordinates(
                latitude: geoPoint.latitude,
                longitude: geoPoint.longitude
            )
        } else if let coordsDict = data["coordinates"] as? [String: Any],
                  let lat = coordsDict["latitude"] as? Double,
                  let lng = coordsDict["longitude"] as? Double {
            coordinates = Destination.Coordinates(latitude: lat, longitude: lng)
        } else {
            return nil
        }

        // Parse temperature
        let temperature: Destination.Temperature
        if let tempDict = data["averageTemperature"] as? [String: Any],
           let summer = tempDict["summer"] as? Int,
           let winter = tempDict["winter"] as? Int {
            temperature = Destination.Temperature(summer: summer, winter: winter)
        } else {
            temperature = Destination.Temperature(summer: 25, winter: 10) // Default values
        }

        // Parse popular months
        let popularMonths = data["popularMonths"] as? [String] ?? []

        // Fetch popular places for this city
        let popularPlaces = try await fetchPopularPlaces(for: cityId)

        // Parse new optional fields
        let climate = data["climate"] as? String

        // Parse cost of living
        let costOfLiving: Destination.CostOfLiving?
        if let costDict = data["costOfLiving"] as? [String: Any],
           let level = costDict["level"] as? String,
           let symbol = costDict["symbol"] as? String,
           let desc = costDict["description"] as? String,
           let minBudget = costDict["dailyBudgetMin"] as? Int,
           let maxBudget = costDict["dailyBudgetMax"] as? Int {
            costOfLiving = Destination.CostOfLiving(
                level: level,
                symbol: symbol,
                description: desc,
                dailyBudgetMin: minBudget,
                dailyBudgetMax: maxBudget
            )
        } else {
            costOfLiving = nil
        }

        // Parse top attractions
        let topAttractions: [Destination.Attraction]?
        if let attractionsArray = data["topAttractions"] as? [[String: Any]] {
            topAttractions = attractionsArray.compactMap { attractionDict in
                guard let name = attractionDict["name"] as? String else { return nil }
                let type = attractionDict["type"] as? String
                return Destination.Attraction(name: name, type: type)
            }
        } else {
            topAttractions = nil
        }

        // Parse travel style and best for
        let travelStyle = data["travelStyle"] as? [String]
        let bestFor = data["bestFor"] as? [String]

        // Parse metadata
        let popularity = data["popularity"] as? Int
        let rating = data["rating"] as? Double

        // Parse timestamps
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()

        return Destination(
            id: cityId,
            name: name,
            country: country,
            description: description,
            imageURL: imageURL,
            popularMonths: popularMonths,
            averageTemperature: temperature,
            currency: currency,
            language: language,
            coordinates: coordinates,
            address: address,
            popularPlaces: popularPlaces,
            climate: climate,
            costOfLiving: costOfLiving,
            topAttractions: topAttractions,
            travelStyle: travelStyle,
            bestFor: bestFor,
            popularity: popularity,
            rating: rating,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    private func fetchPopularPlaces(for cityId: String) async throws -> [PopularPlace] {
        do {
            let snapshot = try await db.collection(placesCollection)
                .whereField("cityId", isEqualTo: cityId)
                .limit(to: 10) // Performans için limit ekle
                .getDocuments(source: .default) // Cache-first

            let popularPlaces = snapshot.documents.compactMap { document in
                return convertToPopularPlace(from: document)
            }

            return popularPlaces
        } catch {
            return []
        }
    }

    private func convertToPopularPlace(from document: QueryDocumentSnapshot) -> PopularPlace? {
        let data = document.data()

        guard let placeId = data["id"] as? String,
              let name = data["name"] as? String,
              let description = data["description"] as? String,
              let imageURL = data["imageURL"] as? String,
              let rating = data["rating"] as? Double else {
            return nil
        }

        // Parse coordinates
        let coordinates: PopularPlace.Coordinates
        if let geoPoint = data["coordinates"] as? GeoPoint {
            coordinates = PopularPlace.Coordinates(
                latitude: geoPoint.latitude,
                longitude: geoPoint.longitude
            )
        } else if let coordsDict = data["coordinates"] as? [String: Any],
                  let lat = coordsDict["latitude"] as? Double,
                  let lng = coordsDict["longitude"] as? Double {
            coordinates = PopularPlace.Coordinates(latitude: lat, longitude: lng)
        } else {
            return nil
        }

        // Get type field in Firestore
        let type = data["type"] as? String ?? "Genel"

        return PopularPlace(
            id: placeId,
            name: name,
            type: type,
            coordinate: coordinates,
            rating: rating,
            imageURL: imageURL,
            description: description
        )
    }
}
