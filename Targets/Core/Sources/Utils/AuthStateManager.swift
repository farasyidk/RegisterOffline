import Foundation
import CoreProtocol
import Combine

@MainActor
public final class AuthStateManager: ObservableObject {
    @Published public var shouldNavigateToLogin = false
    @Published public var unauthorizedMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {}
    
    public func handleUnauthorized(message: String? = nil) {
        unauthorizedMessage = message ?? "Silakan login kembali"
        shouldNavigateToLogin = true
    }
    
    public func resetNavigation() {
        shouldNavigateToLogin = false
        unauthorizedMessage = nil
    }
    
    public func handleError(_ error: Error) -> Bool {
        if let networkError = error as? NetworkError, networkError.isUnauthorized {
            handleUnauthorized(message: networkError.message)
            return true
        }
        return false
    }
}

public final class AuthManager {
    public static let shared = AuthManager()
    
    private var _stateManager: AuthStateManager?
    
    private init() {}
    
    public func setStateManager(_ manager: AuthStateManager) {
        self._stateManager = manager
    }
    
    @MainActor
    public func handleUnauthorized(message: String? = nil) {
        _stateManager?.handleUnauthorized(message: message)
    }
    
    @MainActor
    public func handleError(_ error: Error) -> Bool {
        return _stateManager?.handleError(error) ?? false
    }
}
