import SwiftUI
import StoreKit
import Foundation
struct ContentView: View {
    @EnvironmentObject var dependencyContainer: DependencyContainer
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        HomeViewContainer(dependencyContainer: dependencyContainer, selectedTab: $selectedTab)
                    }
                case 1:
                    NavigationStack {
                        SearchViewContainer(dependencyContainer: dependencyContainer)
                    }
                case 2:
                    NavigationStack {
                        MyRoutesViewContainer(dependencyContainer: dependencyContainer)
                    }
                case 3:
                    NavigationStack {
                        ProfileViewContainer(dependencyContainer: dependencyContainer)
                    }
                default:
                    NavigationStack {
                        HomeViewContainer(dependencyContainer: dependencyContainer, selectedTab: $selectedTab)
                    }
                }
            }
            
            .background(Color.routaBackground)
            
            // Fixed Tab Bar at Bottom
            RoutaFloatingTabBar(
                items: [
                    RoutaTabItem(icon: "globe", title: "Keşfet", tag: 0),
                    RoutaTabItem(icon: "magnifyingglass", title: "Ara", tag: 1),
                    RoutaTabItem(icon: "map", title: "Rotalarım", tag: 2),
                    RoutaTabItem(icon: "person", title: "Profil", tag: 3)
                ],
                selectedTab: $selectedTab,
                style: .standard
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - View Containers for Dependency Injection
struct HomeViewContainer: View {
    let dependencyContainer: DependencyContainer
    @StateObject private var viewModel: HomeViewModel
    @Binding var selectedTab: Int
    
    init(dependencyContainer: DependencyContainer, selectedTab: Binding<Int>) {
        self.dependencyContainer = dependencyContainer
        self._selectedTab = selectedTab
        _viewModel = StateObject(wrappedValue: HomeViewModel(
            destinationRepository: dependencyContainer.destinationRepository
        ))
    }
    
    var body: some View {
        HomeView(viewModel: viewModel, selectedTab: $selectedTab)
    }
}

// MARK: - Placeholder Views
struct SearchViewContainer: View {
    let dependencyContainer: DependencyContainer
    @StateObject private var viewModel: SearchViewModel
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        _viewModel = StateObject(wrappedValue: SearchViewModel(
            destinationRepository: dependencyContainer.destinationRepository
        ))
    }
    
    var body: some View {
        SearchView(viewModel: viewModel)
    }
}

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @EnvironmentObject var dependencyContainer: DependencyContainer
    @State private var showingFilters = false
    
    private let categories = [
        ("all", "Tümü", "globe"),
        ("historical", "Tarihi", "building.columns"),
        ("beach", "Sahil", "beach.umbrella"),
        ("nature", "Doğa", "leaf")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: RoutaSpacing.lg) {
                // Search Bar
                searchBarSection
                
                // Category Filters
                if viewModel.hasSearched || !viewModel.searchText.isEmpty {
                    categoryFiltersSection
                }
                
                // Main Content
                if viewModel.searchText.isEmpty && !viewModel.hasSearched {
                    searchEmptyStateView
                } else if viewModel.isLoading {
                    searchLoadingView
                } else if let error = viewModel.error {
                    searchErrorView(error)
                } else if viewModel.searchResults.isEmpty && viewModel.hasSearched {
                    searchNoResultsView
                } else {
                    searchResultsView
                }
            }
            .padding(.bottom, LayoutConstants.tabBarHeight)
        }
        .background(Color.routaBackground)
        .toolbar(.hidden, for: .navigationBar)
        .dynamicIslandBlur()
        .sheet(isPresented: $showingFilters) {
            SearchFiltersView(viewModel: viewModel)
        }
    }
    
    private var searchBarSection: some View {
        VStack(spacing: RoutaSpacing.md) {
            // Custom Search Bar
            HStack(spacing: RoutaSpacing.md) {
                HStack(spacing: RoutaSpacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(.routaTextSecondary)
                    
                    TextField("Destinasyon ara...", text: $viewModel.searchText)
                        .font(.routaBody())
                        .onSubmit {
                            Task {
                                await viewModel.searchDestinations()
                            }
                        }
                        .onChange(of: viewModel.searchText) { _, newValue in
                            if newValue.isEmpty {
                                viewModel.clearSearch()
                            } else if newValue.count >= 2 {
                                viewModel.scheduleSearch()
                            }
                        }
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.clearSearch()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.routaTextSecondary)
                        }
                    }
                }
                .padding(RoutaSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.routaSurface)
                )
                .routaShadow(.subtle)
                
                if viewModel.hasSearched {
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18))
                            .foregroundColor(.routaPrimary)
                            .padding(RoutaSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.routaSurface)
                            )
                            .routaShadow(.subtle)
                    }
                }
            }
        }
        .padding(.horizontal, RoutaSpacing.lg)
        .dynamicIslandPadding()
    }
    
    private var categoryFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: RoutaSpacing.md) {
                ForEach(categories, id: \.0) { category in
                    CategoryPill(
                        title: category.1,
                        icon: category.2,
                        isSelected: viewModel.selectedCategory == category.0
                    ) {
                        viewModel.selectedCategory = category.0
                        Task {
                            await viewModel.updateFilters()
                        }
                        RoutaHapticsManager.shared.selection()
                    }
                    .id(category.0)
                }
            }
            .padding(.horizontal, RoutaSpacing.lg)
        }
    }
    
    private var searchEmptyStateView: some View {
        VStack(spacing: RoutaSpacing.xl) {
            Spacer()
            
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(RoutaGradients.primaryGradient.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.routaPrimary)
            }
            
            VStack(spacing: RoutaSpacing.md) {
                Text("Destinasyon Arayın")
                    .routaTitle2()
                    .foregroundColor(.routaText)
                
                Text("Dünyanın en güzel yerlerini keşfetmek için arama yapabilirsiniz")
                    .routaBody()
                    .foregroundColor(.routaTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RoutaSpacing.lg)
            }
            
            // Popular Destinations when empty
            if !viewModel.popularDestinations.isEmpty {
                VStack(spacing: RoutaSpacing.md) {
                    Text("Popüler Destinasyonlar")
                        .routaTitle3()
                        .padding(.top, RoutaSpacing.lg)
                    
                    LazyVStack(spacing: RoutaSpacing.md) {
                        ForEach(viewModel.popularDestinations) { destination in
                            NavigationLink(destination: ModernDestinationDetailView(destination: destination).environmentObject(dependencyContainer)) {
                                ModernDestinationListCard(destination: destination)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .simultaneousGesture(TapGesture().onEnded {
                                RoutaHapticsManager.shared.selection()
                            })
                        }
                    }
                    .padding(.horizontal, RoutaSpacing.lg)
                }
            }
            
            // Recent Searches
            if !viewModel.recentSearches.isEmpty {
                VStack(spacing: RoutaSpacing.md) {
                    Text("Son Aramalar")
                        .routaTitle3()
                        .padding(.top, RoutaSpacing.lg)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: RoutaSpacing.sm) {
                        ForEach(viewModel.recentSearches, id: \.self) { search in
                            Button(search) {
                                viewModel.searchText = search
                                Task {
                                    await viewModel.searchDestinations()
                                }
                            }
                            .font(.routaCaption1())
                            .padding(.horizontal, RoutaSpacing.sm)
                            .padding(.vertical, RoutaSpacing.xs)
                            .background(
                                Capsule()
                                    .fill(Color.routaPrimary.opacity(0.1))
                            )
                            .foregroundColor(.routaPrimary)
                        }
                    }
                    .padding(.horizontal, RoutaSpacing.lg)
                }
            }
            
            Spacer()
        }
    }
    
    private var searchLoadingView: some View {
        VStack(spacing: RoutaSpacing.md) {
            ForEach(0..<3) { _ in
                ShimmerListCard()
            }
        }
        .padding(.horizontal, RoutaSpacing.lg)
    }
    
    private func searchErrorView(_ error: Error) -> some View {
        VStack(spacing: RoutaSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.routaError.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.routaError)
            }
            
            VStack(spacing: RoutaSpacing.md) {
                Text("Arama Hatası")
                    .routaTitle2()
                    .foregroundColor(.routaText)
                
                Text(error.localizedDescription)
                    .routaBody()
                    .foregroundColor(.routaTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RoutaSpacing.lg)
            }
            
            RoutaButton(
                "Tekrar Dene",
                icon: "arrow.clockwise",
                variant: .primary,
                size: .medium
            ) {
                Task {
                    await viewModel.searchDestinations()
                }
                RoutaHapticsManager.shared.buttonTap()
            }
            .padding(.horizontal, RoutaSpacing.xl)
            
            Spacer()
        }
    }
    
    private var searchNoResultsView: some View {
        VStack(spacing: RoutaSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.routaTextSecondary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.routaTextSecondary)
            }
            
            VStack(spacing: RoutaSpacing.md) {
                Text("Sonuç Bulunamadı")
                    .routaTitle2()
                    .foregroundColor(.routaText)
                
                Text("'\(viewModel.searchText)' için herhangi bir destinasyon bulunamadı")
                    .routaBody()
                    .foregroundColor(.routaTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RoutaSpacing.lg)
                
                Text("Farklı anahtar kelimeler deneyebilir veya filtreleri temizleyebilirsiniz")
                    .routaCaption1()
                    .foregroundColor(.routaTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RoutaSpacing.xl)
            }
            
            RoutaButton(
                "Filtreleri Temizle",
                icon: "slider.horizontal.3",
                variant: .outline,
                size: .medium
            ) {
                Task {
                    await viewModel.clearFilters()
                }
                RoutaHapticsManager.shared.buttonTap()
            }
            .padding(.horizontal, RoutaSpacing.xl)
            
            Spacer()
        }
    }
    
    private var searchResultsView: some View {
        VStack(spacing: RoutaSpacing.md) {
            // Results Header
            HStack {
                Text("\(viewModel.searchResults.count) sonuç bulundu")
                    .routaCallout()
                    .foregroundColor(.routaTextSecondary)
                
                Spacer()
                
                // Sort Button
                Button(action: {
                    showingFilters = true
                }) {
                    HStack(spacing: RoutaSpacing.xs) {
                        Text(viewModel.sortOption.displayName)
                            .routaCaption1()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.routaPrimary)
                }
            }
            .padding(.horizontal, RoutaSpacing.lg)
            
            // Results List
            LazyVStack(spacing: RoutaSpacing.md) {
                ForEach(viewModel.searchResults) { destination in
                    NavigationLink(destination: ModernDestinationDetailView(destination: destination).environmentObject(dependencyContainer)) {
                        ModernDestinationListCard(destination: destination)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        RoutaHapticsManager.shared.selection()
                    })
                    .id(destination.id)
                }
            }
            .padding(.horizontal, RoutaSpacing.lg)
        }
    }
}

// MARK: - Search Filter Components

struct CategoryFilter {
    let id: String
    let name: String
    let icon: String
    
    static let categories: [CategoryFilter] = [
        CategoryFilter(id: "all", name: "Tümü", icon: "globe"),
        CategoryFilter(id: "historical", name: "Tarihi", icon: "building.columns"),
        CategoryFilter(id: "beach", name: "Sahil", icon: "beach.umbrella"),
        CategoryFilter(id: "nature", name: "Doğa", icon: "leaf")
    ]
}

struct CategoryFilterButton: View {
    let category: CategoryFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: RoutaSpacing.xs) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .medium))
                Text(category.name)
                    .font(.routaCaption1())
            }
            .foregroundColor(isSelected ? .white : .routaText)
            .padding(.horizontal, RoutaSpacing.md)
            .padding(.vertical, RoutaSpacing.sm)
            .background(backgroundShape)
            .routaShadow(isSelected ? .low : .subtle)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(isSelected ? Color.routaPrimary : Color.routaSurface)
    }
}

struct CountryFilterChip: View {
    let country: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(country ?? "Tümü") {
            action()
        }
        font(.routaCaption1())
        .padding(.horizontal, RoutaSpacing.md)
        .padding(.vertical, RoutaSpacing.sm)
        .background(
            Capsule()
                .fill(isSelected ? Color.routaPrimary : Color.routaSurface)
        )
        .foregroundColor(isSelected ? .white : .routaText)
    }
}

struct SortOptionRow: View {
    let option: SearchViewModel.SearchSortOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option.displayName)
                    .routaCallout()
                    .foregroundColor(.routaText)
                
                Spacer()
                
                selectionIndicator
            }
            .padding(RoutaSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.routaSurface)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var selectionIndicator: some View {
        if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.routaPrimary)
        } else {
            Circle()
                .stroke(Color.routaBorder, lineWidth: 1)
                .frame(width: 20, height: 20)
        }
    }
}

struct SearchFiltersView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismiss) var dismiss
    
    private var hasRecentSearches: Bool {
        !viewModel.recentSearches.isEmpty
    }
    
    private var hasAvailableCountries: Bool {
        !viewModel.availableCountries.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RoutaSpacing.xl) {
                    // Category Filter
                    VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                        Text("Kategori")
                            .routaTitle3()
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: RoutaSpacing.sm) {
                            ForEach(CategoryFilter.categories, id: \.id) { category in
                                CategoryFilterButton(
                                    category: category,
                                    isSelected: viewModel.selectedCategory == category.id
                                ) {
                                    viewModel.selectedCategory = category.id
                                    RoutaHapticsManager.shared.selection()
                                }
                            }
                        }
                    }
                    
                    // Country Filter
                    if hasAvailableCountries {
                        VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                            Text("Ülke")
                                .routaTitle3()
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: RoutaSpacing.sm) {
                                    // All countries option
                                    CountryFilterChip(
                                        country: nil,
                                        isSelected: viewModel.selectedCountry == nil
                                    ) {
                                        viewModel.selectedCountry = nil
                                        RoutaHapticsManager.shared.selection()
                                    }
                                    
                                    ForEach(viewModel.availableCountries, id: \.self) { country in
                                        CountryFilterChip(
                                            country: country,
                                            isSelected: viewModel.selectedCountry == country
                                        ) {
                                            viewModel.selectedCountry = country
                                            RoutaHapticsManager.shared.selection()
                                        }
                                    }
                                }
                                .padding(.horizontal, RoutaSpacing.lg)
                            }
                        }
                    }
                    
                    // Sort Options
                    VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                        Text("Sıralama")
                            .routaTitle3()
                        
                        VStack(spacing: RoutaSpacing.xs) {
                            ForEach(SearchViewModel.SearchSortOption.allCases, id: \.self) { option in
                                SortOptionRow(
                                    option: option,
                                    isSelected: viewModel.sortOption == option
                                ) {
                                    viewModel.sortOption = option
                                    RoutaHapticsManager.shared.selection()
                                }
                            }
                        }
                    }
                    
                    // Clear Recent Searches
                    if hasRecentSearches {
                        VStack(alignment: .leading, spacing: RoutaSpacing.md) {
                            Text("Son Aramalar")
                                .routaTitle3()
                            
                            RoutaButton(
                                "Son Aramaları Temizle",
                                icon: "trash",
                                variant: .ghost,
                                size: .medium
                            ) {
                                viewModel.clearRecentSearches()
                                RoutaHapticsManager.shared.buttonTap()
                            }
                        }
                    }
                }
                .padding(RoutaSpacing.lg)
            }
            .background(Color.routaBackground)
            .navigationTitle("Filtreler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Temizle") {
                        Task {
                            await viewModel.clearFilters()
                        }
                        RoutaHapticsManager.shared.buttonTap()
                    }
                    .foregroundColor(.routaError)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Uygula") {
                        Task {
                            await viewModel.updateFilters()
                        }
                        dismiss()
                        RoutaHapticsManager.shared.buttonTap()
                    }
                    .foregroundColor(.routaPrimary)
                }
            }
        }
    }
}

// MARK: - Search View Model

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Destination] = []
    @Published var popularDestinations: [Destination] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var hasSearched = false
    @Published var selectedCategory = "all"
    @Published var selectedCountry: String? = nil
    @Published var sortOption: SearchSortOption = .relevance
    @Published var recentSearches: [String] = []
    
    private let destinationRepository: DestinationRepository
    private var searchTask: Task<Void, Never>?
    private var debounceTask: Task<Void, Never>?
    private let searchCache = NSCache<NSString, NSArray>()
    private var allDestinations: [Destination] = []
    
    enum SearchSortOption: String, CaseIterable {
        case relevance = "relevance"
        case name = "name"
        case popularity = "popularity"
        case newest = "newest"
        
        var displayName: String {
            switch self {
            case .relevance: return "İlgili"
            case .name: return "İsim"
            case .popularity: return "Popülerlik"
            case .newest: return "En Yeni"
            }
        }
    }
    
    init(destinationRepository: DestinationRepository) {
        self.destinationRepository = destinationRepository
        setupCache()
        loadRecentSearches()
        loadPopularDestinations()
    }
    
    private func setupCache() {
        searchCache.countLimit = 50
        searchCache.totalCostLimit = 10 * 1024 * 1024 // 10MB
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "RecentSearches") ?? []
    }
    
    private func saveRecentSearch(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty, !recentSearches.contains(trimmedQuery) else { return }
        
        recentSearches.insert(trimmedQuery, at: 0)
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
    }
    
    private func loadPopularDestinations() {
        Task { @MainActor in
            do {
                let destinations = try await destinationRepository.fetchAllDestinations()
                allDestinations = destinations
                popularDestinations = Array(destinations.prefix(6))
            } catch {
                print("Error loading popular destinations: \(error)")
            }
        }
    }
    
    deinit {
        searchTask?.cancel()
        debounceTask?.cancel()
    }
    
    func scheduleSearch() {
        debounceTask?.cancel()
        
        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            
            if !Task.isCancelled {
                await searchDestinations()
            }
        }
    }
    
    @MainActor
    func searchDestinations() async {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count >= 2 else {
            if trimmedQuery.isEmpty {
                clearSearch()
            }
            return
        }
        
        let queryKey = trimmedQuery.lowercased()
        
        // Check cache first
        if let cachedResults = searchCache.object(forKey: NSString(string: queryKey)) as? [Destination] {
            searchResults = applyFiltersAndSort(cachedResults)
            hasSearched = true
            return
        }
        
        searchTask?.cancel()
        
        searchTask = Task {
            isLoading = true
            error = nil
            hasSearched = true
            
            do {
                if !Task.isCancelled {
                    // Use local search if we have all destinations loaded
                    let results = performLocalSearch(query: trimmedQuery)
                    
                    if !Task.isCancelled {
                        searchResults = applyFiltersAndSort(results)
                        // Cache the results
                        searchCache.setObject(NSArray(array: results), forKey: NSString(string: queryKey))
                        // Save to recent searches
                        saveRecentSearch(trimmedQuery)
                    }
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error
                    searchResults = []
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
    
    private func performLocalSearch(query: String) -> [Destination] {
        let normalizedQuery = query.turkishNormalized().lowercased()
        
        return allDestinations.filter { destination in
            let name = destination.name.turkishNormalized().lowercased()
            let country = destination.country.turkishNormalized().lowercased()
            let description = destination.description.turkishNormalized().lowercased()
            
            return name.contains(normalizedQuery) ||
                   country.contains(normalizedQuery) ||
                   description.contains(normalizedQuery)
        }
    }
    
    private func applyFiltersAndSort(_ destinations: [Destination]) -> [Destination] {
        var filtered = destinations
        
        // Apply category filter
        if selectedCategory != "all" {
            filtered = filtered.filter { destination in
                switch selectedCategory {
                case "historical":
                    return destination.description.contains("tarihi") || destination.description.contains("historical")
                case "beach":
                    return destination.description.contains("sahil") || destination.description.contains("beach")
                case "nature":
                    return destination.description.contains("doğa") || destination.description.contains("nature")
                default:
                    return true
                }
            }
        }
        
        // Apply country filter
        if let selectedCountry = selectedCountry {
            filtered = filtered.filter { $0.country == selectedCountry }
        }
        
        // Apply sorting
        switch sortOption {
        case .relevance:
            // Already sorted by relevance from search
            break
        case .name:
            filtered.sort { $0.name < $1.name }
        case .popularity:
            filtered.sort { $0.popularMonths.count > $1.popularMonths.count }
        case .newest:
            // Mock sorting by newest (in real app, use creation date)
            filtered.sort { $0.id > $1.id }
        }
        
        // Limit results to prevent UI lag
        return Array(filtered.prefix(50))
    }
    
    @MainActor
    func clearFilters() async {
        selectedCategory = "all"
        selectedCountry = nil
        sortOption = .relevance
        if hasSearched {
            await searchDestinations()
        }
    }
    
    @MainActor
    func updateFilters() async {
        if hasSearched {
            searchResults = applyFiltersAndSort(searchResults)
        }
    }
    
    var availableCountries: [String] {
        Array(Set(allDestinations.map { $0.country })).sorted()
    }
    
    @MainActor
    func clearSearch() {
        searchTask?.cancel()
        debounceTask?.cancel()
        searchResults = []
        error = nil
        hasSearched = false
        isLoading = false
        searchText = ""
    }
    
    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: "RecentSearches")
    }
}

// MARK: - Turkish Character Support Extension
extension String {
    func turkishNormalized() -> String {
        return self
            .replacingOccurrences(of: "ç", with: "c")
            .replacingOccurrences(of: "ğ", with: "g")
            .replacingOccurrences(of: "ı", with: "i")
            .replacingOccurrences(of: "ö", with: "o")
            .replacingOccurrences(of: "ş", with: "s")
            .replacingOccurrences(of: "ü", with: "u")
            .replacingOccurrences(of: "Ç", with: "C")
            .replacingOccurrences(of: "Ğ", with: "G")
            .replacingOccurrences(of: "İ", with: "I")
            .replacingOccurrences(of: "Ö", with: "O")
            .replacingOccurrences(of: "Ş", with: "S")
            .replacingOccurrences(of: "Ü", with: "U")
    }
}

struct MyRoutesViewContainer: View {
    let dependencyContainer: DependencyContainer
    @StateObject private var viewModel: MyRoutesViewModel
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        _viewModel = StateObject(wrappedValue: MyRoutesViewModel(
            routeRepository: dependencyContainer.routeRepository,
            destinationRepository: dependencyContainer.destinationRepository
        ))
    }
    
    var body: some View {
        MyRoutesView(viewModel: viewModel)
    }
}

struct MyRoutesView: View {
    @ObservedObject var viewModel: MyRoutesViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Rotalar yükleniyor...")
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
                .padding(.bottom, LayoutConstants.tabBarHeight)
            } else if let error = viewModel.error {
                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Bir hata oluştu")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.body)
                            .multilineTextAlignment(.center)
                        Button("Tekrar Dene") {
                            Task {
                                await viewModel.fetchSavedRoutes()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                }
                .padding()
                .padding(.bottom, LayoutConstants.tabBarHeight)
            } else if viewModel.savedRoutes.isEmpty {
                emptyStateView
                    .padding(.bottom, LayoutConstants.tabBarHeight)
            } else {
                routesListView
                    .padding(.bottom, LayoutConstants.tabBarHeight)
            }
        }
        .background(Color.routaBackground)
        .navigationTitle("Rotalarım")
        .navigationBarTitleDisplayMode(.large)
        .dynamicIslandBlur()
        .refreshable {
            await viewModel.fetchSavedRoutes()
        }
        .onAppear {
            Task {
                await viewModel.fetchSavedRoutes()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "map")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("Henüz kayıtlı rota yok")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Keşfet sekmesinden rotalar oluşturup kaydettiğinizde burada görünecek")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
    
    private var routesListView: some View {
        List {
            ForEach(viewModel.savedRoutes) { route in
                SavedRouteCard(route: route, destination: viewModel.getDestination(for: route.destinationId)) {
                    Task {
                        await viewModel.deleteRoute(route.id)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

struct SavedRouteCard: View {
    let route: TravelPlan
    let destination: Destination?
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(destination?.name ?? "Bilinmeyen Destinasyon")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(destination?.country ?? "")
                        .font(.subheadline)
                        .foregroundColor(.routaTextSecondary)
                }
                
                Spacer()
                
                Menu {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Sil", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.routaTextSecondary)
                        .padding(8)
                        .background(Color.routaCard)
                        .clipShape(Circle())
                }
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("\(route.duration) gün", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.routaPrimary)
                    
                    Label(route.budgetType.displayName, systemImage: "creditcard")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₺\(Int(route.totalBudget.total))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Toplam Bütçe")
                        .font(.caption2)
                        .foregroundColor(.routaTextSecondary)
                }
            }
            
            HStack {
                Text(route.budgetType.icon)
                    .font(.title2)
                
                Text("Oluşturulma: \(route.createdAt, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.routaTextSecondary)
                
                Spacer()
            }
            
            if !route.dailyItinerary.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Günlük Plan Özeti:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.routaTextSecondary)
                    
                    ForEach(route.dailyItinerary.prefix(3)) { day in
                        HStack {
                            Text("Gün \(day.dayNumber):")
                                .font(.caption2)
                                .fontWeight(.medium)
                            
                            Text("\(day.places.count) mekan, \(day.meals.count) öğün")
                                .font(.caption2)
                                .foregroundColor(.routaTextSecondary)
                            
                            Spacer()
                        }
                    }
                    
                    if route.dailyItinerary.count > 3 {
                        Text("ve \(route.dailyItinerary.count - 3) gün daha...")
                            .font(.caption2)
                            .foregroundColor(.routaTextSecondary)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.routaCard)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .alert("Rotayı Sil", isPresented: $showingDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Bu rotayı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}

class MyRoutesViewModel: ObservableObject {
    @Published var savedRoutes: [TravelPlan] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let routeRepository: RouteRepository
    private let destinationRepository: DestinationRepository
    private var destinations: [Destination] = []
    
    init(routeRepository: RouteRepository, destinationRepository: DestinationRepository) {
        self.routeRepository = routeRepository
        self.destinationRepository = destinationRepository
    }
    
    @MainActor
    func fetchSavedRoutes() async {
        isLoading = true
        error = nil
        
        do {
            savedRoutes = try await routeRepository.fetchSavedRoutes()
            
            if destinations.isEmpty {
                destinations = try await destinationRepository.fetchAllDestinations()
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    @MainActor
    func deleteRoute(_ routeId: String) async {
        do {
            try await routeRepository.deleteRoute(routeId)
            savedRoutes.removeAll { $0.id == routeId }
        } catch {
            self.error = error
        }
    }
    
    func getDestination(for destinationId: String) -> Destination? {
        return destinations.first { $0.id == destinationId }
    }
}

struct ProfileViewContainer: View {
    let dependencyContainer: DependencyContainer
    @StateObject private var viewModel: ProfileViewModel
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        _viewModel = StateObject(wrappedValue: ProfileViewModel(
            destinationRepository: dependencyContainer.destinationRepository,
            routeRepository: dependencyContainer.routeRepository
        ))
    }
    
    var body: some View {
        ProfileView(viewModel: viewModel)
            .environmentObject(dependencyContainer)
    }
}

// ProfileView is now in separate file: Features/Profile/ProfileView.swift

// Supporting views are now in separate file: Features/Profile/ProfileView.swift

// Selection views are now in separate file: Features/Profile/ProfileView.swift

// All ProfileView related code moved to Features/Profile/ProfileView.swift

#Preview {
    ContentView()
        .environmentObject(DependencyContainer())
}
