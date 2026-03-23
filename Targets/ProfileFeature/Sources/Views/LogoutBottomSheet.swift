import SwiftUI
import DesignSystem

public struct LogoutBottomSheet: View {
    public let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(onConfirm: @escaping () -> Void) {
        self.onConfirm = onConfirm
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                }
                Text("Keluar")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 32) {
                    DesignSystemAssets.uploadIllustration
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 140)
                        .padding(.top, 24)
                    
                    VStack(spacing: 12) {
                        Text("Apakah kamu yakin ingin keluar?")
                            .font(.system(size: 18, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text("Data yang ada di draft-mu mungkin akan hilang. Kami sarankan untuk upload terlebih dahulu.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            dismiss()
                            onConfirm()
                        }) {
                            Text("Ya, keluar")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.brandDarkBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { dismiss() }) {
                            Text("Batal")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
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
}
