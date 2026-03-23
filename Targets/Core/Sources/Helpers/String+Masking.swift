import Foundation

public enum StringMasker {
    public static func maskNIK(_ nik: String) -> String {
        guard nik.count >= 8 else { return nik }
        let start = nik.prefix(4)
        let end = nik.suffix(4)
        return "\(start)********\(end)"
    }

    public static func maskPhone(_ phone: String) -> String {
        guard phone.count >= 8 else { return phone }
        let start = phone.prefix(3)
        let end = phone.suffix(2)
        return "\(start)*******\(end)"
    }
}
