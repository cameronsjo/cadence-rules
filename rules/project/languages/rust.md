---
notice: "Maintained by the rules plugin. Source: github.com/cameronsjo/rules"
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
  - "**/Cargo.lock"
---

# Rust Standards

**Tooling:** clippy (`#![warn(clippy::all, clippy::pedantic)]`), rustfmt, cargo test

## Patterns

```rust
// Result for error handling (avoid unwrap in production)
fn fetch_user(id: &str) -> Result<User, AppError> {
    let response = client.get(url).send()?;
    let user: User = response.json()?;
    Ok(user)
}

// Custom error types
#[derive(Debug, thiserror::Error)]
enum AppError {
    #[error("User not found: {0}")]
    NotFound(String),
    #[error("Network error: {0}")]
    Network(#[from] reqwest::Error),
}

// Builder pattern for complex construction
let config = ConfigBuilder::new()
    .timeout(Duration::from_secs(30))
    .retries(3)
    .build()?;

// Document unsafe blocks
// SAFETY: pointer is valid and aligned, obtained from Box::into_raw
unsafe { Box::from_raw(ptr) }
```

## Principles

- Leverage type system for compile-time guarantees
- Prefer iterator chains over manual loops
- Minimize allocations (references, slices)
- Document all `unsafe` with safety invariants
- Use `criterion` for benchmarks

## Security

- **MUST** use `.get()` over indexing (`[i]`) for user-controlled indices (indexing panics is DoS)
- **MUST** use `rand::rngs::OsRng` for cryptographic randomness
- **MUST** use established crypto libraries (`ring`, `rustls`, `ed25519-dalek`) -- not hand-rolled
- **MUST** document safety invariants on every `unsafe` block with `// SAFETY:` comment
- **MUST** test all `unsafe` blocks with Miri (`cargo +nightly miri test`)
- **MUST NOT** derive `Debug` on structs containing secrets (leaks via `{:?}` formatting)
- **MUST NOT** use `String::from_utf8_unchecked()` on external input
- **SHOULD** use `secrecy::Secret<T>` wrapper for sensitive values (prevents accidental logging)
- **SHOULD** use `sqlx` with compile-time query checking for database access
- **SHOULD** audit custom `Deserialize` impls for gadget chain vulnerabilities
