import SwiftUI
import Foundation

// MARK: - Image Cache Manager
@MainActor
class ImageCacheManager: ObservableObject {
    static let shared = ImageCacheManager()

    private let cache = NSCache<NSString, UIImage>()
    @Published var preloadingProgress: Double = 0.0
    @Published var isPreloadingComplete = false

    private init() {
        // Configure cache
        cache.countLimit = 20
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    // MARK: - Preload Images
    func preloadOnboardingImages() async {
        let imageURLs = OnboardingPage.samplePages.map { $0.imageURL }
        let totalImages = imageURLs.count

        await withTaskGroup(of: Void.self) { group in
            for (index, urlString) in imageURLs.enumerated() {
                group.addTask { [weak self] in
                    await self?.loadAndCacheImage(from: urlString)

                    await MainActor.run { [weak self] in
                        self?.preloadingProgress = Double(index + 1) / Double(totalImages)
                    }
                }
            }
        }

        // Small delay to show completion
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        isPreloadingComplete = true
    }

    // MARK: - Load and Cache Image
    private func loadAndCacheImage(from urlString: String) async {
        guard let url = URL(string: urlString),
              getCachedImage(for: urlString) == nil else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                cache.setObject(image, forKey: urlString as NSString)
            }
        } catch {
            print("Failed to load image from \(urlString): \(error)")
        }
    }

    // MARK: - Get Cached Image
    func getCachedImage(for urlString: String) -> UIImage? {
        return cache.object(forKey: urlString as NSString)
    }

    // MARK: - Clear Cache
    func clearCache() {
        cache.removeAllObjects()
        preloadingProgress = 0.0
        isPreloadingComplete = false
    }
}

// MARK: - Onboarding Cached AsyncImage View
struct OnboardingCachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @StateObject private var cacheManager = ImageCacheManager.shared

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let url = url,
               let cachedImage = cacheManager.getCachedImage(for: url.absoluteString) {
                content(Image(uiImage: cachedImage))
            } else {
                AsyncImage(url: url) { image in
                    content(image)
                } placeholder: {
                    placeholder()
                }
            }
        }
    }
}