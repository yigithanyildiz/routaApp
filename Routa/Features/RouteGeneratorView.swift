import SwiftUI

struct RouteGeneratorView: View {
    let destination: Destination
    @StateObject private var viewModel: RouteGeneratorViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showGeneratedRoute = false
    
    init(destination: Destination, routeRepository: RouteRepository) {
        self.destination = destination
        _viewModel = StateObject(wrappedValue: RouteGeneratorViewModel(
            destination: destination,
            routeRepository: routeRepository
        ))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Duration Selection
                    durationSection
                    
                    // Budget Type Selection
                    budgetTypeSection
                    
                    // Number of People
                    numberOfPeopleSection
                    
                    // Estimated Budget
                    estimatedBudgetSection
                    
                    // Generate Button
                    generateButton
                }
                .padding()
            }
            .navigationTitle("Rota Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showGeneratedRoute) {
                if let plan = viewModel.generatedPlan {
                    GeneratedRouteView(
                        destination: destination,
                        travelPlan: plan,
                        onSave: {
                            Task {
                                await viewModel.saveRoute()
                                dismiss()
                            }
                        }
                    )
                }
            }
            .onChange(of: viewModel.generatedPlan) { newValue in
                if newValue != nil {
                    showGeneratedRoute = true
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Destination Image
            CustomAsyncImage(url: destination.imageURL, aspectRatio: 16/9)
                .frame(height: 150)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.5)]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .cornerRadius(12)
                )
                .overlay(
                    VStack {
                        Spacer()
                        Text(destination.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                    }
                )
            
            Text("Seyahat planınızı özelleştirin")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Duration Section
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Seyahat Süresi", systemImage: "calendar")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.durationOptions, id: \.self) { days in
                        DurationButton(
                            days: days,
                            isSelected: viewModel.selectedDuration == days,
                            action: { viewModel.selectedDuration = days }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Budget Type Section
    private var budgetTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Bütçe Tipi", systemImage: "dollarsign.circle")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(TravelPlan.BudgetType.allCases, id: \.self) { type in
                    BudgetTypeCard(
                        type: type,
                        isSelected: viewModel.selectedBudgetType == type,
                        action: { viewModel.selectedBudgetType = type }
                    )
                }
            }
        }
    }
    
    // MARK: - Number of People Section
    private var numberOfPeopleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Kişi Sayısı", systemImage: "person.2")
                .font(.headline)
            
            HStack {
                Button(action: {
                    if viewModel.numberOfPeople > 1 {
                        viewModel.numberOfPeople -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.numberOfPeople > 1 ? .blue : .gray)
                }
                .disabled(viewModel.numberOfPeople <= 1)
                
                Text("\(viewModel.numberOfPeople) Kişi")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 80)
                
                Button(action: {
                    if viewModel.numberOfPeople < 10 {
                        viewModel.numberOfPeople += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.numberOfPeople < 10 ? .blue : .gray)
                }
                .disabled(viewModel.numberOfPeople >= 10)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Estimated Budget Section
    private var estimatedBudgetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Tahmini Bütçe", systemImage: "banknote")
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Toplam:")
                    Spacer()
                    Text("₺\(Int(viewModel.estimatedTotalBudget))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Kişi Başı Günlük:")
                    Spacer()
                    Text("₺\(Int(viewModel.estimatedDailyBudget))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Generate Button
    private var generateButton: some View {
        Button(action: {
            Task {
                await viewModel.generateRoute()
            }
        }) {
            if viewModel.isGenerating {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    Text("Rota Oluşturuluyor...")
                }
            } else {
                HStack {
                    Image(systemName: "map.fill")
                    Text("Rotayı Oluştur")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [.blue, .blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(.white)
        .fontWeight(.semibold)
        .cornerRadius(12)
        .disabled(viewModel.isGenerating)
    }
}

// MARK: - Duration Button
struct DurationButton: View {
    let days: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(days)")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(days == 1 ? "Gün" : "Gün")
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Budget Type Card
struct BudgetTypeCard: View {
    let type: TravelPlan.BudgetType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(type.icon)
                            .font(.title2)
                        Text(type.displayName)
                            .font(.headline)
                    }
                    
                    Text(type.budgetDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Text(type.accommodationType)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.05) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RouteGeneratorView(
        destination: MockData.destinations[0],
        routeRepository: MockRouteRepository()
    )
}
