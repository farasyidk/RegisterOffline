import SwiftUI

public struct FormTextField: View {
    public let label: String
    public let placeholder: String
    @Binding public var text: String
    public let isMandatory: Bool
    public let keyboardType: UIKeyboardType
    
    public init(label: String, placeholder: String, text: Binding<String>, isMandatory: Bool = false, keyboardType: UIKeyboardType = .default) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isMandatory = isMandatory
        self.keyboardType = keyboardType
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 2) {
                Text(label)
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.darkGray))
                if isMandatory {
                    Text("*")
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                )
        }
    }
}
