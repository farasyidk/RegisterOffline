import SwiftUI
import DesignSystem

public struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var isPasswordVisible = false
    
    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Top subtle gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.15), Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
                .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Header Logo
                    HStack(spacing: 8) {
                        Image(systemName: "person.text.rectangle.fill")
                            .foregroundColor(Color.brandDarkBlue)
                            .font(.system(size: 20))
                        Text("Register Offline")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.brandDarkBlue)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 16)
                    
                    // Title and Subtitle
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Masuk ke Akun Verifikator")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Masukkan email dan password untuk masuk")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Input Forms
                    VStack(alignment: .leading, spacing: 16) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 2) {
                                Text("Email")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text("*")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                            
                            TextField("Masukkan email di sini", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if isPasswordVisible {
                                    TextField("Masukkan password", text: $viewModel.password)
                                        .autocapitalization(.none)
                                } else {
                                    SecureField("Masukkan password", text: $viewModel.password)
                                        .autocapitalization(.none)
                                }
                                
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 4)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.top, 8)
                    
                    if let err = viewModel.errorMessage {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, -8)
                    }
                    
                    // Login Button
                    Button(action: {
                        Task { await viewModel.login() }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Login")
                            }
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.email.isEmpty || viewModel.password.isEmpty ? Color.gray.opacity(0.1) : Color.brandDarkBlue)
                        .foregroundColor(viewModel.email.isEmpty || viewModel.password.isEmpty ? Color.gray : .white)
                        .cornerRadius(8)
                    }
                    .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // Footer Link
                    HStack(spacing: 4) {
                        Spacer()
                        Text("Belum punya akun?")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("Klik Bantuan")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(Color.brandDarkBlue)
                        Spacer()
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarHidden(true)
        }
    }
}
