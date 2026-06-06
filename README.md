# AuraMirror AI

AuraMirror AI is a premium SwiftUI iOS scaffold for a luxury beauty, fashion, grooming, wardrobe, and personal image coaching app.

Positioning: "The AI mirror that sees your best self."

The app is intentionally supportive and style-focused. It does not rate attractiveness, diagnose skin conditions, make health claims, recommend cosmetic procedures, or shame appearance.

## Build

Open `AuraMirrorAI.xcodeproj` in Xcode 15 or later and run the `AuraMirror AI` scheme on an iOS 17+ simulator or device.

Mock AI is enabled by default through `MockAIService`. `RemoteAIService` is scaffolded against:

```http
POST https://YOUR_BACKEND_URL.com/auramirror-ai
```

## Included

- SwiftUI `NavigationStack` and tab shell
- MVVM-style `AppViewModel`
- SwiftData models
- StoreKit 2 subscription scaffolding
- AI image analysis, wardrobe scanner, shopping intelligence, and remote backend placeholders
- Speech-to-text and voice stylist architecture
- Swift Charts analytics
- Native PDF export and share sheet support
- WidgetKit and Apple Watch placeholder architecture
- Luxury editorial UI components and mock data
