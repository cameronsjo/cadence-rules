<!-- managed by rules — changes will be overwritten by /rules:init-project -->
---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/requirements*.txt"
  - "**/setup.py"
  - "**/setup.cfg"
  - "**/.python-version"
---

# Python Standards

- **Runtime**: Python 3.13+ (3.14 released Oct 2025)
- **Version Management**: mise (replaces pyenv)
- **Package Management**: uv (10x+ faster than pip, written in Rust)
- **Linting/Formatting**: Ruff (10-100x faster, replaces black, isort, flake8)
- **Type Checking**: ty (Astral, 10-60x faster than mypy/Pyright) or Pyright
- **Validation**: Pydantic v2
- **Testing**: pytest + pytest-asyncio
- **AI/LLM**: pydanticai (type-safe LLM interactions)
- **Observability**: OpenTelemetry + structlog

## Core Requirements

- **MUST** use uv for package management (not pip)
- **MUST** include type hints on all functions and variables
- **MUST** use Ruff for linting and formatting
- **MUST** use lazy logging: `logger.debug("val=%s", val)` not f-strings
- **MUST** use Pydantic for validation (config, API bodies, schemas)
- **MUST** use `TaskGroups` (3.11+) for structured concurrency - no dangling futures
- **MUST** explicitly return `T | None` rather than implicit `None`
- **MUST** use type parameter syntax (3.12+): `def first[T](items: list[T])` not `TypeVar`
- **MUST** use `pydantic_settings.BaseSettings` for config (not bare `os.environ`)
- **MUST NOT** use magic strings/numbers
- **MUST NOT** use `*args`/`**kwargs` unless necessary - destroys type safety
- **MUST NOT** use mutable defaults in function args (`def foo(items=[])`)
- **SHOULD** use mise for Python version management
- **SHOULD** use type guards and `typing.Self` for OOP patterns
- **SHOULD** use Polars over pandas in production APIs (lower memory)
- **SHOULD** use `asynccontextmanager` for async resource lifecycle
- **SHOULD** use Result pattern (Ok/Err dataclasses) over exceptions for expected failures

## Ruff Config

- **MUST** set `line-length = 100`
- **MUST** select rules: `["E", "F", "I", "UP", "B", "SIM", "ASYNC"]`
- **MUST** set `typeCheckingMode = "strict"` in pyright/ty

## Anti-patterns

- **MUST NOT** use bare `os.environ["KEY"]` (crashes if missing — use BaseSettings)
- **MUST NOT** use eager f-string logging (`logger.debug(f"val={val}")`)
- **MUST NOT** use `Any` as a type annotation without justification
