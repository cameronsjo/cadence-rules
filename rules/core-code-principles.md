# Code Style

## Core Principles (the non-negotiables)

- **MUST** write code that reads like paragraphs with clear method/variable names. If your code needs a translator, that's a red flag
- **MUST** add type annotations to all code. Untyped code is like IKEA furniture without instructions - technically possible but why
- **MUST** explain WHY in comments: key decisions, optimizations, intellisense info. Future you will thank present you
- **MUST** use defensive programming: type check datetimes, validate inputs, fail fast. Trust issues are healthy here
- **MUST** isolate errors: per-row handling, explicit errors (no silent failures). If it breaks, we want receipts
- **MUST** follow SOLID + DRY + documentation-driven principles
- **MUST** use async/await over callbacks for asynchronous operations. Callback hell is not a place we vacation
- **MUST NOT** include legacy code, backwards compatibility shims, half-measures, magic strings, or magic numbers. Marie Kondo that codebase
- **MUST NOT** fail silently - always surface errors clearly. Speak now or forever debug in production
- **MUST** rename terrible naming when encountered. If you see it, you fix it. Be the change
- **SHOULD** Keep It Simple (KISS) - prefer straightforward over clever implementations. Nobody is impressed by your one-liner, Kevin
- **SHOULD** prefer functional over imperative, immutable over mutable
- **SHOULD** use positive names (enabled, visible, active) over negative (disabled, hidden, inactive). Good vibes only
- **SHOULD** enhance incrementally alongside existing architecture
- **SHOULD** follow industry standard structure: config at root, code in `src/`, docs in `docs/`, scripts in `scripts/`

## Code Markers (TODOs, FIXMEs)

TODOs without issue references are the Post-it notes of code. They yellow, they curl, nobody reads them.

- **MUST NOT** commit orphaned TODOs/FIXMEs without GitHub issue references
- **MUST** use format: `// TODO(#123): description`
- **Markers requiring issue references**: `TODO`, `FIXME`, `HACK`, `XXX`, `REFACTOR`, `BUG`, `OPTIMIZE`
- **Process**: Create GitHub issue FIRST, THEN add comment with reference
- **Enforcement**: `/ready` and `/pr.review` commands will BLOCK commits/PRs with violations

## Avoid Over-Engineering

We get it, you read Clean Code. But please:

- Don't add features, refactor code, or make "improvements" beyond what was asked
- A bug fix doesn't need surrounding code cleaned up
- A simple feature doesn't need extra configurability
- Don't add docstrings, comments, or type annotations to code you didn't change
- Only add comments where the logic isn't self-evident
- Don't add error handling or fallbacks for scenarios that can't happen
- Don't use feature flags or backwards-compatibility shims when you can just change the code
- Don't create helpers, utilities, or abstractions for one-time operations
- Don't design for hypothetical future requirements. YAGNI is not just an acronym, it's a lifestyle
- Three similar lines of code is better than a premature abstraction

## Backwards Compatibility

Avoid hacks like renaming unused `_vars`, re-exporting types, adding `// removed` comments. If something is unused, delete it completely. Let it go. Let it gooo.
