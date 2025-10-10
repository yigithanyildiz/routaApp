import SwiftUI

// MARK: - Comparison View Container
struct ComparisonViewContainer: View {
    let dependencyContainer: DependencyContainer
    @StateObject private var viewModel: ComparisonViewModel

    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        _viewModel = StateObject(wrappedValue: ComparisonViewModel(
            destinationRepository: dependencyContainer.destinationRepository
        ))
    }

    var body: some View {
        ComparisonView(viewModel: viewModel)
    }
}

// MARK: - Comparison View
struct ComparisonView: View {
    @ObservedObject var viewModel: ComparisonViewModel
    @EnvironmentObject var dependencyContainer: DependencyContainer
    @State private var showingDestinationPicker = false
    @State private var editingSide: ComparisonSide?

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Sticky Destination Cards Grid
                    destinationCardsGrid
                        .background(Color.routaBackground.opacity(0.95))
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 16)

                    if let left = viewModel.leftDestination, let right = viewModel.rightDestination {
                        // Comparison Sections
                        VStack(spacing: 0) {
                            climateSection(left: left, right: right)
                            costOfLivingSection(left: left, right: right)
                            topAttractionsSection(left: left, right: right)
                            travelStyleSection(left: left, right: right)
                            bestForSection(left: left, right: right)
                        }

                        // Suggested Alternatives
                        suggestedAlternativesSection
                            .padding(.top, 24)
                    } else {
                        emptyStateView
                            .padding(.vertical, 60)
                    }
                }
                .padding(.bottom, LayoutConstants.tabBarHeight + 20)
            }
        }
        .background(Color.routaBackground)
        .navigationTitle("Compare Destinations")
        .navigationBarTitleDisplayMode(.inline)
        .dynamicIslandBlur()
        .sheet(isPresented: $showingDestinationPicker) {
            if let side = editingSide {
                DestinationPickerSheet(
                    destinations: viewModel.getAvailableDestinationsForSide(side),
                    selectedDestination: side == .left ? viewModel.leftDestination : viewModel.rightDestination,
                    onSelect: { destination in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.selectDestination(destination, for: side)
                        }
                        showingDestinationPicker = false
                        editingSide = nil
                    }
                )
            }
        }
        .task {
            // Load destinations when view first appears
            await viewModel.loadDestinations()
        }
        .onChange(of: showingDestinationPicker) { isShowing in
            // Ensure destinations are loaded before showing sheet
            if isShowing && viewModel.availableDestinations.isEmpty {
                Task {
                    await viewModel.loadDestinations()
                }
            }
        }
    }

    // MARK: - Destination Cards Grid
    private var destinationCardsGrid: some View {
        HStack(spacing: 16) {
            // Left Destination
            GridDestinationCard(
                destination: viewModel.leftDestination,
                title: viewModel.leftDestination?.name ?? "Select City"
            ) {
                editingSide = .left
                showingDestinationPicker = true
            }

            // Right Destination
            GridDestinationCard(
                destination: viewModel.rightDestination,
                title: viewModel.rightDestination?.name ?? "Select City",
                isAddButton: viewModel.rightDestination == nil
            ) {
                editingSide = .right
                showingDestinationPicker = true
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.left.arrow.right.circle")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))

            Text("Select destinations to compare")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Tap on the cards above to choose destinations")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Climate Section
    private func climateSection(left: Destination, right: Destination) -> some View {
        ComparisonSection(title: "CLIMATE") {
            HStack(spacing: 0) {
                VStack(alignment: .center, spacing: 8) {
                    if let climate = left.climate {
                        Text(climate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)

                Divider()
                    .frame(height: 60)

                VStack(alignment: .center, spacing: 8) {
                    if let climate = right.climate {
                        Text(climate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Cost of Living Section
    private func costOfLivingSection(left: Destination, right: Destination) -> some View {
        ComparisonSection(title: "COST OF LIVING") {
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    if let cost = left.costOfLiving {
                        HStack(spacing: 4) {
                            Text(cost.symbol)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(costColor(for: cost.level))

                            Text(cost.level)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }

                        Text(cost.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)

                Divider()
                    .frame(height: 80)

                VStack(spacing: 4) {
                    if let cost = right.costOfLiving {
                        HStack(spacing: 4) {
                            Text(cost.symbol)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(costColor(for: cost.level))

                            Text(cost.level)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }

                        Text(cost.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Top Attractions Section
    private func topAttractionsSection(left: Destination, right: Destination) -> some View {
        ComparisonSection(title: "TOP ATTRACTIONS") {
            HStack(spacing: 0) {
                VStack(alignment: .center, spacing: 8) {
                    if let attractions = left.topAttractions, !attractions.isEmpty {
                        ForEach(attractions.prefix(3), id: \.name) { attraction in
                            Text(attraction.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else if !left.popularPlaces.isEmpty {
                        // Fallback: show popularPlaces if topAttractions is missing
                        ForEach(left.popularPlaces.prefix(3)) { place in
                            Text(place.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)

                Divider()
                    .frame(height: 80)

                VStack(alignment: .center, spacing: 8) {
                    if let attractions = right.topAttractions, !attractions.isEmpty {
                        ForEach(attractions.prefix(3), id: \.name) { attraction in
                            Text(attraction.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else if !right.popularPlaces.isEmpty {
                        // Fallback: show popularPlaces if topAttractions is missing
                        ForEach(right.popularPlaces.prefix(3)) { place in
                            Text(place.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Travel Style Section
    private func travelStyleSection(left: Destination, right: Destination) -> some View {
        ComparisonSection(title: "TRAVEL STYLE") {
            HStack(spacing: 0) {
                VStack(alignment: .center, spacing: 8) {
                    if let styles = left.travelStyle, !styles.isEmpty {
                        Text(styles.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)

                Divider()
                    .frame(height: 60)

                VStack(alignment: .center, spacing: 8) {
                    if let styles = right.travelStyle, !styles.isEmpty {
                        Text(styles.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Best For Section
    private func bestForSection(left: Destination, right: Destination) -> some View {
        ComparisonSection(title: "BEST FOR") {
            HStack(spacing: 0) {
                VStack(alignment: .center, spacing: 6) {
                    if let bestFor = left.bestFor, !bestFor.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(bestFor.prefix(3), id: \.self) { category in
                                Text(category)
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.routaPrimary.opacity(0.2))
                                    .foregroundColor(.routaPrimary)
                                    .cornerRadius(12)
                            }
                        }
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)

                Divider()
                    .frame(height: 60)

                VStack(alignment: .center, spacing: 6) {
                    if let bestFor = right.bestFor, !bestFor.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(bestFor.prefix(3), id: \.self) { category in
                                Text(category)
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(12)
                            }
                        }
                    } else {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Suggested Alternatives
    private var suggestedAlternativesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Suggested Alternatives")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("Based on your comparison, you might also like these destinations.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 16) {
                ForEach(viewModel.recommendedAlternatives.prefix(5)) { destination in
                    NavigationLink(destination: ModernDestinationDetailView(destination: destination)
                        .environmentObject(dependencyContainer)) {
                        SuggestedDestinationCard(destination: destination)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func costColor(for level: String) -> Color {
        switch level.lowercased() {
        case "high": return .red
        case "medium-high", "mod-high": return .orange
        case "medium": return .yellow
        default: return .green
        }
    }
}

// MARK: - Grid Destination Card
struct GridDestinationCard: View {
    let destination: Destination?
    let title: String
    var isAddButton: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack {
                        if let destination = destination {
                            CustomAsyncImage(url: destination.imageURL, aspectRatio: 1.0)
                                .frame(width: geometry.size.width, height: geometry.size.width)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    ZStack {
                                        Color.black.opacity(0.3)
                                        Image(systemName: "pencil")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                )
                                .id(destination.id) // Force refresh when destination changes
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.routaCard)
                                .frame(width: geometry.size.width, height: geometry.size.width)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                                        .foregroundColor(.routaTextSecondary.opacity(0.3))
                                )
                                .overlay(
                                    ZStack {
                                        Circle()
                                            .fill(Color.routaPrimary)
                                            .frame(width: 40, height: 40)

                                        Image(systemName: "plus")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                )
                        }
                    }
                }
                .aspectRatio(1.0, contentMode: .fit)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Comparison Section
struct ComparisonSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.routaBackground)

            content
        }
    }
}

// MARK: - Suggested Destination Card
struct SuggestedDestinationCard: View {
    let destination: Destination

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            CustomAsyncImage(url: destination.imageURL, aspectRatio: 2.0)
                .frame(height: 230)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .id(destination.id) // Force refresh when destination changes

            // Gradient Overlay
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(destination.name + (destination.country.isEmpty ? "" : ", \(destination.country)"))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(destination.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
            .padding(16)
        }
    }
}

// MARK: - Destination Picker Sheet
struct DestinationPickerSheet: View {
    let destinations: [Destination]
    let selectedDestination: Destination?
    let onSelect: (Destination) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredDestinations: [Destination] {
        if searchText.isEmpty {
            return destinations
        }
        return destinations.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.country.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredDestinations) { destination in
                        DestinationPickerRow(
                            destination: destination,
                            isSelected: selectedDestination?.id == destination.id
                        ) {
                            onSelect(destination)
                        }
                    }
                }
                .padding()
            }
            .background(Color.routaBackground)
            .searchable(text: $searchText, prompt: "Search destinations...")
            .navigationTitle("Select Destination")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DestinationPickerRow: View {
    let destination: Destination
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                CustomAsyncImage(url: destination.imageURL, aspectRatio: 1.0)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .id(destination.id) // Force refresh when destination changes

                VStack(alignment: .leading, spacing: 4) {
                    Text(destination.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(destination.country)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let rating = destination.rating {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.routaPrimary)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.routaPrimary.opacity(0.05) : Color.routaCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.routaPrimary : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - Helper Views
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - View Model
class ComparisonViewModel: ObservableObject {
    @Published var leftDestination: Destination?
    @Published var rightDestination: Destination?
    @Published var availableDestinations: [Destination] = []
    @Published var recommendedAlternatives: [Destination] = []
    @Published var isLoading = false

    private let destinationRepository: DestinationRepository

    init(destinationRepository: DestinationRepository) {
        self.destinationRepository = destinationRepository
    }

    @MainActor
    func loadDestinations() async {
        guard availableDestinations.isEmpty else { return }

        isLoading = true
        do {
            availableDestinations = try await destinationRepository.fetchAllDestinations()
            updateRecommendedAlternatives()
        } catch {
            print("Failed to load destinations: \(error)")
        }
        isLoading = false
    }

    func selectDestination(_ destination: Destination, for side: ComparisonSide) {
        switch side {
        case .left:
            leftDestination = destination
        case .right:
            rightDestination = destination
        }
        updateRecommendedAlternatives()
    }

    func getAvailableDestinationsForSide(_ side: ComparisonSide) -> [Destination] {
        // Filter out the destination selected on the other side
        switch side {
        case .left:
            // When selecting left, exclude right destination
            if let rightId = rightDestination?.id {
                return availableDestinations.filter { $0.id != rightId }
            }
        case .right:
            // When selecting right, exclude left destination
            if let leftId = leftDestination?.id {
                return availableDestinations.filter { $0.id != leftId }
            }
        }
        return availableDestinations
    }

    private func updateRecommendedAlternatives() {
        let selectedIds = [leftDestination?.id, rightDestination?.id].compactMap { $0 }
        recommendedAlternatives = availableDestinations.filter { !selectedIds.contains($0.id) }
    }
}

// MARK: - Supporting Types
enum ComparisonSide {
    case left
    case right
}
