import SwiftData
import SwiftUI

@main
struct AuraMirrorAIApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: UserProfile.self,
                AuraDNA.self,
                WardrobeItem.self,
                Outfit.self,
                LookCollection.self,
                VoiceTranscript.self,
                StyleInsight.self,
                SubscriptionState.self
            )
        } catch {
            fatalError("Unable to initialize SwiftData: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container)
                .preferredColorScheme(.dark)
        }
    }
}
