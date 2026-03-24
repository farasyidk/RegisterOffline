import SwiftUI

public struct FormDropdown: View {
    public let label: String
    public let placeholder: String
    @Binding public var selection: String
    public let options: [String]
    public let isMandatory: Bool
    
    public init(label: String, placeholder: String, selection: Binding<String>, options: [String], isMandatory: Bool = false) {
        self.label = label
        self.placeholder = placeholder
        self._selection = selection
        self.options = options
        self.isMandatory = isMandatory
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
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? placeholder : selection)
                        .foregroundColor(selection.isEmpty ? Color(UIColor.placeholderText) : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                )
            }
        }
    }
}
