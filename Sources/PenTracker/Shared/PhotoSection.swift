import SwiftUI
import AppKit

struct PhotoSection: View {
    let photo: Data?
    var maxHeight: CGFloat = 200

    var body: some View {
        if let photo, let nsImage = NSImage(data: photo) {
            Section("Photo") {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: maxHeight)
            }
        }
    }
}
