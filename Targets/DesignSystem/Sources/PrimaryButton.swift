import SwiftUI

public struct PrimaryButton: View {
    public let title: String
    public let action: () -> Void
    public let isLoading: Bool
    public let isDisabled: Bool
    public let isOutlined: Bool
    
    public init(title: String, action: @escaping () -> Void, isLoading: Bool = false, isDisabled: Bool = false, isOutlined: Bool = false) {
        self.title = title
        self.action = action
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.isOutlined = isOutlined
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView().tint(isOutlined ? Color.brandDarkBlue : .white)
                } else {
                    Text(title)
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isOutlined ? Color.clear : (isDisabled ? Color.gray.opacity(0.1) : Color.brandDarkBlue)
            )
            .foregroundColor(
                isOutlined ? Color.brandDarkBlue : (isDisabled ? Color.gray : .white)
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isOutlined ? Color.brandDarkBlue : Color.clear, lineWidth: 1)
            )
        }
        .disabled(isLoading || isDisabled)
    }
}
