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
                        ComparisonViewContainer(dependencyContainer: dependencyContainer)
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
                    RoutaTabItem(icon: "arrow.left.arrow.right", title: "Karşılaştır", tag: 2),
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

// MARK: - Search View Container
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
            .environmentObject(dependencyContainer)
    }
}

// MARK: - Old MyRoutes code removed - replaced with ComparisonView

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
