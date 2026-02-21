# Technical Standards

## Date and Time Handling

Timezones are the final boss of software engineering. Respect them.

- **MUST** use UTC for all backend systems: databases, APIs, logs, internal processing
- **MUST** store timestamps in UTC (ISO 8601 format: `YYYY-MM-DDTHH:mm:ss.sssZ`)
- **MUST** perform timezone conversions only at presentation layer. One job. At the end. That's it
- **MUST** include timezone information when displaying dates/times to users
- **SHOULD** use timezone-aware datetime types (not naive datetimes). Naive datetimes are the "it's fine" of temporal data
- **SHOULD** validate timezone identifiers using IANA timezone database (e.g., `America/New_York`, not `EST`)
- **SHOULD** use timezone aware displays for UI/Frontend

## Cost Boundaries

Every outbound call to a paid API crosses a cost boundary. Validate before the boundary, not after. Your machine's CPU is free. The API call is not.

### Compute Tiers

| Tier | Examples | Validation |
|---|---|---|
| Free | Local compute, Whisper on-device, local LLMs | None required |
| Cheap | Azure storage, small DB queries | Schema validation (non-empty, correct types) |
| Metered | LLM calls (Anthropic, OpenRouter) | Schema + payload quality (no empty arrays, no garbage inputs) |
| Expensive | Image generation (Gemini, DALL-E) | Schema + quality gate + human review for batch |

### Rules

- **MUST** validate payloads before crossing a cost boundary. Empty arrays, malformed inputs, and placeholder data are real money wasted
- **MUST** fail fast on obviously invalid inputs -- check locally before making the network call
- **MUST** scale validation effort proportional to call cost. A $0.001 LLM call gets a schema check. A $0.13 image gen gets a quality gate
- **SHOULD** log the estimated cost tier when making paid API calls, so cost is visible in observability
- **SHOULD** implement dry-run modes for expensive operations (preview what would be sent without sending it)
- **MUST NOT** retry failed calls without diagnosing the input first. Retrying garbage is paying twice for nothing

### Pre-Flight Check Pattern

```python
def preflight(payload, cost_tier: str) -> bool:
    """Validate before crossing a cost boundary."""
    # All tiers: structural validity
    if not payload or payload == [] or payload == {}:
        raise ValueError("Empty payload -- refusing to send to paid API")

    # Metered+: content quality
    if cost_tier in ("metered", "expensive"):
        if isinstance(payload, str) and len(payload.split()) < 10:
            raise ValueError(f"Payload too short ({len(payload.split())} words) for {cost_tier} API")

    # Expensive: quality gate
    if cost_tier == "expensive":
        # Domain-specific quality checks here
        pass

    return True
```

## Performance

- **MUST** profile code before optimizing. Measure twice, refactor once
- **MUST** monitor bundle sizes
- **SHOULD** implement strategic caching and lazy loading. Work smarter, not harder. We're tired

## Design Patterns

- **MUST** prioritize interoperability, async, reusability
- **MUST** design for reverse proxy deployment (configurable base paths, honor X-Forwarded-* headers)
- **SHOULD** use ULIDs over GUIDs/UUIDs unless external-facing
- **SHOULD** use factory/config patterns for swappable components
- **SHOULD** prefer dynamic discovery over hardcoded configs

## Container & Self-Hosted Standards

Because we self-host things. It's our love language.

### Required

- **MUST** expose `/health` endpoint for orchestrator/load balancer health checks
- **MUST** handle SIGTERM gracefully (drain connections, finish in-flight requests). Die with dignity
- **MUST** log to stdout (not files)
- **SHOULD** use structured JSON logging
- **MUST** accept configuration via environment variables
- **MUST** run as non-root user in containers. Root in containers is the "running with scissors" of DevOps
- **MUST** honor `X-Forwarded-*` headers when behind reverse proxy

### Recommended

- **SHOULD** expose `/ready` endpoint if startup is slow or has async initialization
- **SHOULD** support OIDC for user-facing authentication
- **SHOULD** support OpenTelemetry trace context propagation
- **SHOULD** propagate correlation IDs across service boundaries
- **SHOULD** expose Prometheus metrics at `/metrics`
- **SHOULD** use versioned image tags (avoid `:latest`). `:latest` is a lie and we all know it

### Container Image Standards

#### OCI Labels

Label your containers. It's like labeling your Tupperware. Future you will be grateful.

- **MUST** include `org.opencontainers.image.source` label linking to repository
- **MUST** include `org.opencontainers.image.description` with brief description
- **SHOULD** include `org.opencontainers.image.licenses` with SPDX identifier
- **SHOULD** include `org.opencontainers.image.version` from build args
- **SHOULD** include `org.opencontainers.image.revision` (git commit SHA)
- **SHOULD** include `org.opencontainers.image.created` (build timestamp)

#### Supply Chain Security

Trust nobody. Verify everything. This is not paranoia, this is engineering.

- **MUST** sign container images with Cosign (keyless OIDC preferred for CI/CD)
- **MUST** generate SLSA build provenance attestations
- **SHOULD** use `actions/attest-build-provenance` for GitHub Actions workflows
- **SHOULD** publish to GHCR for GitHub-hosted projects (native attestation support)
- **SHOULD** document verification commands in README

#### GitHub Actions Workflow Requirements

```yaml
permissions:
  contents: read
  packages: write
  id-token: write      # Required for keyless Cosign signing
  attestations: write  # Required for provenance attestation
```

#### Registry Selection

| Use Case | Recommendation |
|----------|----------------|
| GitHub-hosted OSS | GHCR (native integration, free, attestations) |
| Broad distribution | Docker Hub (default registry, official images) |
| Private/enterprise | GHCR, ECR, GCR, or private registry |

## Environment Variables

- **MUST** use tool-prefixed names for application-specific environment variables
- **Pattern**: `TOOLNAME_SETTING` (e.g., `MYAPP_DEBUG`, `MYAPP_DISABLE`)
- **MUST NOT** use generic names that could conflict (e.g., `DEBUG`, `DISABLE`). Namespace your stuff. We live in a society

## Terminology

Words matter. Use good ones.

- **MUST** be accurate, neutral, inclusive while preserving technical clarity
- **MUST** use: allow/block/denylist over whitelist/blacklist
- **MUST** use: primary/secondary, main/replica, leader/follower over master/slave
- **MUST** use: validation check, confidence check, smoke test over sanity check
- **MUST** use: placeholder value, sample value, test value over dummy value
- **MUST** use: legacy status, exempted, inherited over grandfathered
- **SHOULD NOT** use "master" in technical contexts (use main, primary, leader, parent, source)

## Tools

- **MUST** use Docker for containerization (Docker Desktop on Windows, Colima on macOS)
- **MUST** use uv for Python (not pip)
- **MUST** use pnpm for JS/TS (not npm/yarn)
- **MUST** use Biome for JS/TS linting and formatting (replaces ESLint + Prettier)
- **MUST** use mise for runtime version management (replaces nvm, pyenv, etc.)
- **MUST** include structured logging + OpenTelemetry early. Not after the incident. Before
- **SHOULD** use feature flags for rollouts/testing
- **SHOULD** use Husky for team repos

## Makefiles

Every project gets a Makefile. It's the universal task runner — no install, no config, tab-complete out of the box.

- **MUST** include a `Makefile` as the project's task runner entry point
- **MUST** include inline comments above each target explaining what it does
- **MUST** include a `help` target as the default that lists available targets with descriptions
- **MUST** use `.PHONY` for all non-file targets
- **SHOULD** group related targets with comment headers (e.g., `## Development`, `## Testing`, `## Release`)
- **SHOULD** use variables for tool paths and flags at the top of the file
- **SHOULD** keep targets thin — delegate to scripts in `scripts/` for anything complex

## New Projects

Every new project gets the full treatment. No excuses. No "I'll add it later."

- **MUST** include: .gitignore, README, CONTRIBUTING, CHANGELOG, LICENSE, Makefile
- **MUST** configure linting/formatting + CI/CD from day 1

## Dependencies

Choose your dependencies like you choose your brunch spot. Carefully.

- **MUST** search for latest stable versions
- **MUST** audit dependencies for: size, maintenance, security, active community
- **MUST NOT** use pre-release versions unless specified
- **SHOULD NOT** use dependencies >6 months old without review. If it hasn't been updated since your last haircut, be suspicious
- **SHOULD** consider simple in-house solutions before adding dependencies
