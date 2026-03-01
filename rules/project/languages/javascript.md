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

## Modern JavaScript (ES2024+)

- **MUST** use `const`/`let` - never `var`
- **MUST** use template literals over string concatenation
- **MUST** use optional chaining (`?.`) and nullish coalescing (`??`)
- **SHOULD** use destructuring for object/array access
- **SHOULD** use spread syntax over `Object.assign`
