import Foundation
import CoreProtocol

public final class NetworkManager: NetworkServiceProtocol {
    private struct APIErrorResponse: Decodable { let error: String }
    
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
            let errorMsg: String?
            if let errResp = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                errorMsg = errResp.error
            } else {
                errorMsg = nil
            }
            
            if httpResponse.statusCode == 401 || errorMsg == "Invalid Token" {
                throw NetworkError(errorMsg ?? "Silakan login kembali", isUnauthorized: true)
            }
            throw NetworkError(errorMsg ?? "HTTP Error: \(httpResponse.statusCode)")
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
            let errorMsg: String?
            if let errResp = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                errorMsg = errResp.error
            } else {
                errorMsg = nil
            }
            
            if httpResponse.statusCode == 401 || errorMsg == "Invalid Token" {
                throw NetworkError(errorMsg ?? "Silakan login kembali", isUnauthorized: true)
            }
            throw NetworkError(errorMsg ?? "HTTP Error: \(httpResponse.statusCode)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError("Decoding error: \(error.localizedDescription)")
        }
    }
}
