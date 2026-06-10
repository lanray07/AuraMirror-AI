import SwiftUI

struct AuraDNAEngineView: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        ScreenScaffold(title: "Aura DNA Engine", subtitle: "Analyze selfies, profile photos, and full-body images into a supportive style identity.") {
            VStack(spacing: 18) {
                PhotoPickerButton(title: "Upload Style Photos", systemImage: "photo.on.rectangle.angled")
                Button {
                    Task { await viewModel.refreshAuraDNA(styleGoals: "Advanced Aura DNA analysis") }
                } label: {
                    Label(viewModel.isLoading ? "Analyzing" : "Run Mock AI Analysis", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AuraColor.gold)
                if let aura = viewModel.auraDNA {
                    AuraDNACard(aura: aura)
                    StyleSection(title: "Visual Strengths", items: aura.strengths)
                    StyleSection(title: "Image Recommendations", items: aura.recommendations)
                    ShareCardPreview(title: aura.archetype, subtitle: aura.aestheticIdentity)
                }
            }
        }
        .navigationTitle("Aura DNA")
    }
}

struct WardrobeScannerView: View {
    @Bindable var viewModel: AppViewModel
    private let engine = WardrobeScannerEngine()

    var body: some View {
        let result = engine.classifyMockWardrobe(items: viewModel.wardrobeItems)
        ScreenScaffold(title: "Wardrobe Scanner", subtitle: "Photograph your wardrobe to reveal categories, colors, gaps, duplicate items, and capsule opportunities.") {
            VStack(spacing: 18) {
                PhotoPickerButton(title: "Photograph Wardrobe", systemImage: "camera.viewfinder")
                Button {
                    Task { await viewModel.scanWardrobe() }
                } label: {
                    Label("Scan With Mock AI", systemImage: "hanger")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AuraColor.gold)
                if viewModel.wardrobeItems.isEmpty {
                    EmptyStateView(title: "No wardrobe items yet", message: "Start with a mock scan or add wardrobe photos.", systemImage: "hanger")
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(viewModel.wardrobeItems) { item in
                            WardrobeCard(item: item)
                        }
                    }
                    StyleSection(title: "Wardrobe Gaps", items: result.gaps)
                    StyleSection(title: "Capsule Suggestions", items: result.capsuleSuggestions)
                }
            }
        }
        .navigationTitle("Wardrobe")
    }
}

struct VoiceStylistAssistantView: View {
    @Bindable var viewModel: AppViewModel
    @State private var speech = SpeechRecognitionService()
    @State private var recorder = VoiceRecordingService()
    @State private var waveform = WaveformAnimationManager()
    @State private var response = "Ask AuraMirror AI what to wear, how to refine a capsule wardrobe, or which colors support your signature look."
    @State private var occasion = "Wedding"

    var body: some View {
        ScreenScaffold(title: "Voice Stylist", subtitle: "A premium speech-to-text stylist for event looks, capsule wardrobes, colors, and confidence-led presentation.") {
            VStack(spacing: 18) {
                VoiceWaveformView(levels: waveform.levels)
                    .luxuryCard()
                    .onChange(of: recorder.isRecording) { _, newValue in
                        waveform.animate(recording: newValue)
                    }
                Text(speech.transcript.isEmpty ? "Live transcription appears here." : speech.transcript)
                    .foregroundStyle(AuraColor.ivory)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .luxuryCard()
                Button {
                    recorder.toggleRecording()
                    speech.startMockTranscription()
                    waveform.animate(recording: recorder.isRecording)
                    Task {
                        do {
                            response = try await viewModel.ai.respond(to: speech.transcript)
                        } catch {
                            response = "AuraMirror AI could not complete that request. Try again with a shorter styling question."
                        }
                    }
                } label: {
                    Label(recorder.isRecording ? "Finish Styling Request" : "Ask With Voice", systemImage: "waveform")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AuraColor.gold)
                Text(response)
                    .foregroundStyle(AuraColor.ivory.opacity(0.82))
                    .luxuryCard()
                Picker("Occasion", selection: $occasion) {
                    ForEach(["Work", "Interview", "Date", "Wedding", "Travel", "Networking", "Content Creation", "Casual"], id: \.self, content: Text.init)
                }
                .pickerStyle(.menu)
                Button {
                    Task { await viewModel.generateOutfit(occasion: occasion) }
                } label: {
                    Label("Generate Occasion Look", systemImage: "calendar.badge.sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(AuraColor.ivory)
                if let outfit = viewModel.featuredOutfit {
                    OutfitCard(outfit: outfit)
                }
            }
        }
        .navigationTitle("AI Stylist")
        .task { await speech.requestAuthorization() }
    }
}

struct SettingsView: View {
    @Bindable var viewModel: AppViewModel
    @State private var showingPaywall = false

    var body: some View {
        ScreenScaffold(title: "Profile & Settings", subtitle: "Manage subscription, preferences, voice settings, privacy, and your beauty disclaimer.") {
            VStack(spacing: 16) {
                Button { showingPaywall = true } label: {
                    Label("Subscription", systemImage: "crown")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)
                .tint(AuraColor.gold)
                SettingsRow(title: "Style Preferences", systemImage: "slider.horizontal.3")
                SettingsRow(title: "Voice Settings", systemImage: "waveform")
                SettingsRow(title: "Wardrobe Settings", systemImage: "hanger")
                SettingsRow(title: "Privacy Policy", systemImage: "lock.shield")
                SettingsRow(title: "Terms of Use", systemImage: "doc.text")
                SettingsRow(title: "Beauty Disclaimer", systemImage: "heart.text.square")
                Button(role: .destructive) {} label: {
                    Label("Delete All Data", systemImage: "trash")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                NavigationLink("Style Analytics Dashboard") { StyleAnalyticsDashboardView(viewModel: viewModel) }
                    .foregroundStyle(AuraColor.gold)
                NavigationLink("Glow-Up Roadmap") { GlowUpRoadmapView() }
                    .foregroundStyle(AuraColor.gold)
                NavigationLink("Profile Photo Coach") { ProfilePhotoCoachView(viewModel: viewModel) }
                    .foregroundStyle(AuraColor.gold)
                NavigationLink("Look Collections") { LookCollectionsView() }
                    .foregroundStyle(AuraColor.gold)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingPaywall) {
            PaywallView(subscriptions: viewModel.subscriptions)
                .presentationDetents([.large])
        }
    }
}

struct ProfilePhotoCoachView: View {
    @Bindable var viewModel: AppViewModel
    @State private var report: StyleReport?

    var body: some View {
        ScreenScaffold(title: "Profile Photo Coach", subtitle: "Supportive image guidance for LinkedIn, dating apps, social media, and professional branding.") {
            VStack(spacing: 18) {
                PhotoPickerButton(title: "Upload Profile Photo", systemImage: "person.crop.square")
                Button {
                    Task {
                        do {
                            report = try await viewModel.ai.analyzeSelfImage(goal: "profile photo coach")
                        } catch {
                            report = StyleReport(title: "Analysis Unavailable", summary: "AuraMirror AI could not analyze that photo right now.", recommendations: ["Try a brighter image with a simple background."])
                        }
                    }
                } label: {
                    Label("Analyze Photo", systemImage: "camera.metering.center.weighted")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AuraColor.gold)
                if let report {
                    StyleSection(title: report.title, items: [report.summary] + report.recommendations)
                }
            }
        }
    }
}

struct GlowUpRoadmapView: View {
    private let plans = [
        ("30-Day Plan", ["Clarify signature palette", "Edit duplicate wardrobe items", "Practice one camera-ready pose"]),
        ("60-Day Plan", ["Build capsule looks", "Refine grooming routine as personal presentation", "Create profile photo variations"]),
        ("90-Day Plan", ["Establish seasonal wardrobe strategy", "Track outfit diversity", "Export your Aura style report"])
    ]

    var body: some View {
        ScreenScaffold(title: "Glow-Up Roadmap", subtitle: "A confidence-focused plan for wardrobe, grooming, photography, and presentation.") {
            VStack(spacing: 16) {
                ForEach(plans, id: \.0) { plan in
                    StyleSection(title: plan.0, items: plan.1)
                }
            }
        }
    }
}

struct StyleAnalyticsDashboardView: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        ScreenScaffold(title: "Style Analytics", subtitle: "Track wardrobe utilization, color distribution, consistency, outfit diversity, and shopping efficiency.") {
            VStack(spacing: 18) {
                AnalyticsChartCard(title: "Color Distribution", data: [("Black", 42), ("Ivory", 28), ("Gold", 12), ("Berry", 18)])
                AnalyticsChartCard(title: "Wardrobe Utilization", data: [("Work", 70), ("Event", 38), ("Travel", 52), ("Casual", 64)])
                StyleSection(title: "Shopping Intelligence", items: ["Prioritize gaps before trend items.", "Repeat your best colors across categories.", "Favor versatile tailoring for higher utilization."])
            }
        }
    }
}

struct LookCollectionsView: View {
    private let collections = ["Travel Wardrobe", "Work Wardrobe", "Luxury Wardrobe", "Minimalist Wardrobe", "Seasonal Wardrobe"]

    var body: some View {
        ScreenScaffold(title: "Look Collections", subtitle: "Save and export personal look systems for seasons, travel, work, and special events.") {
            VStack(spacing: 14) {
                ForEach(collections, id: \.self) { collection in
                    ShareCardPreview(title: collection, subtitle: "A refined capsule built from your Aura DNA.")
                }
            }
        }
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var subscriptions: SubscriptionService
    private let privacyURL = URL(string: "https://github.com/lanray07/AuraMirror-AI/blob/main/PRIVACY_POLICY.md")!
    private let eulaURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    private let submittedPlans: [AuraPlan] = [.premiumMonthly, .premiumYearly]

    var body: some View {
        ZStack {
            LuxuryBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    EditorialTitle(eyebrow: "Aura Premium", title: "Unlock deeper personal image intelligence.", subtitle: "Unlimited AI analysis, wardrobe scanning, outfit generation, profile photo coaching, and glow-up roadmaps.")
                    ForEach(submittedPlans) { plan in
                        Button {
                            Task {
                                await subscriptions.purchase(plan)
                                if subscriptions.activePlan == plan {
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(plan.rawValue)
                                        .font(.headline)
                                    Text("\(subscriptions.displayPrice(for: plan)) / \(plan.durationText)")
                                        .font(.subheadline)
                                        .foregroundStyle(AuraColor.gold)
                                    Text(plan.renewalText)
                                        .font(.caption)
                                        .foregroundStyle(AuraColor.ivory.opacity(0.7))
                                }
                                Spacer()
                                Image(systemName: subscriptions.isLoading ? "hourglass" : "chevron.right")
                            }
                            .foregroundStyle(AuraColor.ivory)
                        }
                        .disabled(subscriptions.isLoading || subscriptions.product(for: plan) == nil)
                        .luxuryCard()
                    }
                    if let purchaseError = subscriptions.purchaseError {
                        Text(purchaseError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .luxuryCard()
                    } else if let purchaseMessage = subscriptions.purchaseMessage {
                        Text(purchaseMessage)
                            .font(.footnote)
                            .foregroundStyle(AuraColor.ivory.opacity(0.78))
                            .luxuryCard()
                    }
                    Button {
                        Task { await subscriptions.restorePurchases() }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(AuraColor.ivory)
                    .disabled(subscriptions.isLoading)
                    StyleSection(title: "Free", items: ["Limited analyses", "Limited outfits", "Limited wardrobe scans"])
                    StyleSection(title: "Aura Premium", items: ["Advanced Aura DNA", "Luxury styling modes", "Premium themes", "Advanced analytics", "Exclusive archetypes"])
                    StyleSection(title: "Subscription Details", items: [
                        "Payment is charged to your Apple ID at confirmation of purchase.",
                        "Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period.",
                        "Manage or cancel subscriptions in your App Store account settings."
                    ])
                    HStack(spacing: 18) {
                        Link("Privacy Policy", destination: privacyURL)
                        Link("Terms of Use (EULA)", destination: eulaURL)
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AuraColor.gold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .luxuryCard()
                }
                .padding(20)
            }
        }
        .task { await subscriptions.loadProducts() }
    }
}

struct StyleSection: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AuraColor.ivory)
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "diamond")
                    .font(.callout)
                    .foregroundStyle(AuraColor.ivory.opacity(0.78))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .luxuryCard()
    }
}

struct SettingsRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AuraColor.ivory.opacity(0.5))
        }
        .foregroundStyle(AuraColor.ivory)
        .luxuryCard()
    }
}
