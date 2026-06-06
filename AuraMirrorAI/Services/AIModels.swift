import Foundation

struct AuraAnalysisRequest: Codable {
    var module: String
    var photos: [String]
    var styleGoals: String
    var occasion: String
    var voiceTranscript: String
}

struct AuraAnalysisResponse: Codable {
    var auraDNA: String
    var outfits: [String]
    var recommendations: [String]
    var shoppingSuggestions: [String]
}

struct StyleReport: Identifiable {
    let id = UUID()
    var title: String
    var summary: String
    var recommendations: [String]
}

enum AuraPlan: String, CaseIterable, Identifiable {
    case free = "Free"
    case premiumMonthly = "Aura Premium Monthly"
    case premiumYearly = "Aura Premium Yearly"
    case eliteMonthly = "Aura Elite Monthly"

    var id: String { rawValue }

    var price: String {
        switch self {
        case .free: return "Included"
        case .premiumMonthly: return "GBP 12.99"
        case .premiumYearly: return "GBP 99.99"
        case .eliteMonthly: return "GBP 24.99"
        }
    }
}

let auraSystemPrompt = "You are AuraMirror AI, a luxury beauty and style intelligence assistant. Help users improve personal style, wardrobe choices, grooming, and confidence using supportive, fashion-forward language. Avoid attractiveness ratings, appearance shaming, cosmetic procedure recommendations, or medical claims."
