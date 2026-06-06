import Foundation
import Observation

@MainActor
@Observable
final class AppViewModel {
    var selectedTab: AppTab = .dashboard
    var isOnboardingComplete = false
    var isLoading = false
    var errorMessage: String?
    var auraDNA: AuraDNA?
    var featuredOutfit: Outfit?
    var wardrobeItems: [WardrobeItem] = []
    var insights: [StyleInsight] = [
        StyleInsight(title: "Signature Palette", content: "Ivory, obsidian, champagne, and one expressive jewel tone."),
        StyleInsight(title: "Image Ritual", content: "Start every look with fit, then refine texture and light.")
    ]
    var subscription = SubscriptionState(plan: "Aura Premium", isActive: false)

    let ai: MockAIService
    let subscriptions: SubscriptionService

    init(ai: MockAIService? = nil, subscriptions: SubscriptionService? = nil) {
        self.ai = ai ?? MockAIService()
        self.subscriptions = subscriptions ?? SubscriptionService()
    }

    func completeOnboarding(profile: OnboardingProfileDraft) async {
        isOnboardingComplete = true
        await refreshAuraDNA(styleGoals: profile.styleGoals.joined(separator: ", "))
    }

    func refreshAuraDNA(styleGoals: String = "Build a refined personal image") async {
        await runLoading {
            self.auraDNA = try await self.ai.analyze(request: AuraAnalysisRequest(module: "aura_dna", photos: [], styleGoals: styleGoals, occasion: "", voiceTranscript: ""))
            self.featuredOutfit = try await self.ai.generateOutfit(occasion: "Work", mood: "confident", weather: "mild")
            self.wardrobeItems = try await self.ai.scanWardrobe()
        }
    }

    func generateOutfit(occasion: String) async {
        await runLoading {
            self.featuredOutfit = try await self.ai.generateOutfit(occasion: occasion, mood: "elevated", weather: "seasonal")
        }
    }

    func scanWardrobe() async {
        await runLoading {
            self.wardrobeItems = try await self.ai.scanWardrobe()
        }
    }

    private func runLoading(_ operation: @escaping () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        do {
            try await operation()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case auraDNA = "Aura DNA"
    case wardrobe = "Wardrobe"
    case stylist = "Stylist"
    case profile = "Profile"

    var id: String { rawValue }
    var systemImage: String {
        switch self {
        case .dashboard: return "sparkles"
        case .auraDNA: return "person.crop.rectangle.stack"
        case .wardrobe: return "hanger"
        case .stylist: return "waveform"
        case .profile: return "crown"
        }
    }
}

struct OnboardingProfileDraft {
    var genderIdentity = ""
    var styleGoals: [String] = []
    var lifestyle = "City-led"
    var wardrobeSize = "Curated"
    var fashionConfidence = 6.0
    var shoppingHabits = "Intentional"
    var styleInterests: Set<String> = ["Quiet Luxury", "Modern Executive"]
}
