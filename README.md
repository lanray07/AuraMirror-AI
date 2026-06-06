# AuraMirror AI

AuraMirror AI is a premium SwiftUI iOS scaffold for a luxury beauty, fashion, grooming, wardrobe, and personal image coaching app.

Positioning: "The AI mirror that sees your best self."

The app is intentionally supportive and style-focused. It does not rate attractiveness, diagnose skin conditions, make health claims, recommend cosmetic procedures, or shame appearance.

## Build

Open `AuraMirrorAI.xcodeproj` in Xcode 15 or later and run the `AuraMirror AI` scheme on an iOS 17+ simulator or device.

## GitHub App Store Upload

The repository includes a manual GitHub Actions workflow at `.github/workflows/ios-app-store-upload.yml`.

Add these repository secrets in GitHub before running it:

- `APPLE_TEAM_ID` - your Apple Developer Team ID.
- `ASC_KEY_ID` - App Store Connect API key ID.
- `ASC_ISSUER_ID` - App Store Connect issuer ID.
- `ASC_PRIVATE_KEY` - full contents of the `AuthKey_XXXXXXXXXX.p8` private key.

Run **Actions > iOS App Store Upload > Run workflow**. The workflow archives the `AuraMirror AI` scheme, exports an App Store Connect IPA, uploads it to App Store Connect, and keeps the IPA as a GitHub Actions artifact.

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
