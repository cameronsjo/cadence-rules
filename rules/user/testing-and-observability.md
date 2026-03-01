---
notice: "Maintained by the rules plugin. Source: github.com/cameronsjo/rules"
---
# Testing and Observability

- **MUST** test behavior, not implementation
- **MUST** catch real bugs, not just increase coverage
- **MUST** test happy path before optimization
- **SHOULD** prefer integration tests over unit tests
- **SHOULD** build systematic debugging tools rather than relying on manual testing

## Observability

- **MUST** implement structured logging in applications, programs, and APIs
- **MUST** implement OpenTelemetry tracing in applications, programs, and APIs
- **MAY** omit observability in simple scripts or utilities where it adds no value

### Log Message Style

- **MUST** write action-oriented log messages that describe intent, outcome, and relevant state
- **MUST** use structured parameters for state: `"Attempting {Action}. State: {State1}, State2: {State2}"`
- **MUST** include context when logging errors: `"Encountered {Error} while {Action}. {RelevantState}"`
- **MUST** confirm success with outcome: `"Successfully completed {Action}. {ResultState}"`
- **SHOULD** be concise but include identifying state: `"File found. Path: {FilePath}"`, `"Connection established. Host: {Host}"`
- **SHOULD** explain reasoning for actions: `"File missing, attempting database update. Path: {FilePath}, PostId: {PostId}"`
- **SHOULD NOT** log without context - always answer "what happened?" and "why does it matter?"

**Design principle**: Message templates serve dual purposes - searchable plaintext patterns AND structured property bags. The template text (before interpolation) provides a stable hash for log aggregation tools (Splunk, Seq, etc.), while parameters populate `Properties`/`Extra` fields with trace IDs, span IDs, and queryable values.
