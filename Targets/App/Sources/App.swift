import SwiftUI
import SwiftData
import Core
import CoreProtocol
import AuthFeature
import ProfileFeature
import MemberFeature

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
        
        #if DEBUG && targetEnvironment(simulator)
        loadRocketSimConnect()
        #endif
    }
    
    private func loadRocketSimConnect() {
        let bundlePath = "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework"
        if let bundle = Bundle(path: bundlePath) {
            bundle.load()
            print("✅ RocketSim Connect successfully linked")
        } else {
            print("❌ Failed to Connect RocketSim bundle")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView(
                authViewModel: authViewModel,
                authRepository: authRepository,
                networkManager: networkManager
            )
            .modelContainer(for: [MemberEntity.self])
        }
    }
}

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var authViewModel: AuthViewModel
    let authRepository: AuthRepositoryProtocol
    let networkManager: NetworkServiceProtocol
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
                    NavigationStack {
                        MemberDashboardView(
                            viewModel: MemberDashboardViewModel(
                                memberRepository: MemberRepository(
                                    networkService: networkManager,
                                    modelContext: modelContext
                                ),
                                authRepository: authRepository
                            ),
                            profileViewProvider: { 
                                AnyView(ProfileView(authRepository: authRepository, onLogout: {
                                    authViewModel.logout()
                                }))
                            },
                            loginViewProvider: {
                                AnyView(LoginView(viewModel: authViewModel))
                            },
                            registerViewProvider: { member in
                                AnyView(RegisterFormView(viewModel: RegisterViewModel(
                                    memberRepository: MemberRepository(
                                        networkService: networkManager,
                                        modelContext: modelContext
                                    ),
                                    editingMember: member
                                )))
                            },
                            onLogout: {
                                authViewModel.logout()
                            }
                        )
                    }
                }
 else {
                    LoginView(viewModel: authViewModel)
                }
            }
        }
    }
}
