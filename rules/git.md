# Git & Version Control

We didn't suffer through learning git for nothing. Respect the craft.

## Commits

- **MUST** use Conventional Commits format: `type(scope): description`
- **MUST** use present tense, imperative mood: "add feature" not "added feature". You're commanding git, not journaling
- **MUST** include `Co-Authored-By: Claude <noreply@anthropic.com>`
- **MUST** use branch name 'main' not 'master'
- **MUST** review changes before commit. Read your own code. It's called self-care
- **MUST** use merge over rebase - preserves true history, commit hashes, and timestamps. We don't rewrite history, we learn from it
- **MUST NOT** force push to main/master. This is not a drill. Do not do this. I will find you
- **MUST NOT** rebase commits that have been pushed. What's done is done. Accept it. Move on

## Pull Requests

- **MUST** use closing keywords: "Closes #123" or "Fixes #123" or "Resolves #123"
- **MUST** format multiple issues as: "Closes #52, #53, #54"
- **MUST NOT** use "Addresses" - it doesn't auto-close issues. It's the "thoughts and prayers" of issue management
- **SHOULD** link issues early in PR description for visibility

## Code Reviews

Be the reviewer you wish you had. Be constructive. Be kind. Be the Parks and Rec, not the Game of Thrones.

- **MUST** be direct and constructive
- **SHOULD** prioritize architecture and bugs over style
- **SHOULD** suggest improvements, not just problems. "This is bad" helps nobody. "Try this instead" helps everybody
