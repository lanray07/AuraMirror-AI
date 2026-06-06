import Foundation

protocol AuraDNAService {
    func analyze(request: AuraAnalysisRequest) async throws -> AuraDNA
}

protocol StyleAnalysisService {
    func analyzeSelfImage(goal: String) async throws -> StyleReport
}

protocol OutfitGenerationService {
    func generateOutfit(occasion: String, mood: String, weather: String) async throws -> Outfit
}

protocol WardrobeScannerService {
    func scanWardrobe() async throws -> [WardrobeItem]
}

protocol ShoppingIntelligenceService {
    func suggestions(for gaps: [String]) async throws -> [String]
}

protocol VoiceStylistService {
    func respond(to transcript: String) async throws -> String
}

final class MockAIService: AuraDNAService, StyleAnalysisService, OutfitGenerationService, WardrobeScannerService, ShoppingIntelligenceService, VoiceStylistService {
    func analyze(request: AuraAnalysisRequest) async throws -> AuraDNA {
        try await Task.sleep(nanoseconds: 250_000_000)
        return AuraDNA(
            archetype: "The Modern Muse",
            strengths: ["Clean lines", "Expressive details", "A memorable signature palette"],
            colorProfile: ["Ivory", "Champagne", "Graphite", "Deep berry"],
            aestheticIdentity: "Quiet luxury with a cinematic, confident finish.",
            recommendations: ["Anchor outfits with one tailored element.", "Repeat a signature color near the face.", "Choose texture over loud pattern for polish."],
            confidenceInsights: ["Your strongest style reads intentional and composed.", "Small styling rituals can make everyday looks feel distinctive."]
        )
    }

    func analyzeSelfImage(goal: String) async throws -> StyleReport {
        StyleReport(
            title: "Profile Photo Refinement",
            summary: "A softer side light, structured neckline, and calm background will make the image feel elevated and assured.",
            recommendations: ["Face a window at a slight angle.", "Choose ivory, black, or deep jewel tones.", "Keep accessories minimal but deliberate."]
        )
    }

    func generateOutfit(occasion: String, mood: String, weather: String) async throws -> Outfit {
        Outfit(
            title: "\(occasion) Atelier Look",
            occasion: occasion,
            components: ["Silk ivory blouse", "Tailored black trouser", "Champagne accent jewelry", "Polished leather shoe"],
            stylingNotes: ["Balance structure with one soft texture.", "Keep the palette refined and camera-ready.", "Add a final intentional detail before leaving."]
        )
    }

    func scanWardrobe() async throws -> [WardrobeItem] {
        [
            WardrobeItem(category: "Blazer", color: "Obsidian", style: "Modern Executive"),
            WardrobeItem(category: "Knitwear", color: "Ivory", style: "Quiet Luxury"),
            WardrobeItem(category: "Trouser", color: "Graphite", style: "Contemporary Classic")
        ]
    }

    func suggestions(for gaps: [String]) async throws -> [String] {
        ["A sculptural black blazer", "Ivory knit with refined neckline", "One metallic evening accent", "A clean leather day shoe"]
    }

    func respond(to transcript: String) async throws -> String {
        "For that moment, build from a refined base: tailored black, ivory near the face, and one luminous accent. The look should feel composed, never overworked."
    }
}

final class RemoteAIService: AuraDNAService, StyleAnalysisService, OutfitGenerationService, WardrobeScannerService, ShoppingIntelligenceService, VoiceStylistService {
    private let endpoint = URL(string: "https://YOUR_BACKEND_URL.com/auramirror-ai")!

    func analyze(request: AuraAnalysisRequest) async throws -> AuraDNA {
        let response: AuraAnalysisResponse = try await post(request)
        return AuraDNA(
            archetype: response.auraDNA.isEmpty ? "The Icon" : response.auraDNA,
            strengths: ["Visual consistency", "Refined presentation"],
            colorProfile: response.recommendations.prefix(4).map { $0 },
            aestheticIdentity: response.auraDNA,
            recommendations: response.recommendations,
            confidenceInsights: ["Your personal image becomes stronger when repeated style choices feel intentional."]
        )
    }

    func analyzeSelfImage(goal: String) async throws -> StyleReport {
        let response: AuraAnalysisResponse = try await post(AuraAnalysisRequest(module: "self_analysis", photos: [], styleGoals: goal, occasion: "", voiceTranscript: ""))
        return StyleReport(title: "AI Self Analysis", summary: response.auraDNA, recommendations: response.recommendations)
    }

    func generateOutfit(occasion: String, mood: String, weather: String) async throws -> Outfit {
        let response: AuraAnalysisResponse = try await post(AuraAnalysisRequest(module: "outfit", photos: [], styleGoals: mood, occasion: occasion, voiceTranscript: weather))
        return Outfit(title: response.outfits.first ?? "Curated Look", occasion: occasion, components: response.outfits, stylingNotes: response.recommendations)
    }

    func scanWardrobe() async throws -> [WardrobeItem] {
        let response: AuraAnalysisResponse = try await post(AuraAnalysisRequest(module: "wardrobe_scan", photos: [], styleGoals: "", occasion: "", voiceTranscript: ""))
        return response.recommendations.map { WardrobeItem(category: $0, color: "Detected", style: "AI classified") }
    }

    func suggestions(for gaps: [String]) async throws -> [String] {
        let response: AuraAnalysisResponse = try await post(AuraAnalysisRequest(module: "shopping", photos: [], styleGoals: gaps.joined(separator: ", "), occasion: "", voiceTranscript: ""))
        return response.shoppingSuggestions
    }

    func respond(to transcript: String) async throws -> String {
        let response: AuraAnalysisResponse = try await post(AuraAnalysisRequest(module: "voice_stylist", photos: [], styleGoals: "", occasion: "", voiceTranscript: transcript))
        return response.recommendations.joined(separator: "\n")
    }

    private func post<T: Codable>(_ request: AuraAnalysisRequest) async throws -> T {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
