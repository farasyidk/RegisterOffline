import Foundation
import UIKit

public final class LocalImageManager {
    public static let shared = LocalImageManager()
    
    private init() {}
    
    // Fungsi bantuan untuk mendapatkan URL dinamis berdasarkan filename
    public func getFileURL(for path: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        // Ambil elemen terakhir jika string merupakan URI lengkap, atau gunakan string tersebut jika ia murni filename
        let fileName: String
        if path.starts(with: "file://") || path.contains("/") {
            fileName = URL(fileURLWithPath: path).lastPathComponent
        } else {
            fileName = path
        }
        
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    public func saveImage(_ image: UIImage, fileName: String) throws -> String {
        guard let fileURL = getFileURL(for: fileName) else {
            throw NSError(domain: "LocalImageManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Documents directory not found"])
        }
        
        var compressionQuality: CGFloat = 0.8
        var imageData = image.jpegData(compressionQuality: compressionQuality)
        
        while let data = imageData, data.count > 2_000_000, compressionQuality > 0.1 {
            compressionQuality -= 0.1
            imageData = image.jpegData(compressionQuality: compressionQuality)
        }
        
        guard let finalData = imageData else {
            throw NSError(domain: "LocalImageManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }
        
        try finalData.write(to: fileURL)
        return fileName // Return purely the filename, let getFileURL construct absolute dynamically
    }
    
    public func loadImage(from path: String) -> UIImage? {
        guard let url = getFileURL(for: path),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    public func deleteImage(at path: String) {
        guard let url = getFileURL(for: path) else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
