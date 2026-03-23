import Foundation
import SwiftData
import CoreProtocol

public final class MemberRepository: MemberRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let modelContext: ModelContext
    
    public init(networkService: NetworkServiceProtocol, modelContext: ModelContext) {
        self.networkService = networkService
        self.modelContext = modelContext
    }
    
    // Local DB Operations
    public func getAllDraftMembers() async throws -> [MemberEntity] {
        let descriptor = FetchDescriptor<MemberEntity>(predicate: #Predicate { $0.syncStatus == "Draft" })
        return try modelContext.fetch(descriptor)
    }
    
    public func saveDraftMember(_ member: MemberEntity) async throws {
        if member.modelContext == nil {
            modelContext.insert(member)
        }
        try modelContext.save()
    }
    
    public func deleteDraftMember(id: UUID) async throws {
        let descriptor = FetchDescriptor<MemberEntity>(predicate: #Predicate { $0.id == id })
        if let member = try modelContext.fetch(descriptor).first {
            modelContext.delete(member)
            try modelContext.save()
        }
    }
    
    public func updateMemberSyncStatus(id: UUID, status: String) async throws {
        let descriptor = FetchDescriptor<MemberEntity>(predicate: #Predicate { $0.id == id })
        if let member = try modelContext.fetch(descriptor).first {
            member.syncStatus = status
            try modelContext.save()
        }
    }
    
    // API Operations
    public func uploadMember(_ member: MemberEntity) async throws -> MemberUploadResponse {
        struct UploadMemberEndpoint: Endpoint {
            var baseURL: URL = AppConfig.baseURL
            var path: String = "/api/v1/member"
            var method: HTTPMethod = .post
            var headers: [String : String]? = nil
            var body: Data? = nil
        }
        
        let boundary = UUID().uuidString
        var bodyData = Data()
        
        func append(_ string: String) {
            if let data = string.data(using: .utf8) {
                bodyData.append(data)
            }
        }
        
        func appendFormField(named name: String, value: String) {
            append("--\(boundary)\r\n")
            append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            append("\(value)\r\n")
        }
        
        appendFormField(named: "name", value: member.name)
        appendFormField(named: "nik", value: member.nik)
        if let phone = member.phone { appendFormField(named: "phone", value: phone) }
        if let gender = member.gender { appendFormField(named: "jenis_kelamin", value: gender) }
        if let bp = member.birthPlace { appendFormField(named: "birth_place", value: bp) }
        if let bd = member.birthDate { appendFormField(named: "birth_date", value: bd) }
        if let st = member.status { appendFormField(named: "status", value: st) }
        if let oc = member.occupation { appendFormField(named: "occupation", value: oc) }
        
        // Alamat KTP
        if let addr = member.address { appendFormField(named: "address", value: addr) }
        if let prob = member.province { appendFormField(named: "provinsi", value: prob) }
        if let city = member.cityRegency { appendFormField(named: "kota_kabupaten", value: city) }
        if let dist = member.district { appendFormField(named: "kecamatan", value: dist) }
        if let sub = member.subDistrict { appendFormField(named: "kelurahan", value: sub) }
        if let pos = member.postalCode { appendFormField(named: "kode_pos", value: pos) }
        
        // Alamat Domisili
        if let daddr = member.domicileAddress { appendFormField(named: "alamat_domisili", value: daddr) }
        if let dprob = member.domicileProvince { appendFormField(named: "provinsi_domisili", value: dprob) }
        if let dcity = member.domicileCityRegency { appendFormField(named: "kota_kabupaten_domisili", value: dcity) }
        if let ddist = member.domicileDistrict { appendFormField(named: "kecamatan_domisili", value: ddist) }
        if let dsub = member.domicileSubDistrict { appendFormField(named: "kelurahan_domisili", value: dsub) }
        if let dpos = member.domicilePostalCode { appendFormField(named: "kode_pos_domisili", value: dpos) }
        
        // Append Images
        if let ktpPath = member.ktpLocalPath {
            let ktpUrl = URL(fileURLWithPath: ktpPath)
            if let imgData = try? Data(contentsOf: ktpUrl) {
                append("--\(boundary)\r\n")
                append("Content-Disposition: form-data; name=\"ktp_file\"; filename=\"ktp_primary.jpg\"\r\n")
                append("Content-Type: image/jpeg\r\n\r\n")
                bodyData.append(imgData)
                append("\r\n")
            }
        }
        
        if let secPath = member.ktpSecondaryLocalPath {
            let secUrl = URL(fileURLWithPath: secPath)
            if let imgData = try? Data(contentsOf: secUrl) {
                append("--\(boundary)\r\n")
                append("Content-Disposition: form-data; name=\"ktp_file_secondary\"; filename=\"ktp_second.jpg\"\r\n")
                append("Content-Type: image/jpeg\r\n\r\n")
                bodyData.append(imgData)
                append("\r\n")
            }
        }
        
        append("--\(boundary)--\r\n")
        
        return try await networkService.uploadMultipart(endpoint: UploadMemberEndpoint(), boundary: boundary, body: bodyData)
    }
    
    public func getSyncedMembers() async throws -> [MemberListResponse] {
        struct GetMembersEndpoint: Endpoint {
            var baseURL: URL = AppConfig.baseURL
            var path: String = "/api/v1/member"
            var method: HTTPMethod = .get
            var headers: [String : String]? = nil
            var body: Data? = nil
        }
        
        return try await networkService.request(endpoint: GetMembersEndpoint())
    }
    
    public func getSyncedMembersFromLocal() async throws -> [MemberEntity] {
        let descriptor = FetchDescriptor<MemberEntity>(predicate: #Predicate { $0.syncStatus == "Synced" })
        return try modelContext.fetch(descriptor)
    }
    
    public func syncMembersWithAPI(_ members: [MemberListResponse]) async throws {
        let descriptor = FetchDescriptor<MemberEntity>(predicate: #Predicate { $0.syncStatus == "Synced" })
        var localSynced = try modelContext.fetch(descriptor)
        
        for apiMember in members {
            let nik = apiMember.nik
            let name = apiMember.name
            
            if let index = localSynced.firstIndex(where: { $0.nik == nik && $0.name == name }) {
                let member = localSynced.remove(at: index)
                member.ktpUrl = apiMember.ktpUrl
                member.ktpUrlSecondary = apiMember.ktpUrlSecondary
                if let phone = apiMember.phone { member.phone = phone }
            } else {
                let newMember = MemberEntity(
                    name: apiMember.name,
                    nik: apiMember.nik,
                    syncStatus: "Synced",
                    ktpUrl: apiMember.ktpUrl,
                    ktpUrlSecondary: apiMember.ktpUrlSecondary
                )
                newMember.phone = apiMember.phone
                modelContext.insert(newMember)
            }
        }
        
        for member in localSynced {
            modelContext.delete(member)
        }
        
        try modelContext.save()
    }
}
