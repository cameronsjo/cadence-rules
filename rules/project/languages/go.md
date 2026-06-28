---
notice: "Maintained by the cadence-rules plugin. Source: github.com/cameronsjo/cadence-rules"
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---

# Go Standards

- **Version**: Go 1.26+ (1.24 is EOL)
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

## Build & Verification

- **MUST** run `go vet ./...` separately from `go build ./...` — the compiler passes with wrong-arity test calls and other subtle issues that vet catches. Run both after any function signature change.
- **SHOULD** run `go test ./...` before claiming a change is complete.

## Module Lifecycle

- **`+incompatible` is a "module ran out of road" flag, not just a version suffix.** It means the module never adopted semantic-import versioning, so any future major MUST live in a new module path. When a Dependabot CVE names a `+incompatible` module with `first_patched_version` higher than `go list -m -versions <module>` returns, the successor lives elsewhere — probe the Go proxy directly: `curl -s https://proxy.golang.org/<candidate-path>/@v/list` for tag lists, `curl -s https://proxy.golang.org/<candidate-path>/@latest` for the latest. Common successor patterns: `<path>/v2`, `<path>/api` and `<path>/client` split modules, or a fully renamed canonical path (e.g. `github.com/docker/docker` → `github.com/moby/moby/{api,client}` + `github.com/moby/moby/v2`). Dependabot's `first_patched_version` is a hint — it can name a version in a different module path than the one it's flagging, or refer to a daemon/binary release rather than the Go SDK linkage. Use it to find the successor, not as a pin target.
- **Daemon-side CVEs in a vendored-daemon Go module are not exploitable from client-only usage.** Modules that ship both daemon and client code (`docker/docker`, `etcd`, `containerd`, anything sliced out of CNCF) get flagged for daemon-side bugs that aren't reachable from the SDK linkage. Read the advisory's "Affected" section before bumping — the actual security boundary may be the running binary on the deploy target, not the linked Go module.

## Standard Library Gaps

- **`os.UserStateDir` does not exist in Go stdlib.** For log/state file paths, use `os.UserConfigDir()` — maps to `~/Library/Application Support/` on macOS, `~/.config/` on Linux. Co-locating logs with config is acceptable for personal tools.
- **`io.NopCloser` wraps `io.Reader`, not a generic `io.Closer`.** For a no-op `io.Closer`, define a private `nopCloser struct{}` with `func (nopCloser) Close() error { return nil }`.
- **`hash.Hash.Sum(b)` *appends* the digest to `b` — it does not hash `b`.** `sha256.New().Sum([]byte(x))` returns `x || sha256("")`, so slicing the result (`[:16]`) yields the first bytes of **raw `x`**, not a hash. Built as a redacted `content_hash` for logs, it silently *leaks the content it was meant to hide*. Use `sum := sha256.Sum256([]byte(x)); sum[:n]`.

## Testing

- **macOS caps Unix-socket paths at ~104 chars (`sun_path`); `t.TempDir()` overflows it.** `t.TempDir()` embeds the full (long) test-function name in the path, so binding a socket under it fails with `bind: invalid argument`. Bind test sockets under a short `os.MkdirTemp("", "x")` dir instead (with `t.Cleanup(func() { os.RemoveAll(dir) })`). Files under `t.TempDir()` are fine — only the socket-path length limit bites. (`net.Listen("unix", …)` in a Go test; the Python side dodges it because `tempfile.mkdtemp()` uses a short name.)

## slog Bootstrap

- **The package that calls `slog.SetDefault()` cannot log through the handler it configures** — the default (stderr-only) handler is active during setup. Keep bootstrap paths minimal and log from callers after the logger is wired.

## Releases (goreleaser)

- **MUST** use annotated tags for goreleaser releases: `git tag -a vX.Y.Z -m "vX.Y.Z: <summary>"`. Lightweight tags (`git tag vX.Y.Z`) fail silently with `fatal: no tag message?` and do not trigger the release workflow.
