// Font weight enum'u için import
import SwiftUI
import Foundation
struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var dependencyContainer: DependencyContainer
    @Binding var selectedTab: Int
    @State private var selectedCategory = "all"
    @State private var isRefreshing = false
    
    // Font weight için type alias
    private typealias FontWeight = Font.RoutaWeight
    
    private let categories = [
        ("all", "Tümü", "globe"),
        ("historical", "Tarihi", "building.columns"),
        ("beach", "Sahil", "beach.umbrella"),
        ("nature", "Doğa", "leaf")
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: RoutaSpacing.xl, pinnedViews: []) {
                headerSection
                searchBarSection
                categorySection
                popularDestinationsSection
                allDestinationsSection
            }
            .padding(.bottom, LayoutConstants.tabBarHeight)
        }
        .background(Color.routaBackground)
        .toolbar(.hidden, for: .navigationBar)
        .dynamicIslandBlur()
        .refreshable {
            await refreshData()
        }
        .task {
            if viewModel.popularDestinations.isEmpty && viewModel.allDestinations.isEmpty {
                await viewModel.refreshData()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Merhaba Gezgin! 👋")
                        .routaHeadline()
                        .foregroundColor(.routaText)

                    Text("Bugün nereyi keşfetmek istersin?")
                        .routaBody()
                        .foregroundColor(.routaTextSecondary)
                }

                Spacer()

       


            }
        }
        .padding(.horizontal, RoutaSpacing.lg)
        .dynamicIslandPadding()
    }
    
    // MARK: - Search Bar Section
    private var searchBarSection: some View {
        Button {
            selectedTab = 1 // Switch to Search tab
            RoutaHapticsManager.shared.selection()
        } label: {
            HStack(spacing: RoutaSpacing.md) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundColor(.routaTextSecondary)
                
                Text("Destinasyon ara...")
                    .routaBody()
                    .foregroundColor(.routaTextSecondary)
                
                Spacer()
            }
            .padding(RoutaSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.routaSurface)
            )
            .routaShadow(.subtle)
        }
        .padding(.horizontal, RoutaSpacing.lg)
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Category Section
    private var categorySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: RoutaSpacing.md) {
                ForEach(categories, id: \.0) { category in
                    CategoryPill(
                        title: category.1,
                        icon: category.2,
                        isSelected: selectedCategory == category.0
                    ) {
                        selectedCategory = category.0
                        RoutaHapticsManager.shared.selection()
                    }
                    .id(category.0)
                }
            }
            .padding(.horizontal, RoutaSpacing.lg)
        }
    }
    
    // MARK: - Popular Destinations Section
    private var popularDestinationsSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.md) {
            SectionHeader(
                title: "Popüler Destinasyonlar",
                actionTitle: "Tümünü Gör"
            ) {
                // Tümünü gör action
            }
            .padding(.horizontal, RoutaSpacing.lg)
            
            if viewModel.isLoadingPopular {
                ShimmerLoadingView()
                    .padding(.horizontal, RoutaSpacing.lg)
            } else if viewModel.popularDestinations.isEmpty {
                EmptyStateCard(
                    icon: "map",
                    title: "Henüz destinasyon yok",
                    description: "Popüler destinasyonlar yükleniyor..."
                )
                .padding(.horizontal, RoutaSpacing.lg)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: RoutaSpacing.md) {
                        ForEach(viewModel.popularDestinations) { destination in
                            NavigationLink(destination: ModernDestinationDetailView(destination: destination).environmentObject(dependencyContainer)) {
                                ModernDestinationCard(destination: destination)
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
    }
    
    // MARK: - All Destinations Section
    private var allDestinationsSection: some View {
        VStack(alignment: .leading, spacing: RoutaSpacing.md) {
            SectionHeader(title: "Tüm Destinasyonlar")
                .padding(.horizontal, RoutaSpacing.lg)
            
            if viewModel.isLoadingAll {
                VStack(spacing: RoutaSpacing.md) {
                    ForEach(0..<3) { _ in
                        ShimmerListCard()
                    }
                }
                .padding(.horizontal, RoutaSpacing.lg)
            } else {
                LazyVStack(spacing: RoutaSpacing.md) {
                    ForEach(viewModel.allDestinations) { destination in
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
    
    // MARK: - Helper Methods
    private func refreshData() async {
        RoutaHapticsManager.shared.pullToRefresh()
        isRefreshing = true
        await viewModel.refreshData()
        isRefreshing = false
    }
}

// MARK: - Supporting Components

struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: RoutaSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(.routaCaption1())
            }
            .foregroundColor(isSelected ? .white : .routaText)
            .padding(.horizontal, RoutaSpacing.md)
            .padding(.vertical, RoutaSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? AnyShapeStyle(RoutaGradients.primaryGradient) : AnyShapeStyle(Color.routaSurface))
            )
            .routaShadow(isSelected ? .low : .subtle)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .routaTitle3()
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.routaCaption1())
                        .foregroundColor(.routaPrimary)
                }
            }
        }
    }
}

struct ModernDestinationCard: View {
    let destination: Destination
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .bottomLeading) {
                CustomAsyncImage(url: destination.imageURL, aspectRatio: 16/10, quality: .standard)
                    .frame(width: 280, height: 180)
                    .clipped()
                
                // Gradient overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Content
                VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                    Text(destination.name)
                        .font(.routaTitle3(.bold))
                        .foregroundStyle(.white)
                    
                    HStack(spacing: RoutaSpacing.sm) {
                        Label(destination.country, systemImage: "mappin.circle.fill")
                            .font(.routaCaption1())
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        // Weather badges
                        HStack(spacing: RoutaSpacing.xs) {
                            WeatherBadge(
                                icon: "sun.max.fill",
                                temp: destination.averageTemperature.summer,
                                color: .orange
                            )
                            WeatherBadge(
                                icon: "snowflake",
                                temp: destination.averageTemperature.winter,
                                color: .blue
                            )
                        }
                    }
                }
                .padding(RoutaSpacing.md)
            }
            .frame(width: 280, height: 180)
            .cornerRadius(20)
            
  
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.routaCard)
        )
        .routaShadow(isPressed ? .low : .medium, style: .colored(.routaPrimary))
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
    }
}

struct ModernDestinationListCard: View {
    let destination: Destination
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: RoutaSpacing.md) {
            // Image
            CustomAsyncImage(url: destination.imageURL, aspectRatio: 1.0, quality: .thumbnail)
                .frame(width: 100, height: 100)
                .cornerRadius(16)
            
            // Content
            VStack(alignment: .leading, spacing: RoutaSpacing.xs) {
                Text(destination.name)
                    .routaHeadline()
                
                Label(destination.country, systemImage: "mappin")
                    .font(.routaCallout())
                    .foregroundColor(.routaTextSecondary)
                
                // Tags
                HStack(spacing: RoutaSpacing.xs) {
                    Tag(text: destination.currency, icon: "dollarsign.circle", color: .green)
                    Tag(text: destination.language, icon: "bubble.left", color: .blue)
                }
                
                // Popular months
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.routaTextSecondary)
                    
                    Text(destination.popularMonths.prefix(2).joined(separator: ", "))
                        .routaCaption1()
                        .foregroundColor(.routaTextSecondary)
                }
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.routaTextSecondary)
        }
        .padding(RoutaSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.routaCard)
        )
        .routaShadow(isPressed ? .subtle : .low)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
    }
}

struct WeatherBadge: View {
    let icon: String
    let temp: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text("\(temp)°")
                .font(.routaCaption1())
                .foregroundColor(.white)
        }
        .padding(.horizontal, RoutaSpacing.xs)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.3))
        )
    }
}

struct Tag: View {
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.routaCaption2())
        }
        .foregroundColor(color)
        .padding(.horizontal, RoutaSpacing.xs)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Loading States
struct ShimmerLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: RoutaSpacing.md) {
            ForEach(0..<2) { _ in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.routaSurface)
                    .frame(width: 280, height: 220)
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.routaSurface,
                                Color.white.opacity(0.3),
                                Color.routaSurface
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .rotationEffect(.degrees(70))
                        .offset(x: isAnimating ? 300 : -300)
                    )
                    .mask(RoundedRectangle(cornerRadius: 20))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

struct ShimmerListCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: RoutaSpacing.md) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.routaSurface)
                .frame(width: 100, height: 100)
            
            VStack(alignment: .leading, spacing: RoutaSpacing.sm) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.routaSurface)
                    .frame(width: 150, height: 20)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.routaSurface)
                    .frame(width: 100, height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.routaSurface)
                    .frame(width: 120, height: 14)
            }
            
            Spacer()
        }
        .padding(RoutaSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.routaCard)
        )
        .overlay(
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.white.opacity(0.3),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .rotationEffect(.degrees(70))
            .offset(x: isAnimating ? 300 : -300)
        )
        .mask(
            RoundedRectangle(cornerRadius: 16)
        )
        .routaShadow(.subtle)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

struct EmptyStateCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: RoutaSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.routaTextSecondary)
            
            Text(title)
                .routaHeadline()
                .foregroundColor(.routaText)
            
            Text(description)
                .routaBody()
                .foregroundColor(.routaTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(RoutaSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.routaSurface)
        )
        .routaShadow(.subtle)
    }
}

// MARK: - Spacing Constants


#Preview {
    NavigationStack {
        HomeView(viewModel: HomeViewModel(destinationRepository: MockDestinationRepository()), selectedTab: .constant(0))
            .environmentObject(DependencyContainer())
    }
}
