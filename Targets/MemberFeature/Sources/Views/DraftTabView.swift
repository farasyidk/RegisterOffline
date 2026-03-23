import SwiftUI
import Core
import CoreProtocol
import DesignSystem

struct DraftTabView: View {
    @ObservedObject var viewModel: MemberDashboardViewModel
    @Binding var editingMember: MemberEntity?
    @Binding var isNavigateToEditing: Bool
    @Binding var selectedMemberForUpload: MemberEntity?
    @Binding var showingUploadSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("List Draft KTA")
                    .font(.headline)
                Text("Upload untuk mengirimkan data ini ke admin untuk di-verifikasi.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.top)
            
            HStack(alignment: .top) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color.brandDarkBlue)
                Text("Nomor Handphone, NIK, dan Foto KTP wajib diisi sebelum di-upload")
                    .font(.caption)
                    .foregroundColor(Color.brandDarkBlue)
            }
            .padding()
            .background(Color.brandDarkBlue.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            ForEach(Array(viewModel.draftMembers.enumerated()), id: \.element.id) { index, member in
                DraftMemberCard(
                    index: index + 1,
                    member: member,
                    onEdit: {
                        editingMember = member
                        isNavigateToEditing = true
                    },
                    onUploadTapped: {
                        selectedMemberForUpload = member
                        showingUploadSheet = true
                    }
                )
            }
        }
        .padding(.bottom, 20)
    }
}
