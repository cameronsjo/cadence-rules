---
notice: "Maintained by the rules plugin. Source: github.com/cameronsjo/rules"
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

## Filesystem

- **MUST** treat `ENOENT` as a first-run signal when reading user-config or per-user state files (`~/.config/...`, `~/.<app>/...`), not an error. Catch `readErr.code === 'ENOENT'`, start from a default object, and proceed to write. A user who hasn't created the file yet should get a successful first-run, not a stack trace.
- **MUST** `mkdir(dirname(path), { recursive: true })` before `writeFile` when the parent directory may not exist (first-run, fresh install, deleted by user).
- **SHOULD** distinguish ENOENT from other I/O errors. Rethrow non-ENOENT errors after handling; don't swallow them under a generic "couldn't read" message.
