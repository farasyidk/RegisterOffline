import SwiftUI
import Core
import CoreProtocol

extension View {
    func sheetView(isShowingUpload: Binding<Bool>, isShowingBulk: Binding<Bool>, selectedMember: MemberEntity?, viewModel: MemberDashboardViewModel) -> some View {
        self
            .sheet(isPresented: isShowingUpload) {
                let sheet = UploadBottomSheet(
                    member: selectedMember,
                    isBulk: false,
                    memberCount: 1,
                    onUpload: { member in
                        Task {
                            if let member = member {
                                await viewModel.uploadSingle(member: member)
                            }
                        }
                    }
                )
                
                if #available(iOS 16.0, *) {
                    sheet
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                } else {
                    sheet
                }
            }
            .sheet(isPresented: isShowingBulk) {
                let sheet = UploadBottomSheet(
                    member: nil as MemberEntity?,
                    isBulk: true,
                    memberCount: viewModel.draftMembers.count,
                    onUpload: { _ in
                        Task {
                            await viewModel.uploadAllDrafts()
                        }
                    }
                )
                
                if #available(iOS 16.0, *) {
                    sheet
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                } else {
                    sheet
                }
            }
    }
    
    func alertView(isPresented: Binding<Bool>, viewModel: MemberDashboardViewModel, onLogout: @escaping () -> Void) -> some View {
        self.alert("Sesi Habis", isPresented: isPresented) {
            Button("OK") {
                onLogout()
                viewModel.isUnauthorized = false
            }
        } message: {
            Text("Silakan login kembali")
        }
    }
}
