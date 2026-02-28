<!-- managed by rules — changes will be overwritten by /rules:init-project -->
---
paths:
  - "**/*.sh"
  - "**/*.bash"
  - "**/Makefile"
  - "**/.envrc"
---

# Bash/Shell Standards

- **Version**: Bash 5.3+ (July 2025) or 5.2
- **Linting**: ShellCheck (non-negotiable in modern workflows)
- **Formatting**: shfmt
- **Readline**: 8.3 (case-insensitive search, export-completions)

## Core Requirements

- **MUST** use `#!/usr/bin/env bash` shebang (portable)
- **MUST** use `set -euo pipefail` at script start
- **MUST** quote all variables: `"$var"` not `$var`
- **MUST** use `[[ ]]` for conditionals (not `[ ]`)
- **MUST** use ShellCheck for linting
- **MUST** keep scripts under 100 lines - rewrite in Python/Go if larger
- **MUST** use `$(command)` substitution (not backticks)
- **MUST NOT** use SUID/SGID on shell scripts (security risk)
- **SHOULD** use `local` for function variables
- **SHOULD** put all code in functions (even just `main`)
- **SHOULD** accept `-h`, `--help`, `help` for help text
- **SHOULD** use `trap cleanup EXIT` for temporary file cleanup
- **SHOULD** use `: "${REQUIRED_VAR:?Error: not set}"` for required env vars

## Script Template

```bash
#!/usr/bin/env bash
set -euo pipefail

# Description: What this script does
# Usage: ./script.sh [options]

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

main() {
    local arg="${1:-}"

    if [[ -z "$arg" ]]; then
        echo "Usage: $SCRIPT_NAME <argument>" >&2
        exit 1
    fi

    # Script logic here
}

main "$@"
```

## Security

- **MUST** validate user input with regex before use (avoid command injection)
- **MUST** use arrays for commands with user input: `cmd=(docker run "$name"); "${cmd[@]}"`
- **SHOULD** restrict script permissions: `chmod 700 script_with_secrets.sh`

## Anti-patterns

- **MUST NOT** use `[ ]` single brackets (use `[[ ]]`)
- **MUST NOT** parse `ls` output (use glob expansion to array: `files=(*.txt)`)
- **MUST NOT** use unquoted `cd $dir` (use `cd "$dir" || exit 1`)
- **MUST NOT** leave commented-out old code (use git)
