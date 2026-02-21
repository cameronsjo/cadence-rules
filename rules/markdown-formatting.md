# Documentation Standards

## Markdown

- **MUST** use RFC 2119 keywords (MUST/SHOULD/MAY) in requirements docs
- **MUST** create documentation files when asked to "write up" something - actual files, not chat responses
- **MUST NOT** provide inline responses for writeup requests - create actual files
- **MUST** use proper markdown: headers, lists, code blocks, tables
- **MUST** use two spaces after emoji
- **MUST** write markdown that passes markdownlint validation
- **MUST** use consistent list markers (prefer `-`)
- **MUST** maintain proper heading hierarchy (no skipped levels)
- **MUST** include blank lines around headings, lists, code blocks
- **MUST** use fenced code blocks with language identifiers
- **SHOULD** be concise, actionable, examples-driven
- **SHOULD** include diagrams for architecture, flows, complex concepts

## Tables

- **MUST** bold the best value in each numeric/statistical column
- **SHOULD** include an italicized caption below statistics tables clarifying value direction (e.g., *Higher FPS is better. Lower latency is better.*)
- **SHOULD** right-align numeric columns for easy visual comparison

**Example:**

```markdown
| Config | FPS | Latency (ms) | Memory (MB) |
|--------|----:|-------------:|------------:|
| A      | **120** | 15       | 512         |
| B      | 90      | **8**    | **384**     |

*Higher FPS is better. Lower latency is better. Lower memory is better.*
```

## Diagrams

- **SHOULD** use Mermaid for interconnected systems, multi-step flows, architecture diagrams
- **SHOULD** use ASCII trees for simple decision trees and linear hierarchies
- **SHOULD NOT** convert simple ASCII diagrams to Mermaid - they're faster to scan and edit

## Structure

- Top-level: `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`
- Deeper content in `docs/` folder
- ADRs in `docs/adr/0001-decision-name.md` with numeric prefix

## Naming

- Convention-based top-level: SCREAMING_SNAKE_CASE (`README.md`, `CONTRIBUTING.md`)
- All other docs: kebab-case (`getting-started.md`, `api-overview.md`)
