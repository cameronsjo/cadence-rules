---
paths:
  - ".github/workflows/**/*"
  - ".gitlab-ci.yml"
  - "**/Jenkinsfile"
  - "**/.gitlab-ci.yml"
  - "**/azure-pipelines.yml"
---

# CI/CD Standards

- **GitHub Actions**: Preferred for GitHub repos
- **Authentication**: OIDC (keyless) over stored secrets
- **Dependency Updates**: Dependabot or Renovate
- **Security Scanning**: CodeQL, Trivy, or Snyk
- **Secrets Management**: OIDC to cloud providers (AWS, GCP, Azure)

## Core Requirements

- **MUST** use OIDC for cloud authentication (no long-lived credentials)
- **MUST** pin actions to full commit SHA (not @main or @v1)
- **MUST** set minimal GITHUB_TOKEN permissions (least privilege)
- **MUST** use reusable workflows for common patterns
- **MUST** sanitize user input to prevent injection attacks
- **MUST NOT** use `secrets: inherit` in reusable workflows
- **MUST NOT** use `pull_request_target` without careful review
- **SHOULD** use concurrency to prevent duplicate runs
- **SHOULD** cache dependencies to speed up builds

## GitHub Actions Security

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

# Global minimal permissions
permissions:
  contents: read

# Prevent duplicate runs
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write      # Only if needed
      id-token: write      # For OIDC

    steps:
      # Pin to full SHA, not tag
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      # Use OIDC for cloud auth
      - uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502 # v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-actions
          aws-region: us-east-1
```

## Reusable Workflows

```yaml
# .github/workflows/reusable-build.yml
name: Reusable Build

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
    secrets:
      # Explicitly declare secrets - don't use inherit
      DEPLOY_KEY:
        required: true

jobs:
  build:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      # Build steps...
```

```yaml
# Usage in another workflow
jobs:
  deploy:
    uses: ./.github/workflows/reusable-build.yml
    with:
      environment: production
    secrets:
      DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```

## Caching

```yaml
# Node.js
- uses: actions/setup-node@39370e3970a6d050c480ffad4ff0ed4d3fdee5af # v4
  with:
    node-version: 22
    cache: npm

# Python with uv
- uses: astral-sh/setup-uv@6b9c6063abd6010835644d4c2e1bef4cf5cd0fca # v6
  with:
    enable-cache: true

# Go
- uses: actions/setup-go@d35c59abb061a4a6fb18e82ac0862c26744d6ab5 # v5
  with:
    go-version: '1.24'
    cache: true

# Docker layers
- uses: docker/build-push-action@48aba3b46d1b1fec4febb7c5d0c644b249420e46 # v6
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

## Injection Prevention

```yaml
# ❌ DANGEROUS - Command injection via PR title
- run: echo "PR: ${{ github.event.pull_request.title }}"

# ✅ SAFE - Use environment variable
- run: echo "PR: $TITLE"
  env:
    TITLE: ${{ github.event.pull_request.title }}

# ✅ SAFE - Use intermediate file
- run: |
    cat << 'EOF' > message.txt
    ${{ github.event.pull_request.body }}
    EOF
    process_safely message.txt
```

## Workflow Naming

```
.github/workflows/
├── ci.yml                    # Main CI pipeline
├── release.yml               # Release automation
├── deploy-*.yml              # Deployment workflows
├── reusable-*.yml            # Reusable workflows
├── scheduled-*.yml           # Cron jobs
└── manual-*.yml              # workflow_dispatch
```

## GitLab CI

```yaml
# .gitlab-ci.yml
default:
  image: node:22-alpine

variables:
  # Reduce clone depth for speed
  GIT_DEPTH: 10

stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - npm ci --cache .npm
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - .npm/
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

# Use rules instead of only/except
deploy:
  stage: deploy
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  environment:
    name: production
```

## Anti-patterns

- ❌ `@main` or `@v1` for actions - use full SHA
- ❌ `secrets: inherit` - explicitly pass needed secrets
- ❌ Long-lived credentials - use OIDC
- ❌ Storing secrets in env vars when OIDC available
- ❌ `pull_request_target` with checkout of PR code
- ❌ Interpolating user input directly in `run:`
- ❌ Overly permissive GITHUB_TOKEN (use read-only default)
