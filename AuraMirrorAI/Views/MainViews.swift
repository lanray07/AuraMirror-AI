import SwiftData
import SwiftUI

struct RootView: View {
    @State private var viewModel = AppViewModel()

    var body: some View {
        Group {
            if viewModel.isOnboardingComplete {
                AppShellView(viewModel: viewModel)
            } else {
                OnboardingView(viewModel: viewModel)
            }
        }
        .background(LuxuryBackground())
        .task {
            await viewModel.refreshAuraDNA()
        }
    }
}

struct AppShellView: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            NavigationStack { DashboardView(viewModel: viewModel) }
                .tabItem { Label(AppTab.dashboard.rawValue, systemImage: AppTab.dashboard.systemImage) }
                .tag(AppTab.dashboard)
            NavigationStack { AuraDNAEngineView(viewModel: viewModel) }
                .tabItem { Label(AppTab.auraDNA.rawValue, systemImage: AppTab.auraDNA.systemImage) }
                .tag(AppTab.auraDNA)
            NavigationStack { WardrobeScannerView(viewModel: viewModel) }
                .tabItem { Label(AppTab.wardrobe.rawValue, systemImage: AppTab.wardrobe.systemImage) }
                .tag(AppTab.wardrobe)
            NavigationStack { VoiceStylistAssistantView(viewModel: viewModel) }
                .tabItem { Label(AppTab.stylist.rawValue, systemImage: AppTab.stylist.systemImage) }
                .tag(AppTab.stylist)
            NavigationStack { SettingsView(viewModel: viewModel) }
                .tabItem { Label(AppTab.profile.rawValue, systemImage: AppTab.profile.systemImage) }
                .tag(AppTab.profile)
        }
        .tint(AuraColor.gold)
    }
}

struct OnboardingView: View {
    @Bindable var viewModel: AppViewModel
    @State private var draft = OnboardingProfileDraft()
    @State private var page = 0

    private let interests = ["Quiet Luxury", "Old Money", "Modern Executive", "Street Luxe", "Minimalist", "Soft Glam", "Contemporary Classic", "Creative", "Fashion Forward"]
    private let goals = ["Define my aesthetic", "Improve wardrobe choices", "Optimize profile photos", "Build confidence", "Plan outfits"]

    var body: some View {
        ZStack {
            LuxuryBackground()
            ScrollView {
                VStack(spacing: 28) {
                    EditorialTitle(
                        eyebrow: "The AI mirror that sees your best self",
                        title: page == 0 ? "Discover the version of you the world remembers." : "Your Style Identity Card is almost ready.",
                        subtitle: "A supportive, fashion-forward profile for color, wardrobe, grooming, photography, and personal image."
                    )
                    if page == 0 { introFields } else { styleInterestFields }
                    Button {
                        if page == 0 {
                            withAnimation(.smooth) { page = 1 }
                        } else {
                            Task { await viewModel.completeOnboarding(profile: draft) }
                        }
                    } label: {
                        Label(page == 0 ? "Continue" : "Generate Aura Profile", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AuraColor.gold)
                    safetyNote
                }
                .padding(22)
            }
        }
    }

    private var introFields: some View {
        VStack(spacing: 16) {
            TextField("Gender identity", text: $draft.genderIdentity)
                .textFieldStyle(.roundedBorder)
            Picker("Lifestyle", selection: $draft.lifestyle) {
                ForEach(["City-led", "Creative", "Corporate", "Social", "Travel-heavy"], id: \.self, content: Text.init)
            }
            .pickerStyle(.menu)
            Picker("Wardrobe size", selection: $draft.wardrobeSize) {
                ForEach(["Minimal", "Curated", "Expansive", "Seasonal"], id: \.self, content: Text.init)
            }
            .pickerStyle(.segmented)
            VStack(alignment: .leading) {
                Text("Fashion confidence")
                    .foregroundStyle(AuraColor.ivory)
                Slider(value: $draft.fashionConfidence, in: 1...10, step: 1)
                    .tint(AuraColor.gold)
            }
            TextField("Shopping habits", text: $draft.shoppingHabits)
                .textFieldStyle(.roundedBorder)
            TagSelector(title: "Style goals", options: goals, selected: Binding(get: { Set(draft.styleGoals) }, set: { draft.styleGoals = Array($0) }))
        }
        .luxuryCard()
    }

    private var styleInterestFields: some View {
        VStack(alignment: .leading, spacing: 18) {
            TagSelector(title: "Style interests", options: interests, selected: $draft.styleInterests)
            ShareCardPreview(title: "The Modern Muse", subtitle: "Quiet luxury, expressive polish, and camera-ready confidence.")
        }
    }

    private var safetyNote: some View {
        Text("AuraMirror AI offers supportive style coaching only. It does not diagnose skin conditions, rate attractiveness, recommend cosmetic procedures, or make health claims.")
            .font(.footnote)
            .foregroundStyle(AuraColor.ivory.opacity(0.58))
            .multilineTextAlignment(.center)
    }
}

struct DashboardView: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        ScreenScaffold(title: "AuraMirror AI", subtitle: "Your premium personal image intelligence studio.") {
            VStack(spacing: 18) {
                HStack {
                    MetricPanel(title: "Aura Score", value: "92", caption: "Style consistency")
                    MetricPanel(title: "Plan", value: viewModel.subscription.plan, caption: viewModel.subscription.isActive ? "Active" : "Preview")
                }
                if let aura = viewModel.auraDNA {
                    AuraDNACard(aura: aura)
                } else {
                    EmptyStateView(title: "Aura DNA pending", message: "Run a mock analysis to generate your identity profile.", systemImage: "sparkles")
                }
                QuickActionsGrid(viewModel: viewModel)
                if let outfit = viewModel.featuredOutfit {
                    OutfitCard(outfit: outfit)
                }
                ForEach(viewModel.insights) { insight in
                    StyleInsightCard(insight: insight)
                }
                UpgradeBanner()
            }
        }
        .navigationTitle("Dashboard")
    }
}

struct QuickActionsGrid: View {
    @Bindable var viewModel: AppViewModel

    private let actions: [(String, String, AppTab)] = [
        ("Analyze My Style", "camera.viewfinder", .auraDNA),
        ("Create Outfit", "tshirt", .stylist),
        ("Scan Wardrobe", "hanger", .wardrobe),
        ("Beauty Archetype", "sparkles.rectangle.stack", .auraDNA),
        ("Occasion Stylist", "calendar.badge.clock", .stylist),
        ("AI Stylist", "waveform", .stylist)
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(actions, id: \.0) { action in
                Button {
                    viewModel.selectedTab = action.2
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: action.1)
                            .font(.title3)
                        Text(action.0)
                            .font(.footnote.weight(.semibold))
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(AuraColor.ivory)
                    .frame(maxWidth: .infinity, minHeight: 84)
                    .background(AuraColor.gold.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

struct ScreenScaffold<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            LuxuryBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    EditorialTitle(eyebrow: "AuraMirror AI", title: title, subtitle: subtitle)
                    content
                }
                .padding(20)
            }
        }
    }
}

struct MetricPanel: View {
    let title: String
    let value: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundStyle(AuraColor.gold)
            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AuraColor.ivory)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(caption)
                .font(.caption)
                .foregroundStyle(AuraColor.ivory.opacity(0.62))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .luxuryCard()
    }
}

struct TagSelector: View {
    let title: String
    let options: [String]
    @Binding var selected: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AuraColor.ivory)
            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button {
                        if selected.contains(option) {
                            selected.remove(option)
                        } else {
                            selected.insert(option)
                        }
                    } label: {
                        Label(option, systemImage: selected.contains(option) ? "checkmark.circle.fill" : "circle")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                    }
                    .foregroundStyle(selected.contains(option) ? Color.black : AuraColor.ivory)
                    .background(selected.contains(option) ? AuraColor.gold : AuraColor.graphite, in: Capsule())
                }
            }
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(AuraColor.gold)
            Text(title)
                .font(.headline)
                .foregroundStyle(AuraColor.ivory)
            Text(message)
                .font(.callout)
                .foregroundStyle(AuraColor.ivory.opacity(0.68))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .luxuryCard()
    }
}
