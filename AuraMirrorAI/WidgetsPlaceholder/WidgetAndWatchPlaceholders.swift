import Foundation
import SwiftUI

struct AuraWidgetSnapshot {
    var outfitSuggestion = "Ivory knit, tailored black trouser, champagne accent."
    var styleTip = "Repeat one signature color near the face today."
    var auraScore = 92
    var inspiration = "Quiet luxury with a cinematic finish."
}

struct WidgetPlaceholderView: View {
    let snapshot = AuraWidgetSnapshot()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AuraMirror")
                .font(.headline)
            Text(snapshot.outfitSuggestion)
                .font(.caption)
            Text("Aura \(snapshot.auraScore)")
                .font(.caption2)
                .foregroundStyle(AuraColor.gold)
        }
        .padding()
        .background(AuraColor.obsidian)
        .foregroundStyle(AuraColor.ivory)
    }
}

struct WatchReminderPayload {
    var title: String
    var body: String
    var date: Date
}

final class WatchConnectivityPlaceholder {
    func upcomingReminders() -> [WatchReminderPayload] {
        [
            WatchReminderPayload(title: "Outfit reminder", body: "Lay out tomorrow's work look.", date: .now.addingTimeInterval(3600)),
            WatchReminderPayload(title: "Shopping reminder", body: "Check capsule gaps before buying.", date: .now.addingTimeInterval(7200))
        ]
    }
}
