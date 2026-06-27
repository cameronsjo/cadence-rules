---
notice: "Maintained by the cadence-rules plugin. Source: github.com/cameronsjo/cadence-rules"
paths:
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.mjs"
  - "**/*.cjs"
---

# JavaScript Standards

## Core Requirements

- **MUST** configure ESLint + Prettier (or Biome)
- **MUST NOT** use magic strings/numbers - use constants
- **MUST** use async/await over callbacks
- **SHOULD** use npm (bun **MAY** be used for speed)
- **SHOULD** migrate to TypeScript for new projects

## React (JSX)

- **MUST** follow React standards in `typescript.md` - TSX is the standard
- **MUST** use functional components exclusively
- **MUST NOT** write new class components
- **SHOULD** convert JSX to TSX when modifying legacy files

## Runtime Target

- **MUST** target Node.js 24 LTS (Krypton, Active LTS since 2025-10-28); Node 22 is in maintenance

## Modern JavaScript (ES2024+)

- **MUST** use `const`/`let` - never `var`
- **MUST** use template literals over string concatenation
- **MUST** use optional chaining (`?.`) and nullish coalescing (`??`)
- **SHOULD** use destructuring for object/array access
- **SHOULD** use spread syntax over `Object.assign`

## Web Output & Encoding

- **MUST** escape `<` when serializing data into an inline `<script>` (JSON-LD, hydration/island state). `JSON.stringify` does not escape `<` or `/`, so a value containing `</script>` ends the block early and injects markup: `JSON.stringify(data).replace(/</g, '\\u003c')`.
- **MUST** `encodeURIComponent` any dynamic value interpolated into a URL path segment (slug/tag links, redirect targets). Raw interpolation breaks navigation and invites injection when the value contains reserved characters (`/`, `%`, `#`, `?`, spaces).

## Filesystem

- **MUST** treat `ENOENT` as a first-run signal when reading user-config or per-user state files (`~/.config/...`, `~/.<app>/...`), not an error. Catch `readErr.code === 'ENOENT'`, start from a default object, and proceed to write. A user who hasn't created the file yet should get a successful first-run, not a stack trace.
- **MUST** `mkdir(dirname(path), { recursive: true })` before `writeFile` when the parent directory may not exist (first-run, fresh install, deleted by user).
- **SHOULD** distinguish ENOENT from other I/O errors. Rethrow non-ENOENT errors after handling; don't swallow them under a generic "couldn't read" message.
- **SHOULD** name the offending file when parsing files read from disk (`JSON.parse`, YAML, TOML). A bare `SyntaxError: Unexpected token` from a directory scan doesn't say which file is malformed — wrap the parse and rethrow with the path: `throw new Error(\`Failed to parse ${file}: ${err.message}\`)`.
