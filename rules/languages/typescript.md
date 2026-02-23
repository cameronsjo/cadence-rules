<!-- managed by rules — changes will be overwritten by /rules:init -->
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/tsconfig*.json"
---

# TypeScript Standards

- **Runtime**: Node 22 LTS / Bun 1.x
- **TypeScript**: 5.6+ with strict mode
- **Linting/Formatting**: Biome (replaces ESLint + Prettier)
- **Testing**: Vitest (fast, native ESM, TypeScript)
- **Build**: tsup, unbuild, or esbuild
- **Validation**: Zod for runtime validation
- **Observability**: OpenTelemetry + pino
- **React**: 19.2+ with React Compiler (auto-memoization)

## Core Requirements

- **MUST** use strict TypeScript (`strict: true` in tsconfig)
- **MUST** add type annotations to all code
- **MUST** avoid `any` - use `unknown` with type guards
- **MUST** use `as const`, enums, or literal types instead of magic strings
- **MUST** enable `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `verbatimModuleSyntax` in tsconfig
- **MUST** use Biome for linting and formatting
- **SHOULD** use ULIDs over UUIDs for IDs (unless external-facing)
- **SHOULD** use branded types for domain modeling (e.g., `type UserId = string & { readonly __brand: "UserId" }`)
- **SHOULD** use `satisfies` to validate types without widening
- **SHOULD** use `using` declarations for automatic resource cleanup

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
