import Foundation

// MARK: - Destination Repository Protocol
protocol DestinationRepository {
    func fetchAllDestinations() async throws -> [Destination]
    func fetchDestination(by id: String) async throws -> Destination
    func searchDestinations(query: String) async throws -> [Destination]
    func fetchPopularDestinations() async throws -> [Destination]
}

// MARK: - Route Repository Protocol
protocol RouteRepository {
    func generateRoute(for destinationId: String, budgetType: TravelPlan.BudgetType, duration: Int) async throws -> TravelPlan
    func saveRoute(_ plan: TravelPlan) async throws
    func fetchSavedRoutes() async throws -> [TravelPlan]
    func deleteRoute(_ planId: String) async throws
}

// MARK: - Place Repository Protocol
protocol PlaceRepository {
    func fetchPlaces(for destinationId: String) async throws -> [Place]
    func fetchPlaceDetails(_ placeId: String) async throws -> Place
    func searchPlaces(in destinationId: String, query: String) async throws -> [Place]
}

// MARK: - Repository Errors
enum RepositoryError: LocalizedError {
    case destinationNotFound
    case routeGenerationFailed
    case networkError(String)
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .destinationNotFound:
            return "Destinasyon bulunamadı"
        case .routeGenerationFailed:
            return "Rota oluşturulamadı"
        case .networkError(let message):
            return "Ağ hatası: \(message)"
        case .decodingError:
            return "Veri işleme hatası"
        case .unknown:
            return "Bilinmeyen bir hata oluştu"
        }
    }
}

// MARK: - Mock Implementations
class MockDestinationRepository: DestinationRepository {
    
    func fetchAllDestinations() async throws -> [Destination] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return MockData.destinations
    }
    
    func fetchDestination(by id: String) async throws -> Destination {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let destination = MockData.destinations.first(where: { $0.id == id }) else {
            throw RepositoryError.destinationNotFound
        }
        
        return destination
    }
    
    func searchDestinations(query: String) async throws -> [Destination] {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        let lowercasedQuery = query.lowercased()
        return MockData.destinations.filter { destination in
            destination.name.lowercased().contains(lowercasedQuery) ||
            destination.country.lowercased().contains(lowercasedQuery)
        }
    }
    
    func fetchPopularDestinations() async throws -> [Destination] {
        try await Task.sleep(nanoseconds: 400_000_000)
        // Return first 3 as popular
        return Array(MockData.destinations.prefix(3))
    }
}

class MockRouteRepository: RouteRepository {
    private var savedRoutes: [TravelPlan] = []
    
    func generateRoute(for destinationId: String, budgetType: TravelPlan.BudgetType, duration: Int) async throws -> TravelPlan {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        guard let destination = MockData.destinations.first(where: { $0.id == destinationId }) else {
            throw RepositoryError.destinationNotFound
        }
        
        // Generate a plan with the requested duration
        var plan = MockData.generateSamplePlan(for: destination, budgetType: budgetType)
        
        // Adjust duration if different from default (3 days)
        if duration != 3 {
            // Create daily itinerary for requested duration
            var newItinerary: [DayPlan] = []
            let places = MockData.istanbulPlaces
            let restaurants = MockData.istanbulRestaurants
            
            for day in 0..<duration {
                let dayPlan = DayPlan(
                    id: UUID().uuidString,
                    dayNumber: day + 1,
                    date: Date().addingTimeInterval(Double(day) * 86400),
                    places: Array(places.shuffled().prefix(2)),
                    meals: [
                        Meal(
                            id: UUID().uuidString,
                            type: .breakfast,
                            restaurant: restaurants.randomElement()!,
                            estimatedCost: plan.totalBudget.food / Double(duration) * 0.25
                        ),
                        Meal(
                            id: UUID().uuidString,
                            type: .lunch,
                            restaurant: restaurants.randomElement()!,
                            estimatedCost: plan.totalBudget.food / Double(duration) * 0.35
                        ),
                        Meal(
                            id: UUID().uuidString,
                            type: .dinner,
                            restaurant: restaurants.randomElement()!,
                            estimatedCost: plan.totalBudget.food / Double(duration) * 0.40
                        )
                    ],
                    accommodation: plan.dailyItinerary[0].accommodation,
                    estimatedCost: plan.totalBudget.total / Double(duration)
                )
                newItinerary.append(dayPlan)
            }
            
            // Update plan with new duration and itinerary
            plan = TravelPlan(
                id: plan.id,
                destinationId: plan.destinationId,
                budgetType: plan.budgetType,
                duration: duration,
                totalBudget: Budget(
                    accommodation: plan.totalBudget.accommodation / 3 * Double(duration),
                    food: plan.totalBudget.food / 3 * Double(duration),
                    transportation: plan.totalBudget.transportation / 3 * Double(duration),
                    activities: plan.totalBudget.activities / 3 * Double(duration),
                    shopping: plan.totalBudget.shopping / 3 * Double(duration),
                    other: plan.totalBudget.other / 3 * Double(duration)
                ),
                dailyItinerary: newItinerary,
                createdAt: Date()
            )
        }
        
        return plan
    }
    
    func saveRoute(_ plan: TravelPlan) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        savedRoutes.append(plan)
    }
    
    func fetchSavedRoutes() async throws -> [TravelPlan] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return savedRoutes
    }
    
    func deleteRoute(_ planId: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        savedRoutes.removeAll { $0.id == planId }
    }
}

class MockPlaceRepository: PlaceRepository {
    
    func fetchPlaces(for destinationId: String) async throws -> [Place] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // For now, return Istanbul places for any destination
        // In real app, each destination would have its own places
        return MockData.istanbulPlaces
    }
    
    func fetchPlaceDetails(_ placeId: String) async throws -> Place {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let place = MockData.istanbulPlaces.first(where: { $0.id == placeId }) else {
            throw RepositoryError.destinationNotFound
        }
        
        return place
    }
    
    func searchPlaces(in destinationId: String, query: String) async throws -> [Place] {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        let lowercasedQuery = query.lowercased()
        return MockData.istanbulPlaces.filter { place in
            place.name.lowercased().contains(lowercasedQuery) ||
            place.description.lowercased().contains(lowercasedQuery)
        }
    }
}
