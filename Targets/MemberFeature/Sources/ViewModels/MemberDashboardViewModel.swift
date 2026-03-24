import Foundation
import CoreProtocol
import Core
import SwiftUI
import Network

@MainActor
public final class MemberDashboardViewModel: ObservableObject {
    private let memberRepository: MemberRepositoryProtocol
    private let authRepository: AuthRepositoryProtocol
    
    @Published public var draftMembers: [MemberEntity] = []
    @Published public var syncedMembers: [MemberListResponse] = []
    
    @Published public var userName: String = "User Profile"
    @Published public var isLoading: Bool = false
    @Published public var uploadProgressMessage: String? = nil
    @Published public var errorMessage: String? = nil
    @Published public var isUploadSuccess: Bool = false
    @Published public var isUnauthorized: Bool = false
    @Published public var isOnline: Bool = true
    
    private var monitor: NWPathMonitor?
    private var wasOffline = false
    private var isBackgroundSyncing = false
    
    public init(memberRepository: MemberRepositoryProtocol, authRepository: AuthRepositoryProtocol) {
        self.memberRepository = memberRepository
        self.authRepository = authRepository
    }
    
    // MARK: - Network Monitoring
    
    public func startNetworkMonitoring() {
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let online = path.status == .satisfied
            
            Task { @MainActor in
                self.isOnline = online
                if online && self.wasOffline {
                    // Back online! Trigger silent auto-sync
                    await self.autoSyncDrafts()
                }
                self.wasOffline = !online
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor?.start(queue: queue)
    }
    
    public func stopNetworkMonitoring() {
        monitor?.cancel()
        monitor = nil
    }
    
    private func autoSyncDrafts() async {
        guard !isLoading && !isBackgroundSyncing && !draftMembers.isEmpty else { return }
        isBackgroundSyncing = true
        
        // No loading overlay for background sync, just background task
        for member in draftMembers {
            do {
                _ = try await memberRepository.uploadMember(member)
                try await memberRepository.updateMemberSyncStatus(id: member.id, status: "Synced")
            } catch {
                print("Background sync failed for \(member.name): \(error.localizedDescription)")
                if let networkError = error as? NetworkError, networkError.isUnauthorized {
                    isUnauthorized = true
                    break
                }
            }
        }
        
        await fetchDraftMembers()
        isBackgroundSyncing = false
    }
    
    // MARK: - API Operations
    
    public func fetchProfile() async {
        do {
            let profile = try await authRepository.getProfile()
            self.userName = profile.fullName
        } catch {
            print("Failed to fetch profile: \(error)")
        }
    }
    
    public func fetchDraftMembers() async {
        do {
            draftMembers = try await memberRepository.getAllDraftMembers()
        } catch {
            if let networkError = error as? NetworkError, networkError.isUnauthorized {
                isUnauthorized = true
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    public func fetchSyncedMembers() async {
        // 1. Load from local first for immediate UI update (offline support)
        do {
            let localSynced = try await memberRepository.getSyncedMembersFromLocal()
            self.syncedMembers = localSynced.map { entity in
                MemberListResponse(
                    name: entity.name,
                    nik: entity.nik,
                    phone: entity.phone,
                    ktpUrl: entity.ktpUrl,
                    ktpUrlSecondary: entity.ktpUrlSecondary
                )
            }
        } catch {
            print("Failed to load local synced members: \(error)")
        }
        
        // 2. Refresh from API in background (no isLoading = true to avoid blocking UI)
        guard isOnline else { return }
        
        do {
            let apiMembers = try await memberRepository.getSyncedMembers()
            // 3. Background sync with local storage
            try await memberRepository.syncMembersWithAPI(apiMembers)
            
            // 4. Final refresh to ensure UI matches local storage state
            let updatedLocal = try await memberRepository.getSyncedMembersFromLocal()
            self.syncedMembers = updatedLocal.map { entity in
                MemberListResponse(
                    name: entity.name,
                    nik: entity.nik,
                    phone: entity.phone,
                    ktpUrl: entity.ktpUrl,
                    ktpUrlSecondary: entity.ktpUrlSecondary
                )
            }
        } catch {
            if let networkError = error as? NetworkError, networkError.isUnauthorized {
                isUnauthorized = true
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    public func uploadSingle(member: MemberEntity) async {
        guard isOnline else {
            errorMessage = "Tidak ada koneksi internet. Data tetap tersimpan sebagai draft."
            return
        }
        
        isLoading = true
        uploadProgressMessage = "Mengunggah \(member.name)..."
        do {
            _ = try await memberRepository.uploadMember(member)
            try await memberRepository.updateMemberSyncStatus(id: member.id, status: "Synced")
            await fetchDraftMembers()
            uploadProgressMessage = "Data berhasil di-upload"
            isUploadSuccess = true
        } catch {
            if let networkError = error as? NetworkError, networkError.isUnauthorized {
                isUnauthorized = true
            } else {
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
    
    public func uploadAllDrafts() async {
        guard isOnline else {
            errorMessage = "Tidak ada koneksi internet. Draft akan di-upload otomatis saat online."
            return
        }
        
        guard !draftMembers.isEmpty else { return }
        isLoading = true
        var successCount = 0
        
        for (index, member) in draftMembers.enumerated() {
            uploadProgressMessage = "Mengunggah \(index + 1) dari \(draftMembers.count)..."
            do {
                _ = try await memberRepository.uploadMember(member)
                try await memberRepository.updateMemberSyncStatus(id: member.id, status: "Synced")
                successCount += 1
            } catch {
                if let networkError = error as? NetworkError, networkError.isUnauthorized {
                    isUnauthorized = true
                    await fetchDraftMembers()
                    isLoading = false
                    return
                }
                print("Failed to sync \(member.name): \(error)")
            }
        }
        
        await fetchDraftMembers()
        isLoading = false
        if successCount > 0 {
            uploadProgressMessage = "Semua beres! \(successCount) data berhasil di-upload."
            isUploadSuccess = true
        } else {
            errorMessage = "Gagal mengunggah data. Periksa koneksi Anda."
        }
    }
}
