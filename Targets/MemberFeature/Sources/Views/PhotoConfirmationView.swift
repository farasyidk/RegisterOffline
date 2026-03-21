import SwiftUI
import DesignSystem

public struct PhotoConfirmationView: View {
    public let image: UIImage
    public let onConfirm: () -> Void
    public let onRetake: () -> Void
    
    @StateObject private var viewModel = PhotoConfirmationViewModel()
    
    public init(image: UIImage, onConfirm: @escaping () -> Void, onRetake: @escaping () -> Void) {
        self.image = image
        self.onConfirm = onConfirm
        self.onRetake = onRetake
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button(action: onRetake) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Text("Tinjau Gambar")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Pastikan foto KTP jelas dan mudah dibaca")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Image Preview (simulating KTP layout ratio)
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 24)
            
            // Quality Alert
            HStack {
                if let isGood = viewModel.isGoodQuality {
                    Image(systemName: isGood ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(isGood ? .green : .orange)
                    Text(isGood ? "Kualitas foto ini sudah baik" : "Kualitas foto ini kurang blur/tidak terbaca. Kami sarankan foto ulang")
                        .font(.footnote)
                        .foregroundColor(Color(UIColor.darkText))
                        .multilineTextAlignment(.leading)
                } else {
                    ProgressView()
                        .padding(.trailing, 8)
                    Text("Menganalisa kualitas teks foto...")
                        .font(.footnote)
                        .foregroundColor(Color(UIColor.darkText))
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding()
            .background(
                Group {
                    if let isGood = viewModel.isGoodQuality {
                        isGood ? Color.green.opacity(0.15) : Color.orange.opacity(0.15)
                    } else {
                        Color.gray.opacity(0.15)
                    }
                }
            )
            .cornerRadius(8)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                PrimaryButton(title: "Gunakan foto ini", action: onConfirm, isDisabled: viewModel.isGoodQuality == nil)
                PrimaryButton(title: "Ambil foto ulang", action: onRetake, isOutlined: true)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.analyzeImageQuality(image: image)
        }
    }
}
