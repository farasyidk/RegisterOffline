import SwiftUI
import Core
import CoreProtocol
import DesignSystem

struct UploadBottomSheet: View {
    let member: MemberEntity?
    let isBulk: Bool
    let memberCount: Int
    let onUpload: (MemberEntity?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Text(isBulk ? "Upload Semua Data" : "Upload Data")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                Divider()
                
                VStack(spacing: 20) {
                    // Illustration
                    DesignSystemAssets.uploadIllustration
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 130)
                        .padding(.top, 20)
                    
                    VStack(spacing: 8) {
                        Text(isBulk ? "Apakah kamu yakin ingin upload semua data?" : "Apakah kamu yakin ingin upload data ini?")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text(isBulk ? "Pastikan kamu sudah mengisi semua data yang diperlukan dengan benar, ya!" : "Data akan dikirimkan ke server untuk proses verifikasi.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onUpload(member)
                        }
                    }) {
                        Text(isBulk ? "Ya, Upload Semua (\(memberCount))" : "Ya, Upload Sekarang")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.brandDarkBlue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Batal")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(UIColor.secondarySystemBackground))
                                .foregroundColor(Color.brandDarkBlue)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.brandDarkBlue, lineWidth: 1)
                                )
                        }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
        }
    }
}
