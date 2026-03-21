import Foundation
import UIKit

public final class LocalImageManager {
    public static let shared = LocalImageManager()
    
    private init() {}
    
    public func saveImage(_ image: UIImage, fileName: String) throws -> String {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "LocalImageManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Documents directory not found"])
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        var compressionQuality: CGFloat = 0.8
        var imageData = image.jpegData(compressionQuality: compressionQuality)
        
        while let data = imageData, data.count > 1_000_000, compressionQuality > 0.1 {
            compressionQuality -= 0.1
            imageData = image.jpegData(compressionQuality: compressionQuality)
        }
        
        guard let finalData = imageData else {
            throw NSError(domain: "LocalImageManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }
        
        try finalData.write(to: fileURL)
        return fileURL.absoluteString
    }
    
    public func loadImage(from urlString: String) -> UIImage? {
        guard let url = URL(string: urlString),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    public func deleteImage(at urlString: String) {
        guard let url = URL(string: urlString) else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
