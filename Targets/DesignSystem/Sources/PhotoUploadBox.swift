import SwiftUI

public struct PhotoUploadBox: View {
    public let onTap: () -> Void
    
    public init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .frame(height: 100)
                    .background(Color(UIColor.secondarySystemBackground))
                
                Image(systemName: "camera.fill")
                    .foregroundColor(Color.brandDarkBlue)
                    .font(.system(size: 24))
            }
        }
    }
}
