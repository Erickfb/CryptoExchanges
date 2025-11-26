import UIKit

final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        cache.countLimit = 100
    }

    @MainActor
    func loadImage(from url: URL, into imageView: UIImageView) {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            imageView.image = cachedImage
            return
        }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    cache.setObject(image, forKey: url as NSURL)
                    imageView.image = image
                }
            } catch {
                print("Failed to load image from \(url): \(error.localizedDescription)")
            }
        }
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
