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
    
    @State private var showingLogoutConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground) // Adaptive background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.primary)
                            .font(.title3)
                    }
                    Text("Profile")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Header Section
                            VStack(spacing: 12) {
                                if let avatarUrl = viewModel.profile?.avatarUrl, let url = URL(string: avatarUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.gray.opacity(0.1)
                                    }
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                } else {
                                    DesignSystemAssets.profile
                                        .resizable()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                }
                                
                                if let profile = viewModel.profile {
                                    Text(profile.fullName)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.brandDarkBlue)
                                    
                                    Text(profile.address ?? "Menteng, Jakarta Pusat, DKI Jakarta")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                    
                                    Text(profile.email)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 20)
                            
                            // Menu Section
                            VStack(spacing: 0) {
                                MenuRow(icon: "ellipsis.rectangle", title: "Ganti Password")
                                Divider().padding(.leading, 50)
                                MenuRow(icon: "questionmark.circle", title: "Bantuan")
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            // Logout Section
                            Button(action: { showingLogoutConfirmation = true }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.red)
                                    Text("Keluar")
                                        .foregroundColor(.red)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                // Footer
                Text("v1.0.1")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.fetchProfile()
        }
        .sheet(isPresented: $showingLogoutConfirmation) {
            LogoutBottomSheet(onConfirm: onLogout)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
    }
}

@available(iOS 16.0, *)
struct LogoutBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        LogoutBottomSheet(onConfirm: {})
    }
}

// Subcomponent for Menu Rows
struct MenuRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.primary)
                    .frame(width: 24)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.5))
                    .font(.caption)
            }
            .padding()
        }
    }
}
