import Foundation

// MARK: - Mock Data Provider
struct MockData {
    
    // MARK: - Destinations
    static let destinations: [Destination] = [
        Destination(
            id: "istanbul",
            name: "İstanbul",
            country: "Türkiye",
            description: "Asya ve Avrupa'yı birleştiren, tarihi ve modern yapısıyla büyüleyen şehir. Ayasofya, Topkapı Sarayı ve Kapalıçarşı gibi eşsiz tarihi mekanları barındırır.",
            imageURL: "https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=800&q=80",
            popularMonths: ["Nisan", "Mayıs", "Eylül", "Ekim"],
            averageTemperature: Destination.Temperature(summer: 28, winter: 8),
            currency: "TRY",
            language: "Türkçe",
            coordinates: Destination.Coordinates(latitude: 41.0082, longitude: 28.9784),
            address: "İstanbul, Türkiye",
            popularPlaces: [
                PopularPlace(
                    id: "galata-tower",
                    name: "Galata Kulesi",
                    type: "Tarihi Yapı",
                    coordinate: PopularPlace.Coordinates(latitude: 41.0256, longitude: 28.9742),
                    rating: 4.6,
                    imageURL: "https://images.unsplash.com/photo-1597933534024-debb6104af15?w=400&q=80",
                    description: "İstanbul'un simgesi, panoramik şehir manzarası"
                ),
                PopularPlace(
                    id: "hagia-sophia",
                    name: "Ayasofya",
                    type: "Tarihi Yapı",
                    coordinate: PopularPlace.Coordinates(latitude: 41.0086, longitude: 28.9802),
                    rating: 4.8,
                    imageURL: "https://images.unsplash.com/photo-1565008576549-57569a49371d?w=400&q=80",
                    description: "Bizans mimarisinin başyapıtı"
                ),
                PopularPlace(
                    id: "grand-bazaar",
                    name: "Kapalıçarşı",
                    type: "Alışveriş",
                    coordinate: PopularPlace.Coordinates(latitude: 41.0108, longitude: 28.9680),
                    rating: 4.5,
                    imageURL: "https://images.unsplash.com/photo-1593238666580-84892c9f0bee?w=400&q=80",
                    description: "Dünyanın en eski kapalı çarşısı"
                ),
                PopularPlace(
                    id: "bosphorus",
                    name: "Boğaziçi",
                    type: "Doğal Güzellik",
                    coordinate: PopularPlace.Coordinates(latitude: 41.0392, longitude: 29.0064),
                    rating: 4.7,
                    imageURL: "https://images.unsplash.com/photo-1541432901042-2d8bd64b4a9b?w=400&q=80",
                    description: "Avrupa ve Asya'yı ayıran boğaz"
                )
            ],
            climate: "Mild, with cool winters and warm summers. Oceanic climate.",
            costOfLiving: Destination.CostOfLiving(
                level: "Medium",
                symbol: "$$",
                description: "Affordable compared to Western Europe, but prices vary by area.",
                dailyBudgetMin: 30,
                dailyBudgetMax: 100
            ),
            topAttractions: [
                Destination.Attraction(name: "Ayasofya", type: "Museum"),
                Destination.Attraction(name: "Topkapı Sarayı", type: "Palace"),
                Destination.Attraction(name: "Kapalıçarşı", type: "Shopping"),
                Destination.Attraction(name: "Boğaz Turu", type: "Experience")
            ],
            travelStyle: ["Romantic", "Cultural", "Historical", "Culinary"],
            bestFor: ["Couples", "Art Lovers", "History Enthusiasts", "Food Lovers"],
            popularity: 95,
            rating: 4.7,
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Destination(
            id: "paris",
            name: "Paris",
            country: "Fransa",
            description: "Işık şehri Paris, Eyfel Kulesi, Louvre Müzesi ve romantik atmosferiyle dünyanın en çok ziyaret edilen şehirlerinden biri.",
            imageURL: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800&q=80",
            popularMonths: ["Mayıs", "Haziran", "Eylül"],
            averageTemperature: Destination.Temperature(summer: 25, winter: 5),
            currency: "EUR",
            language: "Fransızca",
            coordinates: Destination.Coordinates(latitude: 48.8566, longitude: 2.3522),
            address: "Paris, Fransa",
            popularPlaces: [
                PopularPlace(
                    id: "eiffel-tower",
                    name: "Eyfel Kulesi",
                    type: "Tarihi Yapı",
                    coordinate: PopularPlace.Coordinates(latitude: 48.8584, longitude: 2.2945),
                    rating: 4.6,
                    imageURL: "https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=400&q=80",
                    description: "Paris'in sembolü, demir kule"
                ),
                PopularPlace(
                    id: "louvre",
                    name: "Louvre Müzesi",
                    type: "Müze",
                    coordinate: PopularPlace.Coordinates(latitude: 48.8606, longitude: 2.3376),
                    rating: 4.7,
                    imageURL: "https://images.unsplash.com/photo-1566139030003-04fb693bde96?w=400&q=80",
                    description: "Dünyanın en büyük sanat müzesi"
                ),
                PopularPlace(
                    id: "notre-dame",
                    name: "Notre Dame",
                    type: "Tarihi Yapı",
                    coordinate: PopularPlace.Coordinates(latitude: 48.8530, longitude: 2.3499),
                    rating: 4.5,
                    imageURL: "https://images.unsplash.com/photo-1539650116574-75c0c6d73fb6?w=400&q=80",
                    description: "Gotik mimarinin başyapıtı"
                ),
                PopularPlace(
                    id: "champs-elysees",
                    name: "Champs-Élysées",
                    type: "Alışveriş",
                    coordinate: PopularPlace.Coordinates(latitude: 48.8698, longitude: 2.3076),
                    rating: 4.4,
                    imageURL: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400&q=80",
                    description: "Dünyanın en ünlü caddesi"
                )
            ],
            climate: "Temperate oceanic climate with mild temperatures year-round.",
            costOfLiving: Destination.CostOfLiving(
                level: "High",
                symbol: "$$$",
                description: "Expensive, especially for accommodation and dining.",
                dailyBudgetMin: 100,
                dailyBudgetMax: 300
            ),
            topAttractions: [
                Destination.Attraction(name: "Eyfel Kulesi", type: "Monument"),
                Destination.Attraction(name: "Louvre Müzesi", type: "Museum"),
                Destination.Attraction(name: "Notre Dame", type: "Cathedral"),
                Destination.Attraction(name: "Champs-Élysées", type: "Shopping")
            ],
            travelStyle: ["Romantic", "Cultural", "Artistic", "Luxury"],
            bestFor: ["Couples", "Art Lovers", "Food Enthusiasts", "Fashion"],
            popularity: 98,
            rating: 4.8,
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Destination(
            id: "tokyo",
            name: "Tokyo",
            country: "Japonya",
            description: "Geleneksel ve modern kültürün mükemmel birleşimi. Teknoloji, gastronomi ve tarihi tapınakları bir arada sunar.",
            imageURL: "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800&q=80",
            popularMonths: ["Mart", "Nisan", "Ekim", "Kasım"],
            averageTemperature: Destination.Temperature(summer: 30, winter: 5),
            currency: "JPY",
            language: "Japonca",
            coordinates: Destination.Coordinates(latitude: 35.6762, longitude: 139.6503),
            address: "Tokyo, Japonya",
            popularPlaces: [
                PopularPlace(
                    id: "shibuya",
                    name: "Shibuya Kavşağı",
                    type: "Kent Merkezi",
                    coordinate: PopularPlace.Coordinates(latitude: 35.6598, longitude: 139.7006),
                    rating: 4.5,
                    imageURL: "https://images.unsplash.com/photo-1542051841857-5f90071e7989?w=400&q=80",
                    description: "Dünyanın en yoğun kavşağı"
                ),
                PopularPlace(
                    id: "sensoji",
                    name: "Senso-ji Tapınağı",
                    type: "Tarihi Yapı",
                    coordinate: PopularPlace.Coordinates(latitude: 35.7148, longitude: 139.7967),
                    rating: 4.6,
                    imageURL: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=80",
                    description: "Tokyo'nun en eski tapınağı"
                ),
                PopularPlace(
                    id: "tokyo-tower",
                    name: "Tokyo Tower",
                    type: "Gözlem Kulesi",
                    coordinate: PopularPlace.Coordinates(latitude: 35.6586, longitude: 139.7454),
                    rating: 4.4,
                    imageURL: "https://images.unsplash.com/photo-1536098561742-ca998e48cbcc?w=400&q=80",
                    description: "Tokyo'nun kırmızı kulesi"
                ),
                PopularPlace(
                    id: "meiji-shrine",
                    name: "Meiji Tapınağı",
                    type: "Tarihi Yapı",
                    coordinate: PopularPlace.Coordinates(latitude: 35.6761, longitude: 139.6993),
                    rating: 4.7,
                    imageURL: "https://images.unsplash.com/photo-1528360983277-13d401cdc186?w=400&q=80",
                    description: "Huzurlu Shinto tapınağı"
                )
            ],
            climate: "Humid subtropical climate with hot summers and mild winters.",
            costOfLiving: Destination.CostOfLiving(
                level: "High",
                symbol: "$$$",
                description: "Expensive, especially for transportation and accommodation.",
                dailyBudgetMin: 80,
                dailyBudgetMax: 250
            ),
            topAttractions: [
                Destination.Attraction(name: "Shibuya Kavşağı", type: "Landmark"),
                Destination.Attraction(name: "Senso-ji Tapınağı", type: "Temple"),
                Destination.Attraction(name: "Tokyo Tower", type: "Observation Deck"),
                Destination.Attraction(name: "Meiji Tapınağı", type: "Temple")
            ],
            travelStyle: ["Modern", "Cultural", "Technological", "Culinary"],
            bestFor: ["Tech Enthusiasts", "Food Lovers", "Culture Seekers", "Shopping"],
            popularity: 92,
            rating: 4.7,
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Destination(
            id: "roma",
            name: "Roma",
            country: "İtalya",
            description: "Antik Roma İmparatorluğu'nun başkenti. Kolezyum, Trevi Çeşmesi ve Vatikan gibi tarihi hazinelere ev sahipliği yapar.",
            imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800&q=80",
            popularMonths: ["Nisan", "Mayıs", "Eylül", "Ekim"],
            averageTemperature: Destination.Temperature(summer: 30, winter: 10),
            currency: "EUR",
            language: "İtalyanca",
            coordinates: Destination.Coordinates(latitude: 41.9028, longitude: 12.4964),
            address: "Roma, İtalya",
            popularPlaces: [
                PopularPlace(
                    id: "colosseum",
                    name: "Kolezyum",
                    type: "Tarihi Yapı",
                    coordinate: PopularPlace.Coordinates(latitude: 41.8902, longitude: 12.4922),
                    rating: 4.6,
                    imageURL: "https://images.unsplash.com/photo-1540909180-7a5d38638bb2?w=400&q=80",
                    description: "Antik Roma'nın en büyük amfitiyatrosu"
                ),
                PopularPlace(
                    id: "trevi-fountain",
                    name: "Trevi Çeşmesi",
                    type: "Tarihi Yapı",
                    coordinate: PopularPlace.Coordinates(latitude: 41.9009, longitude: 12.4833),
                    rating: 4.5,
                    imageURL: "https://images.unsplash.com/photo-1555992828-1ba25534ed37?w=400&q=80",
                    description: "Barok tarzda ünlü çeşme"
                ),
                PopularPlace(
                    id: "vatican",
                    name: "Vatikan",
                    type: "Tarihi Yapı",
                    coordinate: PopularPlace.Coordinates(latitude: 41.9029, longitude: 12.4534),
                    rating: 4.7,
                    imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400&q=80",
                    description: "Katoliklerin ruhani merkezi"
                ),
                PopularPlace(
                    id: "pantheon",
                    name: "Pantheon",
                    type: "Tarihi Yapı",
                    coordinate: PopularPlace.Coordinates(latitude: 41.8986, longitude: 12.4769),
                    rating: 4.6,
                    imageURL: "https://images.unsplash.com/photo-1531572753322-ad063cecc140?w=400&q=80",
                    description: "Antik Roma tapınağı"
                )
            ],
            climate: "Mediterranean climate with hot, dry summers and mild winters.",
            costOfLiving: Destination.CostOfLiving(
                level: "Medium-High",
                symbol: "$$",
                description: "Moderate to expensive, tourist areas are pricier.",
                dailyBudgetMin: 60,
                dailyBudgetMax: 200
            ),
            topAttractions: [
                Destination.Attraction(name: "Kolezyum", type: "Monument"),
                Destination.Attraction(name: "Trevi Çeşmesi", type: "Fountain"),
                Destination.Attraction(name: "Vatikan", type: "Religious Site"),
                Destination.Attraction(name: "Pantheon", type: "Temple")
            ],
            travelStyle: ["Historical", "Cultural", "Religious", "Romantic"],
            bestFor: ["History Buffs", "Couples", "Art Lovers", "Foodies"],
            popularity: 90,
            rating: 4.6,
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Destination(
            id: "barcelona",
            name: "Barselona",
            country: "İspanya",
            description: "Gaudi'nin eserleri, muhteşem plajları ve canlı kültürü ile Akdeniz'in incisi. La Sagrada Familia mutlaka görülmeli.",
            imageURL: "https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800&q=80",
            popularMonths: ["Mayıs", "Haziran", "Eylül"],
            averageTemperature: Destination.Temperature(summer: 28, winter: 12),
            currency: "EUR",
            language: "İspanyolca",
            coordinates: Destination.Coordinates(latitude: 41.3851, longitude: 2.1734),
            address: "Barcelona, İspanya",
            popularPlaces: [
                PopularPlace(
                    id: "sagrada-familia",
                    name: "Sagrada Familia",
                    type: "Tarihi Yapı",
                    coordinate: PopularPlace.Coordinates(latitude: 41.4036, longitude: 2.1744),
                    rating: 4.7,
                    imageURL: "https://images.unsplash.com/photo-1583422409516-2895a77efded?w=400&q=80",
                    description: "Gaudi'nin başyapıtı"
                ),
                PopularPlace(
                    id: "park-guell",
                    name: "Park Güell",
                    type: "Park",
                    coordinate: PopularPlace.Coordinates(latitude: 41.4145, longitude: 2.1527),
                    rating: 4.5,
                    imageURL: "https://images.unsplash.com/photo-1564221710304-0b37c8b9d729?w=400&q=80",
                    description: "Gaudi'nin mozaik parkı"
                ),
                PopularPlace(
                    id: "gothic-quarter",
                    name: "Gotik Mahalle",
                    type: "Tarihi Bölge",
                    coordinate: PopularPlace.Coordinates(latitude: 41.3837, longitude: 2.1769),
                    rating: 4.4,
                    imageURL: "https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=400&q=80",
                    description: "Ortaçağ sokakları"
                ),
                PopularPlace(
                    id: "la-rambla",
                    name: "La Rambla",
                    type: "Cadde",
                    coordinate: PopularPlace.Coordinates(latitude: 41.3808, longitude: 2.1728),
                    rating: 4.3,
                    imageURL: "https://images.unsplash.com/photo-1583422409516-2895a77efded?w=400&q=80",
                    description: "Ünlü yaya caddesi"
                )
            ],
            climate: "Mediterranean climate with mild winters and warm summers.",
            costOfLiving: Destination.CostOfLiving(
                level: "Medium",
                symbol: "$$",
                description: "More affordable than other major European cities.",
                dailyBudgetMin: 50,
                dailyBudgetMax: 180
            ),
            topAttractions: [
                Destination.Attraction(name: "Sagrada Familia", type: "Cathedral"),
                Destination.Attraction(name: "Park Güell", type: "Park"),
                Destination.Attraction(name: "Gotik Mahalle", type: "Historic District"),
                Destination.Attraction(name: "La Rambla", type: "Street")
            ],
            travelStyle: ["Beach", "Cultural", "Architectural", "Culinary"],
            bestFor: ["Beach Lovers", "Architecture Fans", "Foodies", "Nightlife"],
            popularity: 88,
            rating: 4.6,
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    // MARK: - Sample Places for Istanbul
    static let istanbulPlaces: [Place] = [
        Place(
            id: "ayasofya",
            name: "Ayasofya",
            type: .historical,
            description: "537 yılında inşa edilen, Bizans mimarisinin en önemli örneği. Müze olarak hizmet veriyor.",
            address: "Sultan Ahmet, Ayasofya Meydanı No:1, 34122 Fatih/İstanbul",
            coordinates: Place.Coordinates(latitude: 41.0086, longitude: 28.9802),
            visitDuration: 90,
            entranceFee: 0,
            rating: 4.8,
            imageURL: "https://images.unsplash.com/photo-1565008576549-57569a49371d",
            tips: ["Sabah erken saatlerde gidin", "Ses rehberi alabilirsiniz", "Fotoğraf çekimi serbest"]
        ),
        
        Place(
            id: "topkapi",
            name: "Topkapı Sarayı",
            type: .historical,
            description: "Osmanlı padişahlarının 400 yıl boyunca kullandığı saray. Hazine ve kutsal emanetler bölümü mutlaka görülmeli.",
            address: "Cankurtaran, 34122 Fatih/İstanbul",
            coordinates: Place.Coordinates(latitude: 41.0115, longitude: 28.9833),
            visitDuration: 180,
            entranceFee: 320,
            rating: 4.7,
            imageURL: "https://images.unsplash.com/photo-1599423217192-34cc6a2a8d3b",
            tips: ["Harem bölümü ayrı bilet", "En az 3 saat ayırın", "Hafta içi daha sakin"]
        ),
        
        Place(
            id: "kapalıcarsi",
            name: "Kapalıçarşı",
            type: .shopping,
            description: "Dünyanın en eski ve en büyük kapalı çarşılarından biri. 4000'den fazla dükkan bulunuyor.",
            address: "Beyazıt, Kalpakçılar Cd. No:22, 34126 Fatih/İstanbul",
            coordinates: Place.Coordinates(latitude: 41.0108, longitude: 28.9680),
            visitDuration: 120,
            entranceFee: nil,
            rating: 4.5,
            imageURL: "https://images.unsplash.com/photo-1593238666580-84892c9f0bee",
            tips: ["Pazarlık yapmayı unutmayın", "Nakit para bulundurun", "Sahte ürünlere dikkat"]
        ),
        
        Place(
            id: "galata",
            name: "Galata Kulesi",
            type: .viewpoint,
            description: "İstanbul'un simgelerinden biri. 360 derece panoramik şehir manzarası sunar.",
            address: "Bereketzade, Galata Kulesi, 34421 Beyoğlu/İstanbul",
            coordinates: Place.Coordinates(latitude: 41.0256, longitude: 28.9742),
            visitDuration: 60,
            entranceFee: 175,
            rating: 4.6,
            imageURL: "https://images.unsplash.com/photo-1597933534024-debb6104af15",
            tips: ["Gün batımı için ideal", "Kuyruk olabilir", "Online bilet alabilirsiniz"]
        )
    ]
    
    // MARK: - Sample Restaurants
    static let istanbulRestaurants: [Restaurant] = [
        Restaurant(
            id: "pandeli",
            name: "Pandeli",
            cuisine: "Türk Mutfağı",
            priceRange: 3,
            rating: 4.7,
            address: "Rüstem Paşa, Mısır Çarşısı No:1, 34116 Fatih/İstanbul",
            coordinates: Place.Coordinates(latitude: 41.0167, longitude: 28.9709)
        ),
        
        Restaurant(
            id: "hamdi",
            name: "Hamdi Restaurant",
            cuisine: "Kebap",
            priceRange: 3,
            rating: 4.6,
            address: "Rüstem Paşa, Kalçın Sk. No:11, 34116 Fatih/İstanbul",
            coordinates: Place.Coordinates(latitude: 41.0172, longitude: 28.9715)
        ),
        
        Restaurant(
            id: "karakoy_lokantasi",
            name: "Karaköy Lokantası",
            cuisine: "Modern Türk",
            priceRange: 3,
            rating: 4.8,
            address: "Kemankeş Karamustafa Paşa, Kemankeş Cd. No:37/A, 34425 Beyoğlu/İstanbul",
            coordinates: Place.Coordinates(latitude: 41.0235, longitude: 28.9772)
        ),
        
        Restaurant(
            id: "ciya",
            name: "Çiya Sofrası",
            cuisine: "Anadolu Mutfağı",
            priceRange: 2,
            rating: 4.7,
            address: "Caferağa, Güneşli Bahçe Sok. No:43, 34710 Kadıköy/İstanbul",
            coordinates: Place.Coordinates(latitude: 40.9865, longitude: 29.0269)
        )
    ]
    
    // MARK: - Sample Accommodations
    static let accommodations: [Accommodation] = [
        // Budget
        Accommodation(
            id: "sultan_hostel",
            name: "Sultan Hostel",
            type: .hostel,
            pricePerNight: 150,
            rating: 4.5,
            address: "Alemdar, Akbıyık Cd. No:21, 34122 Fatih/İstanbul",
            amenities: ["WiFi", "Kahvaltı", "24 Saat Resepsiyon", "Ortak Mutfak"]
        ),
        
        // Standard
        Accommodation(
            id: "blue_house",
            name: "Blue House Hotel",
            type: .hotel,
            pricePerNight: 450,
            rating: 4.6,
            address: "Sultanahmet, Dalbastı Sk. No:14, 34122 Fatih/İstanbul",
            amenities: ["WiFi", "Kahvaltı", "Klima", "Teras", "Restoran"]
        ),
        
        // Luxury
        Accommodation(
            id: "four_seasons",
            name: "Four Seasons Sultanahmet",
            type: .hotel,
            pricePerNight: 2500,
            rating: 4.9,
            address: "Sultanahmet, Tevkifhane Sk. No:1, 34122 Fatih/İstanbul",
            amenities: ["WiFi", "Kahvaltı", "Spa", "Fitness", "Restoran", "Bar", "Concierge"]
        )
    ]
    
    // MARK: - Sample Travel Plan
    static func generateSamplePlan(for destination: Destination, budgetType: TravelPlan.BudgetType) -> TravelPlan {
        let budget: Budget
        let accommodation: Accommodation
        let mealBudget: Double
        
        switch budgetType {
        case .budget:
            budget = Budget(
                accommodation: 150,
                food: 100,
                transportation: 50,
                activities: 80,
                shopping: 50,
                other: 20
            )
            accommodation = accommodations[0]
            mealBudget = 100
            
        case .standard:
            budget = Budget(
                accommodation: 450,
                food: 200,
                transportation: 100,
                activities: 150,
                shopping: 100,
                other: 50
            )
            accommodation = accommodations[1]
            mealBudget = 200
            
        case .luxury:
            budget = Budget(
                accommodation: 2500,
                food: 500,
                transportation: 300,
                activities: 400,
                shopping: 300,
                other: 100
            )
            accommodation = accommodations[2]
            mealBudget = 500
        }
        
        // Create 3 days itinerary
        var dailyItinerary: [DayPlan] = []
        
        // Day 1
        let day1 = DayPlan(
            id: UUID().uuidString,
            dayNumber: 1,
            date: Date(),
            places: [istanbulPlaces[0], istanbulPlaces[1]], // Ayasofya, Topkapı
            meals: [
                Meal(
                    id: UUID().uuidString,
                    type: .breakfast,
                    restaurant: istanbulRestaurants[3], // Çiya
                    estimatedCost: mealBudget * 0.25
                ),
                Meal(
                    id: UUID().uuidString,
                    type: .lunch,
                    restaurant: istanbulRestaurants[0], // Pandeli
                    estimatedCost: mealBudget * 0.35
                ),
                Meal(
                    id: UUID().uuidString,
                    type: .dinner,
                    restaurant: istanbulRestaurants[1], // Hamdi
                    estimatedCost: mealBudget * 0.40
                )
            ],
            accommodation: accommodation,
            estimatedCost: budget.total
        )
        
        // Day 2
        let day2 = DayPlan(
            id: UUID().uuidString,
            dayNumber: 2,
            date: Date().addingTimeInterval(86400),
            places: [istanbulPlaces[2], istanbulPlaces[3]], // Kapalıçarşı, Galata
            meals: [
                Meal(
                    id: UUID().uuidString,
                    type: .breakfast,
                    restaurant: istanbulRestaurants[2], // Karaköy Lokantası
                    estimatedCost: mealBudget * 0.25
                ),
                Meal(
                    id: UUID().uuidString,
                    type: .lunch,
                    restaurant: istanbulRestaurants[3], // Çiya
                    estimatedCost: mealBudget * 0.35
                ),
                Meal(
                    id: UUID().uuidString,
                    type: .dinner,
                    restaurant: istanbulRestaurants[0], // Pandeli
                    estimatedCost: mealBudget * 0.40
                )
            ],
            accommodation: accommodation,
            estimatedCost: budget.total
        )
        
        // Day 3
        let day3 = DayPlan(
            id: UUID().uuidString,
            dayNumber: 3,
            date: Date().addingTimeInterval(172800),
            places: Array(istanbulPlaces.prefix(2)), // İlk 2 yer tekrar
            meals: [
                Meal(
                    id: UUID().uuidString,
                    type: .breakfast,
                    restaurant: istanbulRestaurants[1], // Hamdi
                    estimatedCost: mealBudget * 0.25
                ),
                Meal(
                    id: UUID().uuidString,
                    type: .lunch,
                    restaurant: istanbulRestaurants[2], // Karaköy
                    estimatedCost: mealBudget * 0.35
                ),
                Meal(
                    id: UUID().uuidString,
                    type: .dinner,
                    restaurant: istanbulRestaurants[3], // Çiya
                    estimatedCost: mealBudget * 0.40
                )
            ],
            accommodation: accommodation,
            estimatedCost: budget.total
        )
        
        dailyItinerary = [day1, day2, day3]
        
        return TravelPlan(
            id: UUID().uuidString,
            destinationId: destination.id,
            budgetType: budgetType,
            duration: 3,
            totalBudget: Budget(
                accommodation: budget.accommodation * 3,
                food: budget.food * 3,
                transportation: budget.transportation * 3,
                activities: budget.activities * 3,
                shopping: budget.shopping * 3,
                other: budget.other * 3
            ),
            dailyItinerary: dailyItinerary,
            createdAt: Date()
        )
    }
}
