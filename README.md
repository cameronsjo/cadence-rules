# Rules

How to work with code — language standards, security, quality, git, CI/CD, Docker, MCP, documentation.

Designed to be installed alongside the [codex](https://github.com/cameronsjo/codex) plugin. Codex covers *how to work with me*. Rules covers *how to work with code*.

## Rules

All files are installed to `~/.claude/rules/` with a `rules-` prefix, creating an ownership boundary. Non-prefixed files in that directory are user-managed and never touched.

### Always-loaded (unglobbed)

| Source file | Installed as | Domain |
|-------------|-------------|--------|
| `core-code-principles.md` | `rules-core-code-principles.md` | Code style, naming, type annotations |
| `engineering-standards.md` | `rules-engineering-standards.md` | Date/time, cost boundaries, containers |
| `git-workflow.md` | `rules-git-workflow.md` | Commits, PRs, code review |
| `markdown-formatting.md` | `rules-markdown-formatting.md` | Docs, tables, diagrams |
| `security-standards.md` | `rules-security-standards.md` | OWASP, AI/LLM, supply chain |
| `testing-and-observability.md` | `rules-testing-and-observability.md` | Testing, logging, tracing |

### Conditional (globbed by file pattern)

| Source file | Installed as | Triggers on |
|-------------|-------------|-------------|
| `beads.md` | `rules-beads.md` | `.beads/**` |
| `cicd.md` | `rules-cicd.md` | CI/CD configs |
| `dockerfile.md` | `rules-dockerfile.md` | Dockerfiles |
| `docs.md` | `rules-docs.md` | Markdown files |
| `mcp.md` | `rules-mcp.md` | MCP configs |
| `mermaid.md` | `rules-mermaid.md` | Mermaid diagrams |
| `languages/bash.md` | `rules-bash.md` | `*.sh`, `*.bash` |
| `languages/csharp.md` | `rules-csharp.md` | `*.cs`, `*.csproj` |
| `languages/go.md` | `rules-go.md` | `*.go`, `go.mod` |
| `languages/java.md` | `rules-java.md` | `*.java`, `pom.xml` |
| `languages/javascript.md` | `rules-javascript.md` | `*.js`, `*.jsx` |
| `languages/powershell.md` | `rules-powershell.md` | `*.ps1`, `*.psm1` |
| `languages/protobuf.md` | `rules-protobuf.md` | `*.proto` |
| `languages/python.md` | `rules-python.md` | `*.py`, `pyproject.toml` |
| `languages/rust.md` | `rules-rust.md` | `*.rs`, `Cargo.toml` |
| `languages/typescript.md` | `rules-typescript.md` | `*.ts`, `*.tsx` |

## Install

```bash
# Via workbench hub
claude plugin install rules@workbench
claude plugin enable rules@workbench

# Then run the init command to copy rules to ~/.claude/rules/
/rules:init
```

The init command uses md5 hashing to detect changes — it never reads file contents into the LLM context. After running, it self-destructs from cache and reappears when the plugin updates.

## License

MIT
