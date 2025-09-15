import SwiftUI

// Image cache for better performance
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private let maxMemorySize: Int = 100 * 1024 * 1024 // 100MB
    
    private init() {
        cache.totalCostLimit = maxMemorySize
        cache.countLimit = 200
        
        // Clear cache on memory warning
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func clearCache() {
        cache.removeAllObjects()
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        let cost = Int(image.size.width * image.size.height * 4) // Rough memory cost
        cache.setObject(image, forKey: NSString(string: key), cost: cost)
    }
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: NSString(string: key))
    }
}

// Optimized AsyncImage component with caching and quality options
struct CustomAsyncImage: View {
    let url: String?
    let aspectRatio: CGFloat
    let quality: ImageQuality
    
    init(url: String?, aspectRatio: CGFloat = 1.0, quality: ImageQuality = .standard) {
        self.url = url
        self.aspectRatio = aspectRatio
        self.quality = quality
    }
    
    enum ImageQuality {
        case thumbnail
        case standard
        case high
        
        var compressionQuality: CGFloat {
            switch self {
            case .thumbnail: return 0.3
            case .standard: return 0.7
            case .high: return 0.9
            }
        }
        
        var maxSize: CGSize {
            switch self {
            case .thumbnail: return CGSize(width: 150, height: 150)
            case .standard: return CGSize(width: 400, height: 400)
            case .high: return CGSize(width: 800, height: 800)
            }
        }
    }
    
    var body: some View {
        if let urlString = url, let imageURL = URL(string: urlString) {
            CachedAsyncImage(url: imageURL, quality: quality, aspectRatio: aspectRatio)
        } else {
            placeholderView
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
            Image(systemName: "photo")
                .font(.system(size: 30))
                .foregroundColor(.routaTextSecondary)
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

struct CachedAsyncImage: View {
    let url: URL
    let quality: CustomAsyncImage.ImageQuality
    let aspectRatio: CGFloat
    
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var hasError = false
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else if isLoading {
                loadingView
            } else if hasError {
                errorView
            } else {
                loadingView
                    .onAppear {
                        loadImage()
                    }
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }
    
    private var loadingView: some View {
        ZStack {
            Rectangle()
                .fill(Color.routaTextSecondary.opacity(0.2))
            ProgressView()
                .tint(.routaTextSecondary)
        }
    }
    
    private var errorView: some View {
        ZStack {
            Rectangle()
                .fill(Color.routaTextSecondary.opacity(0.1))
            VStack(spacing: 4) {
                Image(systemName: "photo")
                    .font(.system(size: 20))
                    .foregroundColor(.routaTextSecondary)
                Text("Yüklenemedi")
                    .font(.caption2)
                    .foregroundColor(.routaTextSecondary)
            }
        }
    }
    
    private func loadImage() {
        let cacheKey = "\(url.absoluteString)_\(quality.maxSize.width)"
        
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(forKey: cacheKey) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
        
        isLoading = true
        hasError = false
        
        // Load from network on background queue
        Task.detached(priority: .userInitiated) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                guard let uiImage = UIImage(data: data) else {
                    await MainActor.run {
                        hasError = true
                        isLoading = false
                    }
                    return
                }
                
                // Resize and compress image based on quality
                let processedImage = processImage(uiImage)
                
                // Cache the processed image
                ImageCache.shared.setImage(processedImage, forKey: cacheKey)
                
                await MainActor.run {
                    self.image = processedImage
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.hasError = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func processImage(_ image: UIImage) -> UIImage {
        // Process image on background queue to avoid blocking main thread
        return autoreleasepool {
            let maxSize = quality.maxSize
            let compressionQuality = quality.compressionQuality
            
            // Resize if needed
            let size = image.size
            if size.width > maxSize.width || size.height > maxSize.height {
                let scaleFactor = min(maxSize.width / size.width, maxSize.height / size.height)
                let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
                
                let renderer = UIGraphicsImageRenderer(size: newSize)
                let resizedImage = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: newSize))
                }
                
                if let compressedData = resizedImage.jpegData(compressionQuality: compressionQuality),
                   let compressedImage = UIImage(data: compressedData) {
                    return compressedImage
                }
            }
            
            // Just compress if no resize needed
            if let compressedData = image.jpegData(compressionQuality: compressionQuality),
               let compressedImage = UIImage(data: compressedData) {
                return compressedImage
            }
            
            return image
        }
    }
}
