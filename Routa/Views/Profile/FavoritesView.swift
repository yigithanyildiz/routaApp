import SwiftUI
import Foundation
struct FavoritesView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dependencyContainer: DependencyContainer
    @State private var favoriteDestinations: [Destination] = []
    @State private var isLoading = true
    @State private var selectedDestination: Destination?
    
    private var favoritesManager: FavoritesManager {
        authManager.favoritesManager
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: RoutaSpacing.md) {
                // Header
                HStack {
                    Text("Favorilerim")
                        .routaTitle2()
                        .foregroundColor(.routaText)
                    Spacer()
                }
                .padding(.horizontal, RoutaSpacing.lg)
                .dynamicIslandPadding()

                if isLoading {
                    loadingView
                        .padding(.horizontal, RoutaSpacing.lg)
                } else if favoriteDestinations.isEmpty {
                    emptyStateView
                } else {
                    favoritesListView
                }
            }
            .padding(.bottom, LayoutConstants.tabBarHeight)
        }
        .background(Color.routaBackground)
        .dynamicIslandBlur()
        .onAppear {
            loadFavorites()
        }
        .onChange(of: favoritesManager.favoriteIds) { _, _ in
            loadFavorites()
        }
        .refreshable {
            await refreshFavorites()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: RoutaSpacing.md) {
            ForEach(0..<3) { _ in
                ShimmerListCard()
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: RoutaSpacing.xl) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(RoutaGradients.secondaryGradient.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "heart.slash")
                    .font(.system(size: 60))
                    .foregroundColor(.routaTextSecondary)
            }
            
            // Text Content
            VStack(spacing: RoutaSpacing.md) {
                Text("Henüz Favori Eklemediniz")
                    .routaTitle2()
                    .foregroundColor(.routaText)
                    .multilineTextAlignment(.center)
                
                Text("Beğendiğiniz destinasyonları favorilere ekleyerek kolayca ulaşabilirsiniz.")
                    .routaBody()
                    .foregroundColor(.routaTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RoutaSpacing.lg)
            }
            
            // Action Button
            RoutaGradientButton(
                "Destinasyonları Keşfet",
                icon: "map.fill",
                gradient: RoutaGradients.primaryGradient,
                size: .large
            ) {
                RoutaHapticsManager.shared.buttonTap()
                // This will dismiss the view and return to home
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController {
                    tabBarController.selectedIndex = 0 // Switch to home tab
                }
            }
            .padding(.horizontal, RoutaSpacing.xl)
            
            Spacer()
        }
        .padding(.horizontal, RoutaSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Favorites List View
    
    private var favoritesListView: some View {
        VStack(spacing: RoutaSpacing.md) {
            ForEach(favoriteDestinations) { destination in
                NavigationLink(destination: ModernDestinationDetailView(destination: destination).environmentObject(dependencyContainer).environmentObject(authManager)) {
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
    
    // MARK: - Helper Methods
    
    private func loadFavorites() {
        isLoading = true
        
        Task {
            await MainActor.run {
                favoriteDestinations = createMockFavoriteDestinations(
                    from: Array(favoritesManager.favoriteIds)
                )
                isLoading = false
            }
        }
    }
    
    private func refreshFavorites() async {
        RoutaHapticsManager.shared.pullToRefresh()
        loadFavorites()
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    private func createMockFavoriteDestinations(from ids: [String]) -> [Destination] {
        return ids.compactMap { id in
            // Try to find matching destination in mock data
            if let destination = MockData.destinations.first(where: { $0.id == id }) {
                return destination
            } else {
                // Create a basic destination for unknown IDs
                return Destination(
                    id: id,
                    name: "Favori Destinasyon",
                    country: "Bilinmeyen",
                    description: "Bu destinasyon henüz detayları yüklenmedi.",
                    imageURL: "https://picsum.photos/400/300",
                    popularMonths: ["Haziran", "Temmuz"],
                    averageTemperature: Destination.Temperature(summer: 25, winter: 15),
                    currency: "USD",
                    language: "İngilizce",
                    coordinates: Destination.Coordinates(latitude: 0, longitude: 0),
                    address: "Bilinmeyen Konum",
                    popularPlaces: [],
                    climate: nil,
                    costOfLiving: nil,
                    topAttractions: nil,
                    travelStyle: nil,
                    bestFor: nil,
                    popularity: nil,
                    rating: nil,
                    createdAt: nil,
                    updatedAt: nil
                )
            }
        }
    }
}

// MARK: - Supporting Components







#Preview {
    NavigationView {
        FavoritesView()
            .previewEnvironment(authenticated: true)
    }
}
