---
notice: "Maintained by the cadence-rules plugin. Source: github.com/cameronsjo/cadence-rules"
paths:
  - "**/skills/*/SKILL.md"
  - "**/commands/*.md"
---

# Skill & Command Frontmatter Standards

Two specs govern frontmatter: the [Agent Skills spec](https://agentskills.io) (open standard) and the Claude Code skill spec (implementation extensions). Both MUST be satisfied.

## SKILL.md Frontmatter

| Field | Spec | Required | Constraints |
|---|---|---|---|
| `name` | Agent Skills | Yes | 1-64 chars, lowercase + numbers + hyphens, no leading/trailing/consecutive hyphens, must match directory name |
| `description` | Agent Skills | Yes | 1-1024 chars, describe what it does and when to use it |
| `license` | Agent Skills | No | License name or reference to bundled file |
| `compatibility` | Agent Skills | No | Max 500 chars, environment requirements |
| `metadata` | Agent Skills | No | Key-value map (author, version, etc.) |
| `allowed-tools` | Both | No | Space-delimited pre-approved tools |
| `argument-hint` | Claude Code | No | Hint for autocomplete (e.g., `[issue-number]`) |
| `disable-model-invocation` | Claude Code | No | `true`/`false` — prevent Claude auto-loading |
| `user-invocable` | Claude Code | No | `false` to hide from `/` menu |
| `model` | Claude Code | No | Model override |
| `context` | Claude Code | No | `fork` to run in subagent |
| `agent` | Claude Code | No | Subagent type when `context: fork` |
| `hooks` | Claude Code | No | Skill-scoped hooks |
| `when_to_use` | Claude Code | No | Activation guidance that supplements `description` |
| `effort` | Claude Code | No | Reasoning depth: `low`, `medium`, or `high` |

- **MUST** include `name` and `description` in every SKILL.md
- **MUST** match `name` to the parent directory name exactly
- **MUST** use only lowercase letters, numbers, and hyphens in names
- **MUST NOT** start or end names with hyphens, or use consecutive hyphens
- **SHOULD** include `license` and `metadata` (author, version) per Agent Skills spec
- **MUST NOT** use fields not listed above (e.g., `category` is not a valid field)

## Command Frontmatter

Commands (`.claude/commands/*.md`) support the same fields as skills.

- **MUST NOT** include `name:` in command files — commands derive their name from the filename, and `name:` causes double-prefix (e.g., `/plugin:plugin-name` instead of `/name`)
- **SHOULD** include `description` and `allowed-tools`

## Progressive Disclosure

- **SHOULD** keep SKILL.md under 500 lines
- **SHOULD** move detailed reference material to `references/`, `scripts/`, or `assets/` subdirectories
- **SHOULD** reference supporting files from SKILL.md so Claude knows when to load them
