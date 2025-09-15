import SwiftUI

struct GeneratedRouteView: View {
    let destination: Destination
    let travelPlan: TravelPlan
    let onSave: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedDay = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with budget summary
                    headerSection
                    
                    // Day selector
                    daySelectorSection
                    
                    // Daily itinerary
                    if selectedDay < travelPlan.dailyItinerary.count {
                        dailyItinerarySection(for: travelPlan.dailyItinerary[selectedDay])
                    }
                    
                    // Save button
                    saveButton
                        .padding()
                }
            }
            .navigationTitle("Oluşturulan Rota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Destination info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(destination.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("\(travelPlan.duration) Gün")
                        Text("•")
                        Text(travelPlan.budgetType.displayName)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(travelPlan.budgetType.icon)
                    .font(.system(size: 40))
            }
            
            // Budget breakdown
            VStack(spacing: 12) {
                HStack {
                    Text("Toplam Bütçe")
                        .font(.headline)
                    Spacer()
                    Text("₺\(Int(travelPlan.totalBudget.total))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                // Budget categories
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    BudgetCategoryView(title: "Konaklama", amount: travelPlan.totalBudget.accommodation, icon: "bed.double.fill")
                    BudgetCategoryView(title: "Yemek", amount: travelPlan.totalBudget.food, icon: "fork.knife")
                    BudgetCategoryView(title: "Ulaşım", amount: travelPlan.totalBudget.transportation, icon: "car.fill")
                    BudgetCategoryView(title: "Aktivite", amount: travelPlan.totalBudget.activities, icon: "ticket.fill")
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
    }
    
    // MARK: - Day Selector Section
    private var daySelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<travelPlan.duration, id: \.self) { day in
                    Button(action: { selectedDay = day }) {
                        VStack(spacing: 4) {
                            Text("Gün")
                                .font(.caption)
                            Text("\(day + 1)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(width: 60, height: 60)
                        .background(selectedDay == day ? Color.blue : Color(.systemGray6))
                        .foregroundColor(selectedDay == day ? .white : .primary)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }
    
    // MARK: - Daily Itinerary Section
    private func dailyItinerarySection(for dayPlan: DayPlan) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Places to visit
            VStack(alignment: .leading, spacing: 12) {
                Label("Ziyaret Edilecek Yerler", systemImage: "mappin.and.ellipse")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(dayPlan.places) { place in
                    PlaceCard(place: place)
                        .padding(.horizontal)
                }
            }
            
            // Meals
            VStack(alignment: .leading, spacing: 12) {
                Label("Yemek Önerileri", systemImage: "fork.knife")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(dayPlan.meals) { meal in
                    MealCard(meal: meal)
                        .padding(.horizontal)
                }
            }
            
            // Accommodation
            if let accommodation = dayPlan.accommodation {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Konaklama", systemImage: "bed.double.fill")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    AccommodationCard(accommodation: accommodation)
                        .padding(.horizontal)
                }
            }
            
            // Daily cost
            HStack {
                Text("Günlük Tahmini Maliyet")
                    .font(.subheadline)
                Spacer()
                Text("₺\(Int(dayPlan.estimatedCost))")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: onSave) {
            HStack {
                Image(systemName: "square.and.arrow.down.fill")
                Text("Rotayı Kaydet")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.green, .green.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

// MARK: - Budget Category View
struct BudgetCategoryView: View {
    let title: String
    let amount: Double
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("₺\(Int(amount))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Place Card
struct PlaceCard: View {
    let place: Place
    
    var body: some View {
        HStack {
            // Place type icon
            Text(place.type.icon)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack {
                    Label("\(place.visitDuration) dk", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let fee = place.entranceFee, fee > 0 {
                        Label("₺\(Int(fee))", systemImage: "ticket")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Meal Card
struct MealCard: View {
    let meal: Meal
    
    var body: some View {
        HStack {
            // Meal type icon
            Image(systemName: mealIcon)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 40, height: 40)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(meal.restaurant.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(meal.restaurant.cuisine)
                        .font(.caption)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(String(repeating: "$", count: meal.restaurant.priceRange))
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            Text("₺\(Int(meal.estimatedCost))")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var mealIcon: String {
        switch meal.type {
        case .breakfast: return "sun.horizon.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "cup.and.saucer.fill"
        }
    }
}

// MARK: - Accommodation Card
struct AccommodationCard: View {
    let accommodation: Accommodation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(accommodation.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(accommodation.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₺\(Int(accommodation.pricePerNight))")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("/ gece")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Amenities
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(accommodation.amenities, id: \.self) { amenity in
                        Text(amenity)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    GeneratedRouteView(
        destination: MockData.destinations[0],
        travelPlan: MockData.generateSamplePlan(
            for: MockData.destinations[0],
            budgetType: .standard
        ),
        onSave: {}
    )
}
