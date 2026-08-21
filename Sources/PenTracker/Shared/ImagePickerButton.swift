import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ImagePickerButton: View {
    @Binding var photo: Data?
    var label: String = "Choose Photo…"

    @State private var loadErrorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let photo, let nsImage = NSImage(data: photo) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            HStack {
                Button(label) { choosePhoto() }
                if photo != nil {
                    Button("Remove") { photo = nil }
                        .foregroundStyle(.red)
                }
            }
        }
        .alert("Couldn't Load Photo", isPresented: Binding(
            get: { loadErrorMessage != nil },
            set: { if !$0 { loadErrorMessage = nil } }
        ), presenting: loadErrorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }

    private func choosePhoto() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            photo = try Data(contentsOf: url)
        } catch {
            loadErrorMessage = error.localizedDescription
        }
    }
}
