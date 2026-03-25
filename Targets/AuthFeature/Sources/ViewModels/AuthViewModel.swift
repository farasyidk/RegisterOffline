import Foundation
import CoreProtocol
import SwiftUI

@MainActor
public final class AuthViewModel: ObservableObject {
    @Published public var email = ""
    @Published public var password = ""
    @Published public var errorMessage: String? = nil
    @Published public var isLoading = false
    @Published public var isAuthenticated = false
    
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func checkAuthStatus() {
        isAuthenticated = authRepository.isUserLoggedIn()
    }
    
    public func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Silakan masukkan email dan password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authRepository.login(email: email, password: password)
            isAuthenticated = true
        } catch let error as NetworkError {
            errorMessage = error.message
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func logout() {
        authRepository.logout()
        isAuthenticated = false
    }
}
