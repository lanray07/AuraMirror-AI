import PhotosUI
import SwiftUI

struct PhotoPickerButton: View {
    @State private var item: PhotosPickerItem?
    let title: String
    let systemImage: String

    var body: some View {
        PhotosPicker(selection: $item, matching: .images) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AuraColor.gold.opacity(0.5)))
        }
        .tint(AuraColor.ivory)
    }
}

struct ImageAnalysisPipeline {
    var mockEnabled = true

    func extractPhotoTokens(from photos: [PhotosPickerItem]) async -> [String] {
        mockEnabled ? ["mock-selfie", "mock-full-body"] : photos.map { $0.itemIdentifier ?? "photo" }
    }
}
