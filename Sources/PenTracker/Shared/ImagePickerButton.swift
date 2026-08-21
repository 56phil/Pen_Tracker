import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ImagePickerButton: View {
    @Binding var photo: Data?
    var label: String = "Choose Photo…"

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
    }

    private func choosePhoto() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url, let data = try? Data(contentsOf: url) {
            photo = data
        }
    }
}
