import Foundation

struct WardrobeScanResult {
    var categories: [String]
    var colors: [String]
    var styles: [String]
    var gaps: [String]
    var duplicates: [String]
    var capsuleSuggestions: [String]
}

struct WardrobeScannerEngine {
    func classifyMockWardrobe(items: [WardrobeItem]) -> WardrobeScanResult {
        WardrobeScanResult(
            categories: Array(Set(items.map(\.category))).sorted(),
            colors: Array(Set(items.map(\.color))).sorted(),
            styles: Array(Set(items.map(\.style))).sorted(),
            gaps: ["Evening layer", "Warm neutral knit", "Polished day shoe"],
            duplicates: ["Black tailored separates"],
            capsuleSuggestions: ["Five-piece executive capsule", "Weekend quiet-luxury edit"]
        )
    }
}
