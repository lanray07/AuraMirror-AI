import Charts
import SwiftUI

struct AuraDNACard: View {
    let aura: AuraDNA

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Aura DNA")
                        .font(.caption)
                        .foregroundStyle(AuraColor.gold)
                    Text(aura.archetype)
                        .font(.custom("Didot", size: 34, relativeTo: .title))
                        .foregroundStyle(AuraColor.ivory)
                }
                Spacer()
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(AuraColor.gold)
            }
            Text(aura.aestheticIdentity)
                .foregroundStyle(AuraColor.ivory.opacity(0.82))
            TagCloud(tags: aura.colorProfile)
            ForEach(aura.confidenceInsights, id: \.self) { insight in
                Label(insight, systemImage: "checkmark.seal")
                    .font(.footnote)
                    .foregroundStyle(AuraColor.ivory.opacity(0.78))
            }
        }
        .luxuryCard()
    }
}

struct OutfitCard: View {
    let outfit: Outfit

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(outfit.occasion.uppercased(), systemImage: "calendar")
                .font(.caption)
                .foregroundStyle(AuraColor.gold)
            Text(outfit.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AuraColor.ivory)
            ForEach(outfit.components, id: \.self) { component in
                Text(component)
                    .font(.callout)
                    .foregroundStyle(AuraColor.ivory.opacity(0.8))
            }
            TagCloud(tags: outfit.stylingNotes)
        }
        .luxuryCard()
    }
}

struct WardrobeCard: View {
    let item: WardrobeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                LinearGradient(colors: [AuraColor.graphite, AuraColor.berry.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "hanger")
                    .font(.largeTitle)
                    .foregroundStyle(AuraColor.ivory.opacity(0.8))
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(item.category)
                .font(.headline)
                .foregroundStyle(AuraColor.ivory)
            Text("\(item.color) / \(item.style)")
                .font(.footnote)
                .foregroundStyle(AuraColor.ivory.opacity(0.7))
        }
        .luxuryCard()
    }
}

struct StyleInsightCard: View {
    let insight: StyleInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(insight.title)
                .font(.headline)
                .foregroundStyle(AuraColor.ivory)
            Text(insight.content)
                .font(.callout)
                .foregroundStyle(AuraColor.ivory.opacity(0.74))
        }
        .luxuryCard()
    }
}

struct VoiceWaveformView: View {
    let levels: [CGFloat]

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            ForEach(levels.indices, id: \.self) { index in
                Capsule()
                    .fill(LinearGradient(colors: [AuraColor.gold, AuraColor.ivory], startPoint: .top, endPoint: .bottom))
                    .frame(width: 5, height: max(12, 92 * levels[index]))
                    .animation(.smooth(duration: 0.28), value: levels[index])
            }
        }
        .frame(maxWidth: .infinity, minHeight: 116)
    }
}

struct AnalyticsChartCard: View {
    let title: String
    let data: [(String, Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AuraColor.ivory)
            Chart(data, id: \.0) { item in
                BarMark(x: .value("Category", item.0), y: .value("Value", item.1))
                    .foregroundStyle(AuraColor.gold.gradient)
            }
            .frame(height: 180)
        }
        .luxuryCard()
    }
}

struct ShareCardPreview: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("AURAMIRROR AI")
                .font(.caption)
                .foregroundStyle(AuraColor.gold)
            Text(title)
                .font(.custom("Didot", size: 38, relativeTo: .largeTitle))
                .foregroundStyle(AuraColor.ivory)
            Text(subtitle)
                .foregroundStyle(AuraColor.ivory.opacity(0.76))
        }
        .padding(24)
        .frame(height: 420)
        .background(LinearGradient(colors: [Color.black, AuraColor.berry, AuraColor.graphite], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct UpgradeBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .foregroundStyle(AuraColor.gold)
            VStack(alignment: .leading) {
                Text("Aura Premium")
                    .font(.headline)
                Text("Unlock advanced Aura DNA, luxury modes, and premium analytics.")
                    .font(.footnote)
                    .foregroundStyle(AuraColor.ivory.opacity(0.72))
            }
            Spacer()
        }
        .foregroundStyle(AuraColor.ivory)
        .luxuryCard()
    }
}

struct TagCloud: View {
    let tags: [String]

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AuraColor.ivory)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(AuraColor.gold.opacity(0.16), in: Capsule())
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: size.width, height: size.height))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
