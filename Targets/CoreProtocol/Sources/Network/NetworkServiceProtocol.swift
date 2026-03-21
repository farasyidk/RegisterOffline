import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

public struct NetworkError: Error, LocalizedError {
    public let message: String
    public init(_ message: String) { self.message = message }
    public var errorDescription: String? { return message }
}

public protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
    func uploadMultipart<T: Decodable>(
        endpoint: Endpoint,
        boundary: String,
        body: Data
    ) async throws -> T
}

public protocol TokenProviderProtocol {
    func getToken() -> String?
    func saveToken(_ token: String)
    func clearToken()
}
