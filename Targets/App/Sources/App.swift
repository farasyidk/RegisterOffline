import SwiftUI
import SwiftData
import Core
import CoreProtocol
import AuthFeature
import ProfileFeature

@main
struct RegisterOfflineApp: App {
    let networkManager: NetworkServiceProtocol
    let tokenProvider: TokenProviderProtocol
    let authRepository: AuthRepositoryProtocol
    
    @StateObject private var authViewModel: AuthViewModel
    
    init() {
        let provider = KeychainTokenProvider()
        let network = NetworkManager(tokenProvider: provider)
        let authRepo = AuthRepository(networkService: network, tokenProvider: provider)
        
        self.tokenProvider = provider
        self.networkManager = network
        self.authRepository = authRepo
        
        self._authViewModel = StateObject(wrappedValue: AuthViewModel(authRepository: authRepo))
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView(authViewModel: authViewModel, authRepository: authRepository)
                .modelContainer(for: [MemberEntity.self])
        }
    }
}

struct AppRootView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let authRepository: AuthRepositoryProtocol
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            authViewModel.checkAuthStatus()
                            withAnimation { showSplash = false }
                        }
                    }
            } else {
                if authViewModel.isAuthenticated {
                    NavigationView {
                        VStack(spacing: 20) {
                            Text("Dashboard Utama")
                                .font(.largeTitle)
                            
                            NavigationLink("Profil & Logout") {
                                ProfileView(authRepository: authRepository, onLogout: {
                                    authViewModel.logout()
                                })
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                } else {
                    LoginView(viewModel: authViewModel)
                }
            }
        }
    }
}
