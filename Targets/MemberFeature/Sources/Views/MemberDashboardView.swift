import SwiftUI
import SwiftData
import CoreProtocol
import Core
import DesignSystem

public enum DashboardTab {
    case draft
    case synced
}

public struct MemberDashboardView: View {
    @StateObject private var viewModel: MemberDashboardViewModel
    @State private var selectedTab: DashboardTab = .draft
    @Environment(\.modelContext) private var modelContext
    @State private var showToast = false
    @State private var showUnauthorizedAlert = false
    
    // Navigation routing states
    @State private var isShowingAddData = false
    @State private var editingMember: MemberEntity? = nil
    @State private var isNavigateToEditing = false
    @State private var isShowingProfile = false
    @State private var showingUploadSheet = false
    @State private var showingBulkUploadSheet = false
    @State private var selectedMemberForUpload: MemberEntity? = nil
    
    // Auth route up to App level
    public let profileViewProvider: () -> AnyView
    public let loginViewProvider: () -> AnyView
    public let onLogout: () -> Void
    
    public init(viewModel: MemberDashboardViewModel, 
                profileViewProvider: @escaping () -> AnyView, 
                loginViewProvider: @escaping () -> AnyView, 
                onLogout: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.profileViewProvider = profileViewProvider
        self.loginViewProvider = loginViewProvider
        self.onLogout = onLogout
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                tabBarContainer
                contentArea
                
                if selectedTab == .draft {
                    bottomActionsView
                }
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .horizontal)
            
            loadingOverlay
            toastOverlay
        }
        .sheetView(isShowingUpload: $showingUploadSheet, 
                  isShowingBulk: $showingBulkUploadSheet, 
                  selectedMember: selectedMemberForUpload, 
                  viewModel: viewModel)
        .alertView(isPresented: $showUnauthorizedAlert, 
                  viewModel: viewModel, 
                  onLogout: onLogout)
        .background(navigationLinksView)
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.fetchDraftMembers()
                await viewModel.fetchProfile()
            }
        }
        .onChange(of: viewModel.isUploadSuccess) { _, success in
            if success {
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { showToast = false }
                    viewModel.isUploadSuccess = false
                }
            }
        }
        .onChange(of: viewModel.isUnauthorized) { _, isUnauthorized in
            if isUnauthorized {
                showUnauthorizedAlert = true
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var headerView: some View {
        HStack {
            HStack(spacing: 8) {
                DesignSystemAssets.icon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .foregroundColor(Color.brandDarkBlue)
                Text("Register Offline")
                    .font(.headline)
                    .foregroundColor(Color.brandDarkBlue)
            }
            Spacer()
            
            Button(action: { isShowingProfile = true }) {
                HStack(spacing: 8) {
                    Text(viewModel.userName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    DesignSystemAssets.profile
                        .resizable()
                        .frame(width: 22, height: 22)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
    
    @ViewBuilder
    private var tabBarContainer: some View {
        HStack(spacing: 0) {
            TabButton(title: "Draft", isSelected: selectedTab == .draft) {
                selectedTab = .draft
            }
            TabButton(title: "Sudah Di-Upload", isSelected: selectedTab == .synced) {
                selectedTab = .synced
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        Divider()
    }
    
    @ViewBuilder
    private var contentArea: some View {
        ScrollView {
            switch selectedTab {
            case .draft:
                DraftTabView(
                    viewModel: viewModel,
                    editingMember: $editingMember,
                    isNavigateToEditing: $isNavigateToEditing,
                    selectedMemberForUpload: $selectedMemberForUpload,
                    showingUploadSheet: $showingUploadSheet
                )
            case .synced:
                SyncedTabView(viewModel: viewModel)
            }
        }
    }
    
    @ViewBuilder
    private var bottomActionsView: some View {
        VStack(spacing: 12) {
            Button(action: { isShowingAddData = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Tambah Data")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.brandDarkBlue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            Button(action: { showingBulkUploadSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Upload Semua (\(viewModel.draftMembers.count))")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(Color.brandDarkBlue)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.brandDarkBlue, lineWidth: 1))
            }
            .disabled(viewModel.draftMembers.isEmpty)
        }
        .padding()
        .background(Color.white)
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            ZStack {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView(viewModel.uploadProgressMessage ?? "Processing...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .zIndex(2)
        }
    }
    
    @ViewBuilder
    private var toastOverlay: some View {
        if showToast {
            VStack {
                HStack {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    Text(viewModel.uploadProgressMessage ?? "Sukses")
                        .font(.footnote)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
                .padding(.top, 100)
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(1)
        }
    }
    
    @ViewBuilder
    private var navigationLinksView: some View {
        Color.clear
            .navigationDestination(isPresented: $isShowingAddData) {
                RegisterFormView(viewModel: RegisterViewModel(
                    memberRepository: MemberRepository(
                        networkService: NetworkManager(tokenProvider: KeychainTokenProvider()), 
                        modelContext: modelContext
                    )
                ))
                .onDisappear {
                    Task { await viewModel.fetchDraftMembers() }
                }
            }
            .navigationDestination(item: $editingMember) { member in
                RegisterFormView(viewModel: RegisterViewModel(
                    memberRepository: MemberRepository(
                        networkService: NetworkManager(tokenProvider: KeychainTokenProvider()), 
                        modelContext: modelContext
                    ),
                    editingMember: member
                ))
                .onDisappear {
                    Task { await viewModel.fetchDraftMembers() }
                }
            }
            .navigationDestination(isPresented: $isShowingProfile) {
                profileViewProvider()
            }
    }
}
