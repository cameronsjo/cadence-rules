---
notice: "Maintained by the rules plugin. Source: github.com/cameronsjo/rules"
paths:
  - "**/mcp/**"
  - "**/mcp-*"
  - "**/*-mcp/**"
  - "**/*_mcp.py"
  - "**/*-mcp.ts"
---

# MCP Server Standards

## Stack

- **Framework**: fastmcp (Python) or @modelcontextprotocol/sdk (TypeScript)
- **Validation**: Pydantic v2 (Python) / Zod (TypeScript)
- **Observability**: OpenTelemetry + structured logging
- **Testing**: pytest + MCPTestClient / vitest

## Core Requirements

- **MUST** sanitize PII before logging, caching, or external calls
- **MUST** validate all tool inputs with JSON schemas (Pydantic/Zod)
- **MUST** implement rate limiting for MCP endpoints
- **MUST** log all MCP interactions with context
- **MUST** implement OpenTelemetry tracing
- **SHOULD** implement graceful shutdown handling

## PII Sanitization

- **MUST** sanitize before logging (never log raw PII)
- **MUST** sanitize before external API calls
- **MUST** sanitize before caching/storage
- **MUST** sanitize in error messages
- **MUST** cover: emails, SSNs, phone numbers, credit card numbers
- **SHOULD** test with PII patterns to verify sanitization

## Spec Version

The current stable MCP specification revision is **2025-11-25** (modelcontextprotocol.io/specification/2025-11-25). An Extensions framework — using reverse-DNS extension IDs with independent versioning — is expected in an upcoming spec RC; design new servers for forward-compatibility by keeping extension-specific behavior isolated.

## Version Constraints

- **MUST** pin to major version: `fastmcp>=2.13.0,<3.0.0`
- **MUST** check changelog for breaking changes when upgrading
- **MUST** test server startup/shutdown after upgrades
- **MUST** verify tool/resource registration after upgrades
- **MUST** run full PII sanitization tests after upgrades
