import Foundation

public struct AppConfig {
    public static var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["BASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("BASE_URL not set in Info.plist")
        }
        return url
    }
}
