import Foundation
import CoreProtocol
import Core
import SwiftUI

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
    
    public init(memberRepository: MemberRepositoryProtocol, authRepository: AuthRepositoryProtocol) {
        self.memberRepository = memberRepository
        self.authRepository = authRepository
    }
    
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
