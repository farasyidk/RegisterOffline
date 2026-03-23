import SwiftUI
import Core
import DesignSystem
import CoreProtocol

struct SyncedTabView: View {
    @ObservedObject var viewModel: MemberDashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Data yang sudah di-upload")
                    .font(.headline)
                Text("Data-data ini sudah dikirimkan ke admin verifikator.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.top)
            
            if viewModel.syncedMembers.isEmpty && !viewModel.isLoading {
                Text("Belum ada data tersinkronisasi.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
            }
            
            ForEach(Array(viewModel.syncedMembers.indices), id: \.self) { index in
                SyncedMemberCard(index: index + 1, member: viewModel.syncedMembers[index])
            }
        }
        .padding(.bottom, 20)
        .onAppear {
            Task { await viewModel.fetchSyncedMembers() }
        }
    }
}
