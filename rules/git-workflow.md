# Git & Version Control

## Commits

- **MUST** use Conventional Commits format: `type(scope): description`
- **MUST** use present tense, imperative mood: "add feature" not "added feature"
- **MUST** include `Co-Authored-By: Claude <noreply@anthropic.com>`
- **MUST** use branch name 'main' not 'master'
- **MUST** review changes before commit
- **MUST** use merge over rebase - preserves true history, commit hashes, and timestamps
- **MUST NOT** force push to main/master
- **MUST NOT** rebase commits that have been pushed

## Pull Requests

- **MUST** use closing keywords: "Closes #123" or "Fixes #123" or "Resolves #123"
- **MUST** format multiple issues as: "Closes #52, #53, #54"
- **MUST NOT** use "Addresses" - it doesn't auto-close issues
- **SHOULD** link issues early in PR description for visibility

## Code Reviews

- **MUST** be direct and constructive
- **SHOULD** prioritize architecture and bugs over style
- **SHOULD** suggest improvements, not just problems
