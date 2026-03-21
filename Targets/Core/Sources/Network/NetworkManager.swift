import Foundation
import CoreProtocol

public final class NetworkManager: NetworkServiceProtocol {
    private let tokenProvider: TokenProviderProtocol
    
    public init(tokenProvider: TokenProviderProtocol) {
        self.tokenProvider = tokenProvider
    }
    
    public func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        var request = URLRequest(url: endpoint.baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue
        
        var headers = endpoint.headers ?? [:]
        if let token = tokenProvider.getToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = endpoint.body {
            request.httpBody = body
            if headers["Content-Type"] == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError("Invalid response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError("HTTP Error: \(httpResponse.statusCode)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError("Decoding error: \(error.localizedDescription)")
        }
    }
    
    public func uploadMultipart<T: Decodable>(
        endpoint: Endpoint,
        boundary: String,
        body: Data
    ) async throws -> T {
        var request = URLRequest(url: endpoint.baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue
        
        var headers = endpoint.headers ?? [:]
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        if let token = tokenProvider.getToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError("Invalid response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMsg = String(data: data, encoding: .utf8) {
                print("Multipart error details: \(errorMsg)")
            }
            throw NetworkError("HTTP Error: \(httpResponse.statusCode)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError("Decoding error: \(error.localizedDescription)")
        }
    }
}
