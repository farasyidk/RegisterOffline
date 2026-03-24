import SwiftUI
import Core
import CoreProtocol
import DesignSystem

struct DraftMemberCard: View {
    let index: Int
    let member: MemberEntity
    let onEdit: () -> Void
    let onUploadTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Text("\(index)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 24, height: 24)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
                
                // Photo placeholder
                if let path = member.ktpLocalPath, let img = LocalImageManager.shared.loadImage(from: path) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 35)
                        .cornerRadius(4)
                } else {
                    Rectangle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 50, height: 35)
                        .cornerRadius(4)
                        .overlay(Image(systemName: "person.crop.rectangle").foregroundColor(.orange).font(.caption))
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
                
                Text(member.syncStatus)
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
                    .foregroundColor(Color.orange)
                    .cornerRadius(12)
            }
            .padding()
            
            Divider()
            
            HStack(spacing: 0) {
                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.footnote)
                    .foregroundColor(Color.brandDarkBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                
                Divider()
                
                Button(action: onUploadTapped) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Upload")
                    }
                    .font(.footnote)
                    .foregroundColor(Color.brandDarkBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)

        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
