import Foundation

public struct LoginResponse: Decodable {
    public let token: String
}

public struct RegisterResponse: Decodable {
    public let message: String
}

public struct ProfileResponse: Codable {
    public let id: String
    public let fullName: String
    public let email: String
    public let address: String?
    public let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case address
        case avatarUrl = "avatar_url"
    }
}

public struct MemberUploadResponseData: Decodable {
    public let id: Int
    public let name: String
    public let nik: String
    public let phone: String?
    public let ktpUrl: String?
    public let ktpUrlSecondary: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, nik, phone
        case ktpUrl = "ktp_url"
        case ktpUrlSecondary = "ktp_url_secondary"
    }
}

public struct MemberUploadResponse: Decodable {
    public let message: String
    public let member: MemberUploadResponseData
}

public struct MemberListResponse: Decodable {
    public let name: String
    public let nik: String
    public let phone: String?
    public let ktpUrl: String?
    public let ktpUrlSecondary: String?
    
    public init(name: String, nik: String, phone: String? = nil, ktpUrl: String? = nil, ktpUrlSecondary: String? = nil) {
        self.name = name
        self.nik = nik
        self.phone = phone
        self.ktpUrl = ktpUrl
        self.ktpUrlSecondary = ktpUrlSecondary
    }
    
    enum CodingKeys: String, CodingKey {
        case name, nik, phone
        case ktpUrl = "ktp_url"
        case ktpUrlSecondary = "ktp_url_secondary"
    }
}
