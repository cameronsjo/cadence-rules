# Core Code Principles

- **MUST** write code that reads like paragraphs with clear method/variable names
- **MUST** add type annotations to all code
- **MUST** explain WHY in comments: key decisions, optimizations, intellisense info
- **MUST** use defensive programming: type check datetimes, validate inputs, fail fast
- **MUST** isolate errors: per-row handling, explicit errors (no silent failures)
- **MUST** follow SOLID + DRY + documentation-driven principles
- **MUST** use async/await over callbacks for asynchronous operations
- **MUST NOT** include legacy code, backwards compatibility shims, half-measures, magic strings, or magic numbers
- **MUST NOT** fail silently - always surface errors clearly
- **MUST** rename terrible naming when encountered
- **SHOULD** Keep It Simple (KISS) - prefer straightforward over clever implementations
- **SHOULD** prefer functional over imperative, immutable over mutable
- **SHOULD** use positive names (enabled, visible, active) over negative (disabled, hidden, inactive)
- **SHOULD** enhance incrementally alongside existing architecture
- **SHOULD** follow industry standard structure: config at root, code in `src/`, docs in `docs/`, scripts in `scripts/`

## Code Markers (TODOs, FIXMEs)

- **MUST NOT** commit orphaned TODOs/FIXMEs without GitHub issue references
- **MUST** use format: `// TODO(#123): description`
- **Markers requiring issue references**: `TODO`, `FIXME`, `HACK`, `XXX`, `REFACTOR`, `BUG`, `OPTIMIZE`
- **Process**: Create GitHub issue FIRST, THEN add comment with reference
- **Enforcement**: `/ready` and `/pr.review` commands will BLOCK commits/PRs with violations

## Avoid Over-Engineering

- **MUST NOT** add features, refactor code, or make "improvements" beyond what was asked
- **MUST NOT** add docstrings, comments, or type annotations to code you didn't change
- **MUST NOT** add error handling or fallbacks for scenarios that can't happen
- **MUST NOT** create helpers, utilities, or abstractions for one-time operations
- **SHOULD** only add comments where the logic isn't self-evident
- **SHOULD** prefer three similar lines over a premature abstraction (YAGNI)

## Backwards Compatibility

Avoid hacks like renaming unused `_vars`, re-exporting types, adding `// removed` comments. If something is unused, delete it completely.
