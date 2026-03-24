import SwiftUI

public struct FormTextField: View {
    public let label: String
    public let placeholder: String
    @Binding public var text: String
    public let isMandatory: Bool
    public let keyboardType: UIKeyboardType
    public let helpText: String?
    public let isError: Bool
    public let maxLength: Int?
    
    public init(label: String, placeholder: String, text: Binding<String>, isMandatory: Bool = false, keyboardType: UIKeyboardType = .default, helpText: String? = nil, isError: Bool = false, maxLength: Int? = nil) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isMandatory = isMandatory
        self.keyboardType = keyboardType
        self.helpText = helpText
        self.isError = isError
        self.maxLength = maxLength
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 2) {
                Text(label)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                if isMandatory {
                    Text("*")
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }
            
            TextField(placeholder, text: Binding(
                get: { self.text },
                set: { newValue in
                    if let limit = maxLength {
                        self.text = String(newValue.prefix(limit))
                    } else {
                        self.text = newValue
                    }
                }
            ))
            .keyboardType(keyboardType)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isError ? Color.red : Color(UIColor.systemGray4), lineWidth: 1)
            )
            
            if let helpText = helpText {
                Text(helpText)
                    .font(.caption2)
                    .foregroundColor(isError ? .red : .secondary)
                    .padding(.horizontal, 4)
            }
        }
    }
}
