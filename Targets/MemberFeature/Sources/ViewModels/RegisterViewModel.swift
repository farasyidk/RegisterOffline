import SwiftUI
import Foundation
import CoreProtocol
import Core

@MainActor
public final class RegisterViewModel: ObservableObject {
    private let memberRepository: MemberRepositoryProtocol
    
    // Data Utama
    @Published public var phoneNumber: String = ""
    @Published public var nik: String = ""
    @Published public var ktpPaths: [String] = []
    
    // Opsi Data Statis (Dropdown)
    public let genders = ["Laki-Laki", "Perempuan"]
    public let maritalStatuses = ["Belum Kawin", "Kawin", "Cerai Hidup", "Cerai Mati"]
    public let occupations = ["Pegawai Swasta", "Wiraswasta", "PNS", "Mahasiswa/Pelajar", "Lainnya"]
    public let provinces = ["DKI Jakarta", "Jawa Barat", "Jawa Tengah", "Jawa Timur", "Banten"]
    public let cities = ["Jakarta Selatan", "Surabaya", "Bandung"]
    public let districts = ["Tebet", "Setiabudi", "Pasar Minggu"]
    public let villages = ["Menteng Dalam", "Kuningan Timur"]
    
    // Informasi Lainnya
    @Published public var fullName: String = ""
    @Published public var birthPlace: String = ""
    @Published public var birthDate: Date = Date()
    @Published public var gender: String = ""
    @Published public var status: String = ""
    @Published public var occupation: String = ""
    
    // Informasi Alamat KTP
    @Published public var ktpAddress: String = ""
    @Published public var ktpProvince: String = ""
    @Published public var ktpCity: String = ""
    @Published public var ktpDistrict: String = ""
    @Published public var ktpVillage: String = ""
    @Published public var ktpPostalCode: String = ""
    
    // Alamat Domisili
    @Published public var isDomicileSameAsKtp: Bool = false {
        didSet {
            if isDomicileSameAsKtp {
                domicileAddress = ktpAddress
                domicileProvince = ktpProvince
                domicileCity = ktpCity
                domicileDistrict = ktpDistrict
                domicileVillage = ktpVillage
                domicilePostalCode = ktpPostalCode
            }
        }
    }
    @Published public var domicileAddress: String = ""
    @Published public var domicileProvince: String = ""
    @Published public var domicileCity: String = ""
    @Published public var domicileDistrict: String = ""
    @Published public var domicileVillage: String = ""
    @Published public var domicilePostalCode: String = ""
    
    // View States
    @Published public var isSaving: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var isSavedSuccessfully: Bool = false
    @Published public var isUploadSuccessfully: Bool = false
    
    public init(memberRepository: MemberRepositoryProtocol) {
        self.memberRepository = memberRepository
    }
    
    public var isFormValid: Bool {
        !phoneNumber.isEmpty && !nik.isEmpty && ktpPaths.count >= 1
    }
    
    private var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: birthDate)
    }
    
    public func saveDraft() async {
        guard isFormValid else { return }
        isSaving = true
        errorMessage = nil
        
        let entity = MemberEntity(name: fullName, nik: nik, syncStatus: "Draft")
        entity.phone = phoneNumber
        entity.birthPlace = birthPlace
        entity.birthDate = formattedBirthDate
        entity.gender = gender.isEmpty ? nil : gender
        entity.status = status.isEmpty ? nil : status
        entity.occupation = occupation.isEmpty ? nil : occupation
        
        entity.address = ktpAddress
        entity.province = ktpProvince
        entity.cityRegency = ktpCity
        entity.district = ktpDistrict
        entity.subDistrict = ktpVillage
        entity.postalCode = ktpPostalCode
        
        entity.domicileAddress = domicileAddress
        entity.domicileProvince = domicileProvince
        entity.domicileCityRegency = domicileCity
        entity.domicileDistrict = domicileDistrict
        entity.domicileSubDistrict = domicileVillage
        entity.domicilePostalCode = domicilePostalCode
        
        if ktpPaths.count > 0 {
            entity.ktpLocalPath = ktpPaths[0]
        }
        if ktpPaths.count > 1 {
            entity.ktpSecondaryLocalPath = ktpPaths[1]
        }
        
        do {
            try await memberRepository.saveDraftMember(entity)
            isSavedSuccessfully = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSaving = false
    }
    
    public func addKtpPhotoPath(_ path: String) {
        if ktpPaths.count < 2 {
            ktpPaths.append(path)
        }
    }
    
    public func uploadToServer() async {
        guard isFormValid else { return }
        isSaving = true
        errorMessage = nil
        
        let entity = MemberEntity(name: fullName, nik: nik, syncStatus: "Synced")
        entity.phone = phoneNumber
        entity.birthPlace = birthPlace
        entity.birthDate = formattedBirthDate
        entity.gender = gender.isEmpty ? nil : gender
        entity.status = status.isEmpty ? nil : status
        entity.occupation = occupation.isEmpty ? nil : occupation
        
        entity.address = ktpAddress
        entity.province = ktpProvince
        entity.cityRegency = ktpCity
        entity.district = ktpDistrict
        entity.subDistrict = ktpVillage
        entity.postalCode = ktpPostalCode
        
        entity.domicileAddress = domicileAddress
        entity.domicileProvince = domicileProvince
        entity.domicileCityRegency = domicileCity
        entity.domicileDistrict = domicileDistrict
        entity.domicileSubDistrict = domicileVillage
        entity.domicilePostalCode = domicilePostalCode
        
        if ktpPaths.count > 0 {
            entity.ktpLocalPath = ktpPaths[0]
        }
        if ktpPaths.count > 1 {
            entity.ktpSecondaryLocalPath = ktpPaths[1]
        }
        
        do {
            _ = try await memberRepository.uploadMember(entity)
            isUploadSuccessfully = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSaving = false
    }
}
