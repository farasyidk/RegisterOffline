import SwiftUI

public struct DesignSystemAssets {
    public static var icon: Image {
        #if canImport(UIKit)
        if let uiImage = UIImage(named: "icon", in: Bundle(for: DesignSystemMarker.self), compatibleWith: nil) {
            return Image(uiImage: uiImage)
        }
        #endif
        return Image("icon")
    }
    
    public static var profile: Image {
        #if canImport(UIKit)
        if let uiImage = UIImage(named: "profile", in: bundle, compatibleWith: nil) {
            return Image(uiImage: uiImage)
        }
        #endif
        return Image("profile")
    }
    
    public static var uploadIllustration: Image {
        #if canImport(UIKit)
        if let uiImage = UIImage(named: "upload_illustration", in: bundle, compatibleWith: nil) {
            return Image(uiImage: uiImage)
        }
        #endif
        return Image("upload_illustration")
    }
    
    public static var bundle: Bundle {
        Bundle(for: DesignSystemMarker.self)
    }
}

// Marker for bundle identification
public final class DesignSystemMarker {}

public extension Bundle {
    static var designSystem: Bundle {
        Bundle(for: DesignSystemMarker.self)
    }
}
