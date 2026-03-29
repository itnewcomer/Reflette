import SwiftUI

struct ErrorAlert: ViewModifier {
    @Binding var error: String?

    func body(content: Content) -> some View {
        content.alert(L10n.error, isPresented: .init(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Button("OK") { error = nil }
        } message: {
            Text(error ?? "")
        }
    }
}

extension View {
    func errorAlert(_ error: Binding<String?>) -> some View {
        modifier(ErrorAlert(error: error))
    }
}
