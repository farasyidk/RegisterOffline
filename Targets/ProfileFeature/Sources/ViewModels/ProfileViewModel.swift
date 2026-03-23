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
        self.profile = authRepository.getCachedProfile()
    }
    
    public func fetchProfile() async {
        if profile == nil {
            isLoading = true
        }
        errorMessage = nil
        do {
            let fetchedProfile = try await authRepository.getProfile()
            profile = fetchedProfile
        } catch {
            if profile == nil {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
}
