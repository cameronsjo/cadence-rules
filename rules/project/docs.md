<!-- managed by rules — changes will be overwritten by /rules:init-project -->
---
paths:
  - "docs/**/*.md"
  - "**/docs/**/*.md"
  - "**/*.mdx"
---

# Documentation Standards

- **Format**: Markdown or MDX (for interactive docs)
- **Static Site**: MkDocs, Docusaurus, or Astro
- **Linting**: Vale (prose style), markdownlint (formatting)
- **Link Checking**: lychee or markdown-link-check in CI
- **API Docs**: Redocly, Stoplight, or Swagger
- **Spell Check**: cspell or typos

## Core Requirements (Docs-as-Code)

- **MUST** store docs in same repo as code (evolve together)
- **MUST** use Git workflow with PR reviews for doc changes
- **MUST** automate doc builds via CI/CD
- **MUST** run linting and link checks in CI
- **MUST** use consistent terminology throughout docs
- **MUST NOT** let docs drift from code - update together
- **SHOULD** create contribution guide for doc writers
- **SHOULD** use style guide for tone and formatting

## Structure

```
docs/
├── index.md              # Landing page
├── getting-started/      # Onboarding
│   ├── installation.md
│   ├── quickstart.md
│   └── configuration.md
├── guides/               # How-to guides
│   └── *.md
├── reference/            # API/CLI reference
│   └── *.md
├── architecture/         # System design
│   ├── overview.md
│   └── adr/             # Architecture Decision Records
│       └── 0001-*.md
├── contributing.md       # How to contribute
└── changelog.md          # Version history
```

## Writing Style

- **MUST** write for the reader, not the writer
- **MUST** use active voice and present tense
- **MUST** be concise - remove unnecessary words
- **MUST** include code examples for technical concepts
- **MUST** use numbered steps for procedures
- **SHOULD** start with "why" before "how"
- **SHOULD** include expected outcomes for procedures
- **SHOULD** provide copy-pasteable commands

## Document Template

```markdown
# Page Title

Brief description of what this page covers and why it matters.

## Prerequisites

- Requirement 1
- Requirement 2

## Steps

1. First step with expected outcome
   ```bash
   command --example
   ```

2. Second step explaining what happens

## Next Steps

- Link to related topic
- Link to advanced usage
```

## Code Examples

```markdown
<!-- Good: Complete, runnable example -->
```python
from mylib import Client

client = Client(api_key="your-key")
result = client.fetch("example")
print(result.data)
```

<!-- Bad: Incomplete snippet -->
```python
client.fetch("example")
```
```

## Formatting Conventions

- **MUST** use ATX-style headers (`#` not underlines)
- **MUST** include blank lines around headers, lists, code blocks
- **MUST** use fenced code blocks with language identifiers
- **MUST** use consistent list markers (`-` preferred)
- **MUST NOT** skip heading levels (h1 → h3)
- **SHOULD** keep lines under 120 characters
- **SHOULD** use reference-style links for repeated URLs

## Diagrams

- **SHOULD** use Mermaid for version-controlled diagrams
- **SHOULD** include alt text for images
- **SHOULD** keep diagrams simple (< 15 nodes)

## CI/CD Integration

```yaml
# Example GitHub Action
- name: Lint docs
  run: |
    markdownlint docs/**/*.md
    vale docs/

- name: Check links
  run: lychee docs/**/*.md --exclude-mail

- name: Build docs
  run: mkdocs build --strict
```

## Anti-patterns

- ❌ "Click here" links - use descriptive link text
- ❌ Screenshots of terminal output - use code blocks
- ❌ Outdated version numbers - use variables/macros
- ❌ Walls of text - use headers, lists, code blocks
- ❌ Assuming reader knowledge - define terms or link to glossary
- ❌ "Simply" or "just" - removes reader confidence
