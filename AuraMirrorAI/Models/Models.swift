import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var genderIdentity: String
    var styleGoals: [String]
    var lifestyle: String
    var wardrobeSize: String
    var fashionConfidence: Int
    var shoppingHabits: String
    var styleInterests: [String]
    var createdAt: Date

    init(genderIdentity: String = "Self-described", styleGoals: [String] = [], lifestyle: String = "Editorial everyday", wardrobeSize: String = "Curated", fashionConfidence: Int = 6, shoppingHabits: String = "Intentional", styleInterests: [String] = []) {
        self.id = UUID()
        self.genderIdentity = genderIdentity
        self.styleGoals = styleGoals
        self.lifestyle = lifestyle
        self.wardrobeSize = wardrobeSize
        self.fashionConfidence = fashionConfidence
        self.shoppingHabits = shoppingHabits
        self.styleInterests = styleInterests
        self.createdAt = Date()
    }
}

@Model
final class AuraDNA {
    var id: UUID
    var archetype: String
    var strengths: [String]
    var colorProfile: [String]
    var aestheticIdentity: String
    var recommendations: [String]
    var confidenceInsights: [String]
    var createdAt: Date

    init(archetype: String, strengths: [String], colorProfile: [String], aestheticIdentity: String, recommendations: [String], confidenceInsights: [String]) {
        self.id = UUID()
        self.archetype = archetype
        self.strengths = strengths
        self.colorProfile = colorProfile
        self.aestheticIdentity = aestheticIdentity
        self.recommendations = recommendations
        self.confidenceInsights = confidenceInsights
        self.createdAt = Date()
    }
}

@Model
final class WardrobeItem {
    var id: UUID
    var category: String
    var color: String
    var style: String
    var imagePlaceholder: String
    var createdAt: Date

    init(category: String, color: String, style: String, imagePlaceholder: String = "fashion-placeholder") {
        self.id = UUID()
        self.category = category
        self.color = color
        self.style = style
        self.imagePlaceholder = imagePlaceholder
        self.createdAt = Date()
    }
}

@Model
final class Outfit {
    var id: UUID
    var title: String
    var occasion: String
    var components: [String]
    var stylingNotes: [String]
    var createdAt: Date

    init(title: String, occasion: String, components: [String], stylingNotes: [String] = []) {
        self.id = UUID()
        self.title = title
        self.occasion = occasion
        self.components = components
        self.stylingNotes = stylingNotes
        self.createdAt = Date()
    }
}

@Model
final class LookCollection {
    var id: UUID
    var title: String
    var category: String
    var createdAt: Date

    init(title: String, category: String) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.createdAt = Date()
    }
}

@Model
final class VoiceTranscript {
    var id: UUID
    var transcript: String
    var aiResponse: String
    var createdAt: Date

    init(transcript: String, aiResponse: String) {
        self.id = UUID()
        self.transcript = transcript
        self.aiResponse = aiResponse
        self.createdAt = Date()
    }
}

@Model
final class StyleInsight {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date

    init(title: String, content: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
    }
}

@Model
final class SubscriptionState {
    var id: UUID
    var plan: String
    var isActive: Bool

    init(plan: String = "Free", isActive: Bool = false) {
        self.id = UUID()
        self.plan = plan
        self.isActive = isActive
    }
}
