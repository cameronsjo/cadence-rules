---
notice: "Maintained by the rules plugin. Source: github.com/cameronsjo/rules"
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---

# Go Standards

- **Version**: Go 1.24+ (iterators stable, Swiss Tables maps, weak pointers)
- **HTTP**: stdlib net/http (1.22+ routing) or chi
- **Database**: sqlc (type-safe SQL) or pgx
- **Validation**: go-playground/validator
- **CLI**: cobra + viper
- **Testing**: stdlib + testify (testing.B.Loop for benchmarks in 1.24)
- **Linting**: golangci-lint (100+ linters, caching, parallel)
- **Observability**: OpenTelemetry + slog (stdlib, slog.DiscardHandler in 1.24)

## Core Philosophy

Prefer stdlib over frameworks. Use generics for data structures, not business logic.

## Core Requirements

- **MUST** use `gofmt` / `goimports` for formatting
- **MUST** use `golangci-lint` with strict config
- **MUST** handle all errors explicitly - no ignoring with `_`
- **MUST** use context for cancellation and timeouts (first arg to I/O functions)
- **MUST** use `errors.Is`/`errors.As` for error checking (not equality)
- **MUST** handle errors in defer statements (`defer file.Close()` can lose data on write flush failure)
- **MUST** wrap errors with context: `fmt.Errorf("failed to get user %s: %w", id, err)`
- **MUST** use `errgroup.WithContext` for goroutine lifecycle management (not bare `go func()`)
- **MUST NOT** use `panic` for error handling - only for startup failures
- **MUST NOT** use package-level global variables for DB/loggers - inject via constructors
- **SHOULD** use slog for structured logging (not Logrus/Zap)
- **SHOULD** prefer table-driven tests
- **SHOULD** use `assert.Regexp` over `assert.Contains` when asserting against generated or dynamic content (enum values, ordered lists, version strings)
- **SHOULD** accept interfaces, return structs
- **SHOULD** use sqlc or pgx for database (explicit SQL) - avoid heavy ORMs like GORM
- **SHOULD** pass dependencies manually in `NewService()` constructors - avoid magic DI frameworks
- **SHOULD** use generics for utilities only - limit to 5 type parameters
- **SHOULD** use range-over-func iterators (1.23+) with `slices.Collect` for collection pipelines

## Project Structure

- `cmd/<app>/main.go` — entrypoints
- `internal/` — private packages (handler, service, repository)
- `pkg/` — public packages (if any)

## Anti-patterns

- **MUST NOT** `panic(err)` for error handling
- **MUST NOT** ignore errors with `_ = json.Unmarshal(...)`
- **MUST NOT** launch goroutines without lifecycle management
- **MUST NOT** use bare `os.Getenv` for config — validate at startup with Pydantic-style struct parsing

## Security

- **MUST** use `crypto/rand` for tokens (not `math/rand`)
- **MUST** use `filepath.Clean()` + `filepath.Rel()` check for path traversal prevention
- **MUST** use `html/template` for HTML output (not `text/template`)
- **MUST** set `tls.Config{MinVersion: tls.VersionTLS12}` on HTTP clients and servers
- **MUST** set timeouts on all HTTP servers (`ReadTimeout`, `WriteTimeout`, `IdleTimeout`)
- **MUST** validate UTF-8 before string operations on external input: `utf8.Valid()`
- **MUST NOT** use `os/exec.Command()` with shell expansion -- pass args separately
- **MUST NOT** use `unsafe` package without documented safety invariants
- **SHOULD** use `errgroup` with context for goroutine lifecycle (prevents goroutine leaks)
- **SHOULD** use `sync.Mutex` or channels for shared state -- never bare goroutine writes
- **SHOULD** use `-race` flag in CI test runs to detect data races
