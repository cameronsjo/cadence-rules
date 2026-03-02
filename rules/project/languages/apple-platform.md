---
paths:
  - "**/*.xcodeproj/**"
  - "**/*.xcworkspace/**"
  - "**/Info.plist"
  - "**/*.entitlements"
  - "**/project.yml"
  - "**/*.xcconfig"
  - "**/*.xctestplan"
---

# Apple Platform Standards

## Build Configuration

- **MUST** use `.xcconfig` files for build settings (not Xcode GUI) — diffs cleanly in git
- **MUST** separate signing config from build config (signing xcconfig in `.gitignore`)
- **MUST** share schemes (tick "Shared" in scheme editor) for CI reproducibility
- **MUST** commit `Package.resolved` for apps (not for libraries)
- **SHOULD** use SwiftPM over CocoaPods (CocoaPods Trunk goes read-only Dec 2026)

## Info.plist & Privacy

- **MUST** include `NS*UsageDescription` for every TCC-protected resource
- **MUST** use concrete, user-facing language (not generic "this app needs access")
- **MUST NOT** leave usage descriptions empty — App Store rejection

| Resource | Key |
|----------|-----|
| Calendar | `NSCalendarsUsageDescription` |
| Reminders | `NSRemindersUsageDescription` |
| Camera | `NSCameraUsageDescription` |
| Microphone | `NSMicrophoneUsageDescription` |
| Contacts | `NSContactsUsageDescription` |
| Location | `NSLocationWhenInUseUsageDescription` |
| Accessibility | `NSAccessibilityUsageDescription` |

## Code Signing

- **MUST** use ad-hoc (`-`) signing for local dev only
- **MUST** use Developer ID + hardened runtime + notarization for distribution
- **MUST** use `notarytool` (not deprecated `altool`) for notarization
- **MUST NOT** set `com.apple.security.get-task-allow` in release builds
- **MUST NOT** use `codesign --deep` (deprecated since macOS 13)
- **SHOULD** sign from inside out (helpers/frameworks first, outer .app last)

```bash
# Dev signing (ad-hoc)
codesign --force --sign - MyApp.app

# Distribution signing
codesign --force --options runtime --timestamp \
  --entitlements App.entitlements \
  --sign "Developer ID Application: Company (TEAMID)" MyApp.app
```

## App Lifecycle

- **MUST** use SwiftUI `App` protocol for new apps
- **MUST** use `@NSApplicationDelegateAdaptor` for AppKit callbacks (push tokens, deep links)
- **MUST** use `scenePhase` for lifecycle events (not `applicationDidBecomeActive`)
- **SHOULD** place app-level `@State` models in the `App` struct (not in views)
- **SHOULD** use `.accessory` activation policy for menu bar / overlay apps

```swift
@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup { ContentView().environment(appState) }
    }
}
```

## macOS Window Types

| Type | Use Case |
|------|----------|
| `WindowGroup` | Standard windows |
| `Settings` | Preferences (broken for SwiftPM — use NSWindow + NSHostingView) |
| `MenuBarExtra` | Menu bar items (macOS 13+) |
| `NSPanel` | Overlay, HUD, floating panels |

## Accessibility

- **MUST** use `.accessibilityLabel()` on custom controls and icons
- **MUST** respect `@Environment(\.accessibilityReduceMotion)` for animations
- **SHOULD** use `.accessibilityElement(children: .combine)` for grouped elements
- **SHOULD** use `@ScaledMetric` for measurements that should scale with Dynamic Type
- **SHOULD** test with VoiceOver and Accessibility Inspector

## Localization

- **MUST** use `.xcstrings` String Catalogs for new projects (not `.strings`)
- **MUST** use Foundation formatters for dates, numbers, measurements
- **MUST NOT** hardcode locale-sensitive formatting (date formats, number separators)
- **SHOULD** organize string catalogs by feature (one `.xcstrings` per module)

## Distribution Checklist

```
[ ] Hardened runtime enabled
[ ] All entitlements declared
[ ] Info.plist privacy descriptions present
[ ] Signed with Developer ID (not ad-hoc)
[ ] Notarized via notarytool
[ ] Stapled ticket to DMG/app
[ ] Sparkle EdDSA keys generated (if auto-update)
[ ] appcast.xml published (if Sparkle)
```

## Objective-C Interop

- **MUST** use `NS_ASSUME_NONNULL_BEGIN/END` on all Objective-C headers
- **MUST** use `NS_SWIFT_NAME` to rename APIs for natural Swift call sites
- **SHOULD** use `@objc @implementation extension` (SE-0436) for incremental migration
- **SHOULD** prefer `NS_REFINED_FOR_SWIFT` + Swift overlay over direct bridging for complex APIs
