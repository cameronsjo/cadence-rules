<!-- managed by rules — changes will be overwritten by /rules:init-project -->
---
paths:
  - "**/Dockerfile"
  - "**/Dockerfile.*"
  - "**/Containerfile"
  - "**/*.dockerfile"
  - "**/.dockerignore"
---

# Dockerfile Standards

- **Builder**: BuildKit (default since Docker 23.0)
- **CLI**: docker buildx
- **Base Images**: Distroless, Alpine, or scratch for minimal attack surface
- **Scanning**: Trivy, Docker Scout, or Grype for vulnerability scanning
- **Signing**: Cosign (keyless OIDC preferred)
- **Provenance**: SLSA Build Level 3 attestations
- **Registry**: GHCR (native attestation support) or ECR/GCR

## Core Requirements

- **MUST** use multi-stage builds to minimize final image size
- **MUST** run as non-root user (use `USER` instruction)
- **MUST** use specific version tags (never `latest` in production)
- **MUST** include `.dockerignore` to exclude .git, node_modules, .env, secrets
- **MUST** order instructions by change frequency (rarely-changed first)
- **MUST** include OCI labels (`source`, `description` required; `licenses`, `version`, `revision`, `created` recommended)
- **MUST** use `uv` for Python images (not pip)
- **MUST NOT** store secrets in images - use build args, env vars, or secrets mounts
- **SHOULD** use BuildKit cache mounts for package managers (`--mount=type=cache`)
- **SHOULD** use distroless or scratch base images when possible
- **SHOULD** sign images with Cosign and generate SLSA provenance
- **SHOULD** use zstd compression for faster push/pull
- **SHOULD** use tini or dumb-init for signal handling (or distroless which handles this)

## Multi-Stage Build Template

```dockerfile
# syntax=docker/dockerfile:1
FROM node:22-alpine AS builder

WORKDIR /app

# Dependencies first (cached unless package*.json changes)
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

# Then application code
COPY . .
RUN npm run build

# Minimal runtime image
FROM gcr.io/distroless/nodejs22-debian12

LABEL org.opencontainers.image.source="https://github.com/org/repo"
LABEL org.opencontainers.image.description="Service description"
LABEL org.opencontainers.image.licenses="MIT"

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

USER nonroot

EXPOSE 3000
CMD ["dist/server.js"]
```

## Security

- **MUST** create and use non-root user (`addgroup`/`adduser` or distroless `nonroot`)
- **MUST** use `--mount=type=secret` for build-time secrets (never `ARG` for secrets)
- **SHOULD** run with `--read-only --tmpfs /tmp` at runtime
- **SHOULD** include `HEALTHCHECK` instruction

## Anti-patterns

- **MUST NOT** use `FROM image:latest` (mutable tag)
- **MUST NOT** separate `apt-get update` from `apt-get install` (cache issues)
- **MUST NOT** use `ADD` for remote URLs (use `curl` + `RUN` instead)
- **MUST NOT** `COPY . .` before dependencies (breaks layer caching)
- **MUST NOT** put secrets in `ENV` instructions

## .dockerignore Template

```
.git
.gitignore
.env*
*.md
!README.md
Dockerfile*
docker-compose*
.dockerignore
node_modules
__pycache__
*.pyc
.pytest_cache
.coverage
.venv
target/
dist/
build/
*.log
.DS_Store
```
