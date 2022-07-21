import SwiftUI

struct LabelModifier: ViewModifier {
    var label: String

    func body(content: Content) -> some View {
        return HStack(alignment: .firstTextBaseline) {
            Text(label)
            Spacer()
            content
        }
    }
}

extension View {
    /// Add label to left side of View
    /// - Parameter label: Label to add
    /// - Returns: modified view
    func withLabel(label: String) -> some View {
        return self.modifier(LabelModifier(label: label))
    }
}
