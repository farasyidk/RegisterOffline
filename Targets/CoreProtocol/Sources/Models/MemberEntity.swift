import Foundation
import SwiftData

@Model
public final class MemberEntity {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var nik: String
    public var phone: String?
    public var birthPlace: String?
    public var birthDate: String?
    public var status: String?
    public var occupation: String?
    
    // Alamat KTP
    public var address: String?
    public var province: String?
    public var cityRegency: String?
    public var district: String?
    public var subDistrict: String?
    public var postalCode: String?
    
    // Alamat Domisili
    public var domicileAddress: String?
    public var domicileProvince: String?
    public var domicileCityRegency: String?
    public var domicileDistrict: String?
    public var domicileSubDistrict: String?
    public var domicilePostalCode: String?
    
    // Media (Local file URLs as string)
    public var ktpLocalPath: String?
    public var ktpSecondaryLocalPath: String?
    
    public var syncStatus: String // "Draft" or "Synced"
    
    public init(id: UUID = UUID(), name: String, nik: String, syncStatus: String = "Draft") {
        self.id = id
        self.name = name
        self.nik = nik
        self.syncStatus = syncStatus
    }
}
