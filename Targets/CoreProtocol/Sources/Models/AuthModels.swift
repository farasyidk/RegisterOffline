import Foundation

public struct LoginResponse: Decodable {
    public let token: String
}

public struct RegisterResponse: Decodable {
    public let message: String
}

public struct ProfileResponse: Decodable {
    public let id: String
    public let fullName: String
    public let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
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
    
    enum CodingKeys: String, CodingKey {
        case name, nik, phone
        case ktpUrl = "ktp_url"
        case ktpUrlSecondary = "ktp_url_secondary"
    }
}
