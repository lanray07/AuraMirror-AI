import SwiftUI
import UIKit

struct PDFExportService {
    func makeStyleReportPDF(title: String, sections: [String]) -> URL? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(title.replacingOccurrences(of: " ", with: "-")).pdf")
        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Didot", size: 30) ?? .systemFont(ofSize: 30, weight: .semibold)]
                title.draw(at: CGPoint(x: 48, y: 54), withAttributes: titleAttributes)
                var y: CGFloat = 112
                for section in sections {
                    section.draw(in: CGRect(x: 48, y: y, width: 516, height: 74), withAttributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.darkGray])
                    y += 86
                }
            }
            return url
        } catch {
            return nil
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
