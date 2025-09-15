import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var popularDestinations: [Destination] = []
    @Published var allDestinations: [Destination] = []
    @Published var isLoadingPopular = false
    @Published var isLoadingAll = false
    @Published var popularError: Error?
    @Published var allError: Error?
    
    // MARK: - Dependencies
    private let destinationRepository: DestinationRepository
    
    // MARK: - Task Management
    private var fetchPopularTask: Task<Void, Never>?
    private var fetchAllTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(destinationRepository: DestinationRepository) {
        self.destinationRepository = destinationRepository
    }
    
    deinit {
        fetchPopularTask?.cancel()
        fetchAllTask?.cancel()
    }
    
    // MARK: - Methods
    func fetchPopularDestinations() async {
        // Cancel previous task if exists
        fetchPopularTask?.cancel()
        
        isLoadingPopular = true
        popularError = nil
        
        fetchPopularTask = Task { [weak self] in
            do {
                let destinations = try await self?.destinationRepository.fetchPopularDestinations()
                
                await MainActor.run { [weak self] in
                    if !Task.isCancelled, let self = self, let destinations = destinations {
                        self.popularDestinations = destinations
                    }
                    self?.isLoadingPopular = false
                }
            } catch {
                await MainActor.run { [weak self] in
                    // Ignore cancellation errors
                    if !Task.isCancelled && !(error is CancellationError) {
                        self?.popularError = error
                        print("Error fetching popular destinations: \(error)")
                    }
                    self?.isLoadingPopular = false
                }
            }
        }
    }
    
    func fetchAllDestinations() async {
        // Cancel previous task if exists
        fetchAllTask?.cancel()
        
        isLoadingAll = true
        allError = nil
        
        fetchAllTask = Task { [weak self] in
            do {
                let destinations = try await self?.destinationRepository.fetchAllDestinations()
                
                await MainActor.run { [weak self] in
                    if !Task.isCancelled, let self = self, let destinations = destinations {
                        self.allDestinations = destinations
                    }
                    self?.isLoadingAll = false
                }
            } catch {
                await MainActor.run { [weak self] in
                    // Ignore cancellation errors
                    if !Task.isCancelled && !(error is CancellationError) {
                        self?.allError = error
                        print("Error fetching all destinations: \(error)")
                    }
                    self?.isLoadingAll = false
                }
            }
        }
    }
    
    func refreshData() async {
        // Cancel any existing tasks
        fetchPopularTask?.cancel()
        fetchAllTask?.cancel()
        
        // Create new tasks
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                await self?.fetchPopularDestinations()
            }
            group.addTask { [weak self] in
                await self?.fetchAllDestinations()
            }
        }
    }
}
