---
paths:
  - "**/*.swift"
  - "**/Package.swift"
  - "**/project.yml"
---

# Swift Standards

- **Language**: Swift 6.2+ (strict concurrency by default, typed throws, noncopyable types)
- **SwiftPM**: swift-tools-version 6.2, explicit platform declarations
- **Linting**: SwiftLint or swift-format
- **Testing**: Swift Testing (`import Testing`, `#expect`, `#require`) for unit/integration; XCTest for UI automation
- **Observability**: os.Logger (unified logging system)
- **UI**: SwiftUI (prefer over AppKit/UIKit for new views)

## Core Requirements

- **MUST** enable strict concurrency (`swift-tools-version: 6.2` or `-strict-concurrency=complete`)
- **MUST** use `@MainActor` on ObservableObject classes that publish to SwiftUI views
- **MUST** use `async/await` over completion handlers for new code
- **MUST** use `guard` for early returns — keep the happy path left-aligned
- **MUST** use `let` over `var` wherever possible
- **MUST** use access control explicitly (`private`, `public`) — omit `internal` (it's the default)
- **MUST** handle all errors — never ignore with `_ = try?` without justification
- **MUST** use `os.Logger` for structured logging (not `print()`)
- **MUST NOT** use force unwraps (`!`) in production code — use `guard let` or `if let`
- **MUST NOT** use `Any` or `AnyObject` without justification
- **MUST NOT** use `@objc` unless required for Objective-C interop or selectors
- **SHOULD** use value types (structs, enums) over reference types (classes) unless identity semantics are needed
- **SHOULD** use `Sendable` conformance for types crossing actor boundaries
- **SHOULD** prefer `nonisolated` functions for work that doesn't need actor isolation
- **SHOULD** use extensions with `// MARK: -` to organize code by protocol conformance

## Naming

- `UpperCamelCase` — types, protocols, enums
- `lowerCamelCase` — properties, methods, variables, enum cases
- No abbreviations except universal (`URL`, `ID`, `UUID`)
- Clarity at the call site — parameter labels should read naturally

```swift
// Preferred
func fetchUser(byID id: String) -> User
let maximumRetryCount = 3
enum ConnectionState { case connected, disconnected, reconnecting }

// Avoid
func fetchUser(_ s: String) -> User
let maxRetry = 3
```

## Concurrency (Swift 6.2)

- **MUST** use `Task { }` over `DispatchQueue.main.asyncAfter` for delayed work
- **MUST** use structured concurrency (task groups, async let) over unstructured `Task.detached`
- **MUST** mark `@MainActor` only on classes that genuinely need main-thread access (UI state, AppKit)
- **MUST** use `nonisolated` for methods that do I/O or background work on `@MainActor` classes
- **MUST** use `@concurrent` to explicitly offload async work off the caller's executor (SE-0461; replaces `Task.detached`)
- **SHOULD** use `nonisolated(nonsending)` to keep async work on the caller's executor when offloading is not desired (SE-0461; opposite semantics from `@concurrent`)
- **MUST** map non-Sendable types (EKEvent, EKReminder) to Sendable value types inside callbacks before crossing actor boundaries
- **MUST NOT** use `@preconcurrency` or `@unchecked Sendable` without a documented safety invariant and follow-up ticket
- **MUST NOT** use `DispatchQueue.main.async` in `@MainActor` contexts — you're already on main
- **MUST NOT** use `DispatchSemaphore.wait()` in async context — deadlocks the cooperative thread pool
- **SHOULD** enable `defaultIsolation(MainActor.self)` for app targets (not libraries)
- **SHOULD** use `[weak self]` in Task closures for long-lived operations
- **SHOULD** check `Task.isCancelled` in loops and after sleep
- **SHOULD** use `some Protocol` over `any Protocol` in hot paths (avoids heap allocation)

```swift
// Preferred: nonisolated async for I/O work on @MainActor class
@MainActor
final class NotificationServer: ObservableObject {
    private nonisolated func handleConnection(_ conn: NWConnection) async {
        let data = await readData(from: conn)
        await MainActor.run { self.push(notification) }
    }
}

// Preferred: Task.sleep over DispatchQueue
Task {
    try? await Task.sleep(for: .seconds(1))
    guard !Task.isCancelled else { return }
    doWork()
}
```

## SwiftUI

- **MUST** use `@Observable` (iOS 17+/macOS 14+) over `ObservableObject` for new code
- **MUST** keep `body` pure — no side effects, no object allocation, no heavy computation
- **MUST** use stable identity for `ForEach` (never `.indices` for dynamic content)
- **MUST** apply `.glassEffect()` after layout and visual modifiers (macOS 26)
- **MUST** use `.interactive()` on glass effects for tappable elements
- **SHOULD** extract complex views into separate subviews (improves diffing performance)
- **SHOULD** use static properties for formatters, navigation items, and other per-render allocations
- **SHOULD** use `GlassEffectContainer` when multiple glass elements coexist
- **SHOULD** avoid `GeometryReader` unless the geometry value is actually used
- **SHOULD** precompute filtered/sorted collections — don't filter inside `ForEach`

```swift
// Preferred: static formatter, not allocated per render
private static let timeFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "h:mm a"
    return f
}()

// Preferred: glass button with interactive
Button { action() } label: {
    Image(systemName: "gear")
        .frame(width: 24, height: 24)
        .glassEffect(.regular.interactive(), in: Circle())
}
```

## macOS-Specific

- **MUST** use `NSApplication.shared.setActivationPolicy(.accessory)` for menu bar / overlay apps
- **MUST** codesign `.app` bundles for TCC permission persistence (`codesign --force --deep --sign -`)
- **MUST** use `UserDefaults` or file-based storage for dev; Keychain for production secrets
- **SHOULD** use Carbon `RegisterEventHotKey` for global hotkeys (no accessibility permissions needed)
- **SHOULD** use `NSPanel` with `.nonactivatingPanel` for overlay windows
- **SHOULD** use `NSHostingView` for SwiftUI content in AppKit windows
- **SHOULD** handle `SIGTERM` gracefully in LaunchAgent services

## Error Handling

- **MUST** use typed throws (Swift 6) for domain errors where callers need to match
- **MUST** wrap errors with context: `throw ServiceError.fetchFailed(underlying: error)`
- **SHOULD** use enum-based error types conforming to `Error` and `LocalizedError`
- **SHOULD** use `Result` for synchronous operations that can fail

```swift
enum CalendarError: Error, LocalizedError {
    case accessDenied
    case fetchFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .accessDenied: "Calendar access denied"
        case .fetchFailed(let e): "Failed to fetch events: \(e.localizedDescription)"
        }
    }
}
```

## Logging

- **MUST** use `os.Logger` with subsystem and category
- **MUST** use structured parameters: `log.info("Fetching events. Count: \(count)")`
- **MUST** use appropriate levels: `.debug` (routine), `.info` (lifecycle), `.warning` (degraded), `.error` (failure)
- **MUST NOT** use `print()` or `NSLog()` in production
- **SHOULD** use `nonisolated let log` on `@MainActor` classes so logging works from any context

```swift
private nonisolated let log = Logger(subsystem: "com.app.name", category: "service-name")
```

## Project Structure

```
Package.swift               # SwiftPM manifest
Sources/
  AppName/
    App/                    # @main, AppDelegate, WindowManager
    Core/                   # ViewModels, EventMonitors, Settings
    Services/               # API clients, data services
    UI/
      Views/                # SwiftUI views
      Components/           # Reusable UI components
      Theme/                # Design tokens, colors, fonts
      Window/               # NSPanel, NSWindow controllers
    Utilities/              # Extensions, helpers
    Intents/                # AppIntents (Siri Shortcuts)
    Models/                 # Data types, API response models
```

## Anti-Patterns

```swift
// ❌ Force unwrap in production
let user = users.first!

// ❌ Mutable singleton state without actor isolation
class Cache { static var shared = Cache(); var items: [String] = [] }

// ❌ DispatchQueue for delays in async context
DispatchQueue.main.asyncAfter(deadline: .now() + 1) { ... }

// ❌ print() for logging
print("fetched \(count) items")

// ❌ Object allocation in view body
var body: some View {
    let formatter = DateFormatter() // allocates every render
    Text(formatter.string(from: date))
}

// ❌ GeometryReader with unused parameter
GeometryReader { _ in content }

// ✅ Preferred alternatives shown in sections above
```

## Testing

- **MUST** use Swift Testing (`import Testing`) for new test files
- **MUST** use `#expect` as default assertion, `#require` when subsequent lines depend on a value
- **MUST** default to parallel-safe tests — fix shared state before using `.serialized`
- **SHOULD** use parameterized tests (`@Test(arguments:)`) over repeated test methods
- **SHOULD** use traits (`.enabled`, `.disabled`, `.timeLimit`, `.bug`, tags) over naming conventions
