import Foundation
import SwiftUI

@MainActor
class RouteGeneratorViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var generatedPlan: TravelPlan?
    @Published var isGenerating = false
    @Published var error: Error?
    
    // Route Parameters
    @Published var selectedDuration: Int = 3
    @Published var selectedBudgetType: TravelPlan.BudgetType = .standard
    @Published var numberOfPeople: Int = 1
    
    // MARK: - Dependencies
    private let routeRepository: RouteRepository
    private let destination: Destination
    
    // MARK: - Computed Properties
    var durationOptions: [Int] {
        [1, 2, 3, 4, 5, 7, 10, 14]
    }
    
    var estimatedTotalBudget: Double {
        let baseBudget: Double
        switch selectedBudgetType {
        case .budget:
            baseBudget = 450 // 150 konaklama + 100 yemek + 50 ulaşım + 80 aktivite + 50 alışveriş + 20 diğer
        case .standard:
            baseBudget = 1050
        case .luxury:
            baseBudget = 4100
        }
        return baseBudget * Double(selectedDuration) * Double(numberOfPeople)
    }
    
    var estimatedDailyBudget: Double {
        estimatedTotalBudget / Double(selectedDuration) / Double(numberOfPeople)
    }
    
    // MARK: - Initialization
    init(destination: Destination, routeRepository: RouteRepository) {
        self.destination = destination
        self.routeRepository = routeRepository
    }
    
    // MARK: - Methods
    func generateRoute() async {
        isGenerating = true
        error = nil
        generatedPlan = nil
        
        do {
            let plan = try await routeRepository.generateRoute(
                for: destination.id,
                budgetType: selectedBudgetType,
                duration: selectedDuration
            )
            
            // Adjust the plan for number of people
            if numberOfPeople > 1 {
                generatedPlan = adjustPlanForPeople(plan, people: numberOfPeople)
            } else {
                generatedPlan = plan
            }
            
        } catch {
            self.error = error
            print("Error generating route: \(error)")
        }
        
        isGenerating = false
    }
    
    func saveRoute() async {
        guard let plan = generatedPlan else { return }
        
        do {
            try await routeRepository.saveRoute(plan)
        } catch {
            self.error = error
            print("Error saving route: \(error)")
        }
    }
    
    private func adjustPlanForPeople(_ plan: TravelPlan, people: Int) -> TravelPlan {
        // Multiply budget by number of people
        let adjustedBudget = Budget(
            accommodation: plan.totalBudget.accommodation * Double(people),
            food: plan.totalBudget.food * Double(people),
            transportation: plan.totalBudget.transportation * Double(people),
            activities: plan.totalBudget.activities * Double(people),
            shopping: plan.totalBudget.shopping * Double(people),
            other: plan.totalBudget.other * Double(people)
        )
        
        // Create new plan with adjusted budget
        return TravelPlan(
            id: plan.id,
            destinationId: plan.destinationId,
            budgetType: plan.budgetType,
            duration: plan.duration,
            totalBudget: adjustedBudget,
            dailyItinerary: plan.dailyItinerary,
            createdAt: plan.createdAt
        )
    }
}

// MARK: - Budget Display Helper
extension TravelPlan.BudgetType {
    var budgetDescription: String {
        switch self {
        case .budget:
            return "Ekonomik seçeneklerle tasarruflu bir seyahat"
        case .standard:
            return "Konfor ve bütçe dengesinde bir seyahat"
        case .luxury:
            return "Premium hizmetler ve konforlu bir deneyim"
        }
    }
    
    var accommodationType: String {
        switch self {
        case .budget:
            return "Hostel / Ekonomik Otel"
        case .standard:
            return "3-4 Yıldızlı Otel"
        case .luxury:
            return "5 Yıldızlı Otel / Butik Otel"
        }
    }
}
