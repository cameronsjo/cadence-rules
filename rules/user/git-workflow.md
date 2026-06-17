---
notice: "Maintained by the rules plugin. Source: github.com/cameronsjo/rules"
---
# Git & Version Control

## Commits

- **MUST** use Conventional Commits format: `type(scope): description`
- **MUST** use present tense, imperative mood: "add feature" not "added feature"
- **MUST** keep subject line under 72 characters
- **MUST** include `Co-Authored-By: Claude <noreply@anthropic.com>`
- **MUST** use branch name 'main' not 'master'
- **MUST** review changes before commit
- **MUST** use merge over rebase - preserves true history, commit hashes, and timestamps
- **MUST NOT** force push to main/master
- **MUST NOT** rebase commits that have been pushed

### Commit Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add OAuth login` |
| `fix` | Bug fix | `fix(api): handle null response` |
| `docs` | Documentation only | `docs: update API guide` |
| `refactor` | Code change without feature/fix | `refactor(db): extract query builder` |
| `test` | Test changes | `test(auth): add login edge cases` |
| `chore` | Build/tooling changes | `chore: update dependencies` |
| `perf` | Performance improvement | `perf(db): add query caching` |
| `ci` | CI/CD changes | `ci: add deployment pipeline` |
| `wip` | Work in progress (checkpoint) | `wip: broken — auth middleware incomplete` |

### Breaking Changes

- **MUST** use `!` or `BREAKING CHANGE` footer for breaking changes
- Examples: `feat!: remove legacy API`, `feat: add v2 API\n\nBREAKING CHANGE: v1 removed`

## Version Control Practices

- **MUST NOT** create backup files (file.bak, file.old) — use version control instead
- **MUST NOT** commit large binary files without LFS
- **MUST** use UTC for all timestamps (ISO 8601: `YYYY-MM-DDTHH:mm:ss.sssZ`)

## Pull Requests

- **MUST** use closing keywords: "Closes #123" or "Fixes #123" or "Resolves #123"
- **MUST** repeat the keyword for each issue: "Closes #52, closes #53" — a bare comma list ("Closes #52, #53") auto-closes only the **FIRST**; the rest stay open and need manual closing (verified 2026-06-16: "Closes #6, #30" closed #6, left #30 open)
- **MUST NOT** use "Addresses" - it doesn't auto-close issues
- **SHOULD** link issues early in PR description for visibility

## Code Reviews

- **MUST** be direct and constructive
- **SHOULD** prioritize architecture and bugs over style
- **SHOULD** use suggestion blocks for proposed changes
- **SHOULD** explain the "why" behind review feedback
- **SHOULD** use inline PR review comments (file + line range annotations) over top-level PR comments
- **SHOULD** submit as a single PR review with inline comments (not individual comment posts)
- **SHOULD** support re-entrancy: dismiss/replace previous review on re-run, no duplicate comments
- **MUST NOT** leave unactionable comments
