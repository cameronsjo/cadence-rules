---
notice: "Maintained by the rules plugin. Source: github.com/cameronsjo/rules"
paths:
  - "**/*.py"
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.go"
  - "**/*.rs"
  - "**/*.java"
  - "**/*.cs"
  - "**/*.sh"
  - "**/*.swift"
  - "**/Dockerfile*"
  - "**/Containerfile"
  - "**/Makefile"
  - "**/docker-compose*.yml"
  - "**/pyproject.toml"
  - "**/package.json"
  - "**/go.mod"
  - "**/Cargo.toml"
alwaysApply: false
---
# Engineering Standards

## Date and Time Handling

- **MUST** use UTC for all backend systems: databases, APIs, logs, internal processing
- **MUST** store timestamps in UTC (ISO 8601 format: `YYYY-MM-DDTHH:mm:ss.sssZ`)
- **MUST** perform timezone conversions only at presentation layer
- **MUST** include timezone information when displaying dates/times to users
- **SHOULD** use timezone-aware datetime types (not naive datetimes)
- **SHOULD** validate timezone identifiers using IANA timezone database (e.g., `America/New_York`, not `EST`)
- **SHOULD** use timezone aware displays for UI/Frontend

## Cost Boundaries

Validate before the cost boundary, not after.

### Compute Tiers

| Tier | Examples | Validation |
|---|---|---|
| Free | Local compute, Whisper on-device, local LLMs | None required |
| Cheap | Azure storage, small DB queries | Schema validation (non-empty, correct types) |
| Metered | LLM calls (Anthropic, OpenRouter) | Schema + payload quality (no empty arrays, no garbage inputs) |
| Expensive | Image generation (Gemini, DALL-E) | Schema + quality gate + human review for batch |

### Rules

- **MUST** validate payloads before crossing a cost boundary
- **MUST** fail fast on obviously invalid inputs -- check locally before making the network call
- **MUST** scale validation effort proportional to call cost
- **SHOULD** log the estimated cost tier when making paid API calls, so cost is visible in observability
- **SHOULD** implement dry-run modes for expensive operations (preview what would be sent without sending it)
- **MUST NOT** retry failed calls without diagnosing the input first

## Performance

- **MUST** profile code before optimizing
- **MUST** monitor bundle sizes
- **SHOULD** implement strategic caching and lazy loading

## Design Patterns

- **MUST** prioritize interoperability, async, reusability
- **MUST** design for reverse proxy deployment (configurable base paths, honor X-Forwarded-* headers)
- **SHOULD** use ULIDs over GUIDs/UUIDs unless external-facing
- **SHOULD** use factory/config patterns for swappable components
- **SHOULD** prefer dynamic discovery over hardcoded configs

## Environment Variables

- **MUST** use tool-prefixed names: `TOOLNAME_SETTING` (e.g., `MYAPP_DEBUG`)
- **MUST NOT** use generic names that could conflict (e.g., `DEBUG`, `DISABLE`)

## Terminology

- **MUST** use inclusive, neutral language throughout
- **MUST** use: allow/block/denylist, primary/secondary, main/replica, leader/follower, validation check, placeholder value, legacy status

## Tools

- **MUST** use Docker for containerization (Docker Desktop on Windows, Colima on macOS)
- **MUST** use uv for Python (not pip)
- **MUST** use pnpm for JS/TS (not npm/yarn)
- **MUST** use Biome for JS/TS linting and formatting (replaces ESLint + Prettier)
- **MUST** use mise for runtime version management (replaces nvm, pyenv, etc.)
- **MUST** include structured logging + OpenTelemetry from the start
- **SHOULD** use feature flags for rollouts/testing
- **SHOULD** use Husky for team repos

## Makefiles

- **MUST** include a `Makefile` with a default `help` target listing all targets with descriptions
- **MUST** use `.PHONY` for all non-file targets; keep targets thin (delegate to `scripts/`)

## New Projects

- **MUST** include: .gitignore, README, CONTRIBUTING, CHANGELOG, LICENSE, Makefile
- **MUST** configure linting/formatting + CI/CD from day 1

## Dependencies

- **MUST** search for latest stable versions
- **MUST** audit dependencies for: size, maintenance, security, active community
- **MUST NOT** use pre-release versions unless specified
- **SHOULD NOT** use dependencies >6 months old without review
- **SHOULD** consider simple in-house solutions before adding dependencies
