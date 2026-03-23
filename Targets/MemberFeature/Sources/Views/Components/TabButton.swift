import SwiftUI
import DesignSystem

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? Color.brandDarkBlue : .gray)
                    .padding(.top, 12)
                
                Rectangle()
                    .fill(isSelected ? Color.brandDarkBlue : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
