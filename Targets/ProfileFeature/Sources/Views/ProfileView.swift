import SwiftUI
import CoreProtocol
import DesignSystem

public struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    public var onLogout: () -> Void
    
    public init(authRepository: AuthRepositoryProtocol, onLogout: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(authRepository: authRepository))
        self.onLogout = onLogout
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Color.brandDarkBlue)
                .padding(.top, 40)
            
            if viewModel.isLoading {
                ProgressView("Memuat Profil...")
            } else if let profile = viewModel.profile {
                VStack(spacing: 8) {
                    Text(profile.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(profile.email)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            } else if let err = viewModel.errorMessage {
                Text(err)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                onLogout()
            }) {
                Text("Keluar (Logout)")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchProfile()
        }
    }
}
