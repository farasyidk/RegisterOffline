import Foundation
import CoreProtocol
import SwiftUI

@MainActor
public final class ProfileViewModel: ObservableObject {
    @Published public var profile: ProfileResponse? = nil
    @Published public var errorMessage: String? = nil
    @Published public var isLoading = false
    
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func fetchProfile() async {
        isLoading = true
        errorMessage = nil
        do {
            profile = try await authRepository.getProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
