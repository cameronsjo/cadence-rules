---
notice: "Maintained by the cadence-rules plugin. Source: github.com/cameronsjo/cadence-rules"
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/tsconfig*.json"
---

# TypeScript Standards

- **Runtime**: Node 24 LTS / Bun 1.x
- **TypeScript**: 6.0+ (`strict: true` is the default; never disable it)
- **Linting/Formatting**: Biome v2+ (type-aware lint rules require Biome v2+; replaces ESLint + Prettier)
- **Testing**: Vitest (fast, native ESM, TypeScript)
- **Build**: tsup, unbuild, or esbuild
- **Validation**: Zod for runtime validation
- **Observability**: OpenTelemetry + pino
- **React**: 19.2+ with React Compiler (auto-memoization)

## Core Requirements

- **MUST** use strict TypeScript (`strict: true` in tsconfig; this is the default in TypeScript 6.0+ — **MUST NOT** disable it)
- **MUST** add type annotations to all code
- **MUST** avoid `any` - use `unknown` with type guards
- **MUST** use `as const`, enums, or literal types instead of magic strings
- **MUST** enable `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `verbatimModuleSyntax` in tsconfig
- **MUST** use ES2025 import attributes syntax for typed imports: `import data from "./data.json" with { type: "json" }` (replaces deprecated `assert`)
- **MUST** use Biome for linting and formatting
- **SHOULD** use ULIDs over UUIDs for IDs (unless external-facing)
- **SHOULD** use branded types for domain modeling (e.g., `type UserId = string & { readonly __brand: "UserId" }`)
- **SHOULD** use `satisfies` to validate types without widening
- **SHOULD** use `using` declarations for automatic resource cleanup

## Web Output & Encoding

- **MUST** escape `<` when serializing data into an inline `<script>` (JSON-LD, hydration/island state). `JSON.stringify` does not escape `<` or `/`, so a value containing `</script>` ends the block early and injects markup: `JSON.stringify(data).replace(/</g, '\\u003c')`.
- **MUST** `encodeURIComponent` any dynamic value interpolated into a URL path segment (slug/tag links, redirect targets). Raw interpolation breaks navigation and invites injection when the value contains reserved characters (`/`, `%`, `#`, `?`, spaces).
- **MUST NOT** pass a leading-slash path to `new URL(path, base)` when `base` carries a path — a root-relative path **silently drops the base path**: `new URL('/search', 'https://h/v3')` → `https://h/search` (the `/v3` vanishes), mis-routing every request to a 404 that reads as "endpoint missing." Use a slash-terminated base + slash-less path (`new URL('search', 'https://h/v3/')`) or join explicitly. Bites any HTTP-client wrapper with a versioned base URL.

## React 19+ Standards (TSX)

### Core Philosophy

- **MUST** render on server by default, hydrate on client only when interactivity is required
- **MUST** use functional components exclusively (class components are legacy)
- **MUST** enable React Compiler in build pipeline (auto-memoizes, replaces manual `useMemo`/`useCallback`)
- **MUST** remove `useMemo`/`useCallback` once Compiler is active
- **MUST NOT** write new class components

### Server vs Client Components

- **MUST** use Server Components (RSC) by default - zero client JS bundle weight
- **MUST** mark Client Components explicitly with `'use client'`
- **MUST** push client boundary as far down the tree as possible
- **MUST NOT** make entire page a Client Component for one interactive element

### Component Patterns

- **MUST** use direct function signatures (not `React.FC`)
- **MUST** use default arguments (not `defaultProps`)
- **MUST** use explicit event types: `React.ChangeEvent<HTMLInputElement>`
- **MUST NOT** spread props blindly (`...props`) - be explicit
- **MUST NOT** write components over 300 lines - break them down

### React 19 Hooks

- **MUST** use `use(Promise)` for client-side data fetching (replaces `useEffect` + fetch)
- **MUST** use `useOptimistic` for immediate UI updates while awaiting server response
- **MUST** use `useActionState` for form submissions
- **MUST** use `useFormStatus` for form pending states
- **MUST NOT** use `useEffect` for data fetching
- **SHOULD** fetch data in Server Components and pass as props

### State Management

- **MUST** colocate state - keep it as close to usage as possible
- **MUST** use TanStack Query or SWR for server state
- **MUST NOT** use Redux for server state - it's for client-global UI state only
- **SHOULD** use Zustand over Redux for client state

### Component Quality

- **MUST** implement Error Boundaries around major sections
- **MUST** use `<Suspense fallback={...}>` for async components
- **MUST** use unique IDs for list keys (not `index` if list can reorder)
- **SHOULD** use composition over inheritance (pass components as children/props)

### Forms

- **MUST** use Server Actions for mutations
- **MUST** validate with Zod or Valibot for runtime type safety
- **SHOULD** use React Hook Form + Zod for complex client forms

### Project Structure (Feature-Based)

- `src/features/<name>/` — components, hooks, actions, types per feature
- `src/components/` — generic UI primitives (Button, Card)
- `src/lib/` — singleton clients (DB, Redis)
- `app/` — routing (App Router / Remix)

### 2025 React Tooling

| Category | Tool | Notes |
|----------|------|-------|
| Framework | Next.js 15+ (App Router) or React Router v7 | Full React 19 support |
| Styling | Tailwind CSS + shadcn/ui | Utility-first, accessible |
| Server State | TanStack Query | Caching/deduplication |
| Client State | Zustand | Minimal API |
| Forms | React Hook Form + Zod | Schema validation |
| Testing | Vitest + React Testing Library | Fast, modern |
