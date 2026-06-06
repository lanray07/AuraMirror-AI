import SwiftUI

enum AuraColor {
    static let obsidian = Color(red: 0.035, green: 0.033, blue: 0.038)
    static let ink = Color(red: 0.075, green: 0.071, blue: 0.082)
    static let ivory = Color(red: 0.965, green: 0.93, blue: 0.84)
    static let champagne = Color(red: 0.78, green: 0.63, blue: 0.38)
    static let gold = Color(red: 0.95, green: 0.78, blue: 0.44)
    static let berry = Color(red: 0.42, green: 0.08, blue: 0.18)
    static let graphite = Color(red: 0.23, green: 0.23, blue: 0.25)
}

struct LuxuryBackground: View {
    var body: some View {
        LinearGradient(
            colors: [AuraColor.obsidian, AuraColor.ink, Color.black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct EditorialTitle: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow.uppercased())
                .font(.caption)
                .foregroundStyle(AuraColor.gold)
            Text(title)
                .font(.custom("Didot", size: 42, relativeTo: .largeTitle))
                .foregroundStyle(AuraColor.ivory)
                .lineLimit(3)
                .minimumScaleFactor(0.75)
            Text(subtitle)
                .font(.callout)
                .foregroundStyle(AuraColor.ivory.opacity(0.72))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func luxuryCard(cornerRadius: CGFloat = 8) -> some View {
        padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(AuraColor.gold.opacity(0.28), lineWidth: 1))
    }
}
