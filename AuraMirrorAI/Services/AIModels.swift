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

    var productID: String? {
        switch self {
        case .free: return nil
        case .premiumMonthly: return "auramirror.premium.monthly"
        case .premiumYearly: return "auramirror.premium.yearly"
        case .eliteMonthly: return "auramirror.elite.monthly"
        }
    }

    var fallbackPrice: String {
        switch self {
        case .free: return "Included"
        case .premiumMonthly: return "GBP 12.99"
        case .premiumYearly: return "GBP 99.99"
        case .eliteMonthly: return "GBP 24.99"
        }
    }

    var durationText: String {
        switch self {
        case .free: return "No subscription"
        case .premiumMonthly, .eliteMonthly: return "1 month"
        case .premiumYearly: return "1 year"
        }
    }

    var renewalText: String {
        switch self {
        case .free: return "Free preview access"
        case .premiumMonthly, .eliteMonthly: return "Auto-renews monthly until canceled"
        case .premiumYearly: return "Auto-renews yearly until canceled"
        }
    }
}

let auraSystemPrompt = "You are AuraMirror AI, a luxury beauty and style intelligence assistant. Help users improve personal style, wardrobe choices, grooming, and confidence using supportive, fashion-forward language. Avoid attractiveness ratings, appearance shaming, cosmetic procedure recommendations, or medical claims."
