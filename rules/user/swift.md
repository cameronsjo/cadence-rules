---
notice: "Maintained by the cadence-rules plugin. Source: github.com/cameronsjo/cadence-rules"
---
# Swift & SwiftUI

## Safety

- **MUST NOT** use `!` force unwraps on failable initializers (`URL`, `URLComponents`, `DateFormatter`, etc.) — use `guard let` or `if let`
- **MUST** iterate `IndexSet` in reverse order (`sorted(by: >)`) when removing items from an array by index to prevent index corruption

## SwiftUI

- **MUST NOT** use `.constant()` bindings for values that need to change (e.g., alert `isPresented`) — use `Binding(get:set:)` instead
- **MUST** implement custom `Hashable`/`Equatable` based on stable identity (`id`) when a model is used with `NavigationLink(value:)` or `NavigationStack(path:)` — auto-synthesized Hashable includes mutable fields like timestamps
- **SHOULD** use `.numberPad` for integer fields and `.decimalPad` for decimal fields

## Observation & Concurrency

- **SHOULD** use `@State` with `@Observable` classes (modern pattern)
- **MUST NOT** use `@StateObject` (Combine-era) with `@Observable` classes
- **MUST** mark ViewModels as `@MainActor @Observable final class`
- **MUST** use `await` for all actor-crossing calls

## Logging

- **MUST** use `os.Logger` for logging (not `print()`)
- **SHOULD** use privacy annotations (`.public` for non-sensitive data, default redaction for PII)

## Build Scripts

- **MUST** use `set -o pipefail` when piping build/test output through `tail` or `grep` in Makefiles/scripts to preserve exit codes
