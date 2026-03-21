import Foundation
import CoreProtocol

public final class AuthRepository: AuthRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let tokenProvider: TokenProviderProtocol
    
    public init(networkService: NetworkServiceProtocol, tokenProvider: TokenProviderProtocol) {
        self.networkService = networkService
        self.tokenProvider = tokenProvider
    }
    
    public func login(email: String, password: String) async throws -> LoginResponse {
        struct LoginEndpoint: Endpoint {
            var baseURL: URL = AppConfig.baseURL
            var path: String = "/api/v1/login"
            var method: HTTPMethod = .post
            var headers: [String : String]? = nil
            var body: Data?
        }
        
        let reqBody = ["email": email, "password": password]
        let bodyData = try? JSONSerialization.data(withJSONObject: reqBody)
        
        let endpoint = LoginEndpoint(body: bodyData)
        let response: LoginResponse = try await networkService.request(endpoint: endpoint)
        
        tokenProvider.saveToken(response.token)
        return response
    }
    
    public func register(email: String, fullName: String, password: String, phone: String?) async throws -> RegisterResponse {
        struct RegisterEndpoint: Endpoint {
            var baseURL: URL = AppConfig.baseURL
            var path: String = "/api/v1/register"
            var method: HTTPMethod = .post
            var headers: [String : String]? = nil
            var body: Data?
        }
        
        var reqBody = [
            "email": email,
            "full_name": fullName,
            "password": password
        ]
        if let phone = phone {
            reqBody["phone"] = phone
        }
        let bodyData = try? JSONSerialization.data(withJSONObject: reqBody)
        
        let endpoint = RegisterEndpoint(body: bodyData)
        return try await networkService.request(endpoint: endpoint)
    }
    
    public func logout() {
        tokenProvider.clearToken()
    }
    
    public func isUserLoggedIn() -> Bool {
        return tokenProvider.getToken() != nil
    }
    
    public func getProfile() async throws -> ProfileResponse {
        struct ProfileEndpoint: Endpoint {
            var baseURL: URL = AppConfig.baseURL
            var path: String = "/api/v1/profile"
            var method: HTTPMethod = .get
            var headers: [String : String]? = nil
            var body: Data? = nil
        }
        
        return try await networkService.request(endpoint: ProfileEndpoint())
    }
}
