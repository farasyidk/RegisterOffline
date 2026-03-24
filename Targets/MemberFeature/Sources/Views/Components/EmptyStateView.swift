import SwiftUI
import DesignSystem

@MainActor
public struct EmptyStateView: View {
    private let title: String
    private let message: String
    
    public init(
        title: String = "Belum ada data", 
        message: String = "Klik \"Tambah Data\" untuk menambahkan data calon anggota"
    ) {
        self.title = title
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            DesignSystemAssets.emptyDataIllustration
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 180)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "4A4A4A"))
                
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
    }
}
