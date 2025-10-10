import Foundation
import MapKit

// MARK: - Destination Model
struct Destination: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let country: String
    let description: String
    let imageURL: String
    let popularMonths: [String]
    let averageTemperature: Temperature
    let currency: String
    let language: String
    let coordinates: Coordinates
    let address: String
    let popularPlaces: [PopularPlace]

    // New fields
    let climate: String?
    let costOfLiving: CostOfLiving?
    let topAttractions: [Attraction]?
    let travelStyle: [String]?
    let bestFor: [String]?
    let popularity: Int?
    let rating: Double?
    let createdAt: Date?
    let updatedAt: Date?

    struct Temperature: Codable, Hashable {
        let summer: Int
        let winter: Int
    }

    struct Coordinates: Codable, Hashable {
        let latitude: Double
        let longitude: Double

        var clLocationCoordinate2D: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    struct CostOfLiving: Codable, Hashable {
        let level: String // "Low", "Medium", "High", "Medium-High"
        let symbol: String // "$", "$$", "$$$"
        let description: String
        let dailyBudgetMin: Int // USD
        let dailyBudgetMax: Int // USD
    }

    struct Attraction: Codable, Hashable {
        let name: String
        let type: String? // "Museum", "Monument", etc.
    }
}

// MARK: - Popular Place Model
struct PopularPlace: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let type: String
    let coordinate: Coordinates
    let rating: Double
    let imageURL: String
    let description: String
    
    struct Coordinates: Codable, Hashable {
        let latitude: Double
        let longitude: Double
        
        var clLocationCoordinate2D: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
}

// MARK: - Travel Plan Model
struct TravelPlan: Identifiable, Codable, Equatable {
    let id: String
    let destinationId: String
    let budgetType: BudgetType
    let duration: Int // days
    let totalBudget: Budget
    let dailyItinerary: [DayPlan]
    let createdAt: Date
    
    enum BudgetType: String, Codable, CaseIterable,Equatable {
        case budget = "budget"
        case standard = "standard"
        case luxury = "luxury"
        
        var displayName: String {
            switch self {
            case .budget: return "Ekonomik"
            case .standard: return "Standart"
            case .luxury: return "Lüks"
            }
        }
        
        var icon: String {
            switch self {
            case .budget: return "🎒"
            case .standard: return "✈️"
            case .luxury: return "👑"
            }
        }
    }
}

// MARK: - Budget Model
struct Budget: Codable, Equatable {
    let accommodation: Double
    let food: Double
    let transportation: Double
    let activities: Double
    let shopping: Double
    let other: Double
    
    var total: Double {
        accommodation + food + transportation + activities + shopping + other
    }
}

// MARK: - Day Plan Model
struct DayPlan: Identifiable, Codable,Equatable  {
    let id: String
    let dayNumber: Int
    let date: Date?
    let places: [Place]
    let meals: [Meal]
    let accommodation: Accommodation?
    let estimatedCost: Double
}

// MARK: - Place Model
struct Place: Identifiable, Codable,Equatable {
    let id: String
    let name: String
    let type: PlaceType
    let description: String
    let address: String
    let coordinates: Coordinates
    let visitDuration: Int // minutes
    let entranceFee: Double?
    let rating: Double?
    let imageURL: String?
    let tips: [String]
    
    enum PlaceType: String, Codable,Equatable {
        case historical = "historical"
        case museum = "museum"
        case park = "park"
        case beach = "beach"
        case shopping = "shopping"
        case viewpoint = "viewpoint"
        case entertainment = "entertainment"
        
        var icon: String {
            switch self {
            case .historical: return "🏛️"
            case .museum: return "🖼️"
            case .park: return "🌳"
            case .beach: return "🏖️"
            case .shopping: return "🛍️"
            case .viewpoint: return "🌅"
            case .entertainment: return "🎭"
            }
        }
    }
    
    struct Coordinates: Codable,Equatable {
        let latitude: Double
        let longitude: Double
    }
}

// MARK: - Meal Model
struct Meal: Identifiable, Codable,Equatable  {
    let id: String
    let type: MealType
    let restaurant: Restaurant
    let estimatedCost: Double
    
    enum MealType: String, Codable, Equatable {
        case breakfast = "breakfast"
        case lunch = "lunch"
        case dinner = "dinner"
        case snack = "snack"
        
        var displayName: String {
            switch self {
            case .breakfast: return "Kahvaltı"
            case .lunch: return "Öğle Yemeği"
            case .dinner: return "Akşam Yemeği"
            case .snack: return "Atıştırmalık"
            }
        }
    }
}

// MARK: - Restaurant Model
struct Restaurant: Identifiable, Codable,Equatable {
    let id: String
    let name: String
    let cuisine: String
    let priceRange: Int // 1-4 ($ - $$$$)
    let rating: Double?
    let address: String
    let coordinates: Place.Coordinates
}

// MARK: - Accommodation Model
struct Accommodation: Identifiable, Codable,Equatable {
    let id: String
    let name: String
    let type: AccommodationType
    let pricePerNight: Double
    let rating: Double?
    let address: String
    let amenities: [String]
    
    enum AccommodationType: String, Codable, Equatable {
        case hotel = "hotel"
        case hostel = "hostel"
        case airbnb = "airbnb"
        case boutique = "boutique"
        
        var displayName: String {
            switch self {
            case .hotel: return "Otel"
            case .hostel: return "Hostel"
            case .airbnb: return "Airbnb"
            case .boutique: return "Butik Otel"
            }
        }
    }
}
