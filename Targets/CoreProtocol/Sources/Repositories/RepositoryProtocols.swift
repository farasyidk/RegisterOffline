import Foundation

public protocol MemberRepositoryProtocol {
    func getAllDraftMembers() async throws -> [MemberEntity]
    func saveDraftMember(_ member: MemberEntity) async throws
    func deleteDraftMember(id: UUID) async throws
    func updateMemberSyncStatus(id: UUID, status: String) async throws
    func uploadMember(_ member: MemberEntity) async throws -> MemberUploadResponse
    func getSyncedMembers() async throws -> [MemberListResponse]
    func getSyncedMembersFromLocal() async throws -> [MemberEntity]
    func syncMembersWithAPI(_ members: [MemberListResponse]) async throws
}

public protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> LoginResponse
    func register(email: String, fullName: String, password: String, phone: String?) async throws -> RegisterResponse
    func logout()
    func isUserLoggedIn() -> Bool
    func getProfile() async throws -> ProfileResponse
    func getCachedProfile() -> ProfileResponse?
}
