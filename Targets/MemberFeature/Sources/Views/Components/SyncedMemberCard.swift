import SwiftUI
import Core
import DesignSystem
import CoreProtocol

struct SyncedMemberCard: View {
    let index: Int
    let member: MemberListResponse
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index)")
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 24, height: 24)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
            
            if let urlStr = member.ktpUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        Rectangle().fill(Color.gray.opacity(0.1))
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 50, height: 35)
                .cornerRadius(4)
                .clipped()
            } else {
                Rectangle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 50, height: 35)
                    .cornerRadius(4)
                    .overlay(Image(systemName: "person.crop.rectangle").foregroundColor(.green).font(.caption))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(StringMasker.maskNIK(member.nik))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(StringMasker.maskPhone(member.phone ?? "-"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("Di-upload")
                .font(.caption2)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.15))
                .foregroundColor(Color.green)
                .cornerRadius(12)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)

        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
