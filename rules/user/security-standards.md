---
---

# Security Standards

## Core Principles

- **MUST** be secure-by-default and secure-by-design
- **MUST NOT** commit secrets - use environment variables
- **MUST** ensure security opt-outs are environment-gated (never in production)
- **MAY** use security opt-outs for local development (HTTP on localhost, disabled auth, relaxed CORS)

## Focus Areas (2025+)

- **OWASP Top 10 2025**: Current vulnerability categories
- **AI/LLM Security**: Prompt injection, PII leakage, model abuse
- **Supply Chain**: Dependency vulnerabilities, SBOM, attestation
- **Zero Trust**: Authentication everywhere, least privilege
- **API Security**: BOLA, rate limiting, input validation

## OWASP Top 10 Checklist

### A01: Broken Access Control

- [ ] Authorization checked on every request
- [ ] IDOR vulnerabilities tested
- [ ] Privilege escalation paths reviewed
- [ ] CORS properly configured

### A02: Cryptographic Failures

- [ ] Sensitive data encrypted at rest
- [ ] TLS 1.3 for data in transit
- [ ] No weak algorithms (MD5, SHA1, DES)
- [ ] Secrets in vault, not env vars for production

### A03: Injection

- [ ] SQL: Parameterized queries only
- [ ] Command: No shell execution with user input
- [ ] XSS: Output encoding, CSP headers
- [ ] Prompt: LLM input sanitization

### A04: Insecure Design

- [ ] Threat modeling completed
- [ ] Security patterns documented
- [ ] Fail-safe defaults implemented
- [ ] Defense in depth applied

### A05: Security Misconfiguration

- [ ] Default credentials changed
- [ ] Error messages sanitized
- [ ] Unnecessary features disabled
- [ ] Security headers configured

### A06: Vulnerable Components

- [ ] Dependencies scanned (npm audit, uv audit)
- [ ] SBOM generated
- [ ] Critical CVEs addressed
- [ ] Update process defined

### A07: Auth Failures

- [ ] MFA available for sensitive operations
- [ ] Password requirements enforced
- [ ] Session management secure
- [ ] Rate limiting on auth endpoints

### A08: Data Integrity Failures

- [ ] Code signing implemented
- [ ] CI/CD pipeline secured
- [ ] Dependencies verified (checksums)
- [ ] Deserialization safe

### A09: Logging Failures

- [ ] Security events logged
- [ ] No PII in logs
- [ ] Tamper-proof log storage
- [ ] Alerting configured

### A10: SSRF

- [ ] URL allowlisting for outbound requests
- [ ] Internal endpoints not exposed
- [ ] Response validation implemented

## Severity Classification

```yaml
Critical (P0):
  - Remote code execution
  - Authentication bypass
  - SQL injection
  - Exposed secrets/credentials
  - Privilege escalation to admin

High (P1):
  - Stored XSS
  - IDOR on sensitive data
  - Insecure deserialization
  - Missing authentication
  - SSRF to internal services

Medium (P2):
  - Reflected XSS
  - CSRF without sensitive impact
  - Missing rate limiting
  - Information disclosure
  - Weak cryptography

Low (P3):
  - Missing security headers
  - Verbose error messages
  - Clickjacking potential
  - Cookie without secure flag
```

## Security Patterns

- **MUST** use parameterized queries (never string interpolation)
- **MUST** validate input with schema libraries (Pydantic, Zod)
- **MUST** encode output (markupsafe, DOMPurify)
- **SHOULD** implement rate limiting on auth and API endpoints

## AI/LLM Security

- **MUST** sanitize user input before sending to LLMs
- **MUST** validate LLM outputs before execution
- **MUST** implement PII detection and redaction
- **MUST NOT** trust LLM-generated code without review
- **SHOULD** use allowlists for LLM tool/function calls
- **SHOULD** rate limit LLM API calls per user

## Concurrency Security

- **MUST** avoid TOCTOU (time-of-check-to-time-of-use) patterns -- check and act atomically
- **MUST** use file locks or atomic operations for shared file access
- **MUST NOT** check file existence then open -- use try/open with error handling
- **MUST NOT** check permission then act -- attempt the action and handle the error
- **SHOULD** use database transactions with appropriate isolation levels for concurrent data access
- **SHOULD** use optimistic locking (version columns) over pessimistic locks for web applications

## SSRF Prevention

- **MUST** validate and allowlist URLs before making outbound requests
- **MUST** block requests to private/internal IP ranges (10.x, 172.16-31.x, 192.168.x, 127.x, ::1, fd00::/8)
- **MUST** resolve DNS before validation -- prevent DNS rebinding by pinning the resolved IP
- **MUST NOT** follow redirects to internal addresses (validate after redirect)
- **SHOULD** use a dedicated HTTP client with URL validation middleware

## Second-Order Injection

- **MUST** treat stored data as untrusted when used in new contexts (SQL, HTML, shell)
- **MUST** encode/escape at the point of use, not at the point of storage
- **MUST NOT** assume data is safe because it was validated on input -- context changes
- **SHOULD** apply output encoding even to database-retrieved values used in HTML/SQL/shell

## Webhook Signature Validation

- **MUST** verify HMAC signatures on incoming webhooks before processing
- **MUST** use constant-time comparison for signature verification (prevent timing attacks)
- **MUST** reject requests with missing or invalid signatures
- **SHOULD** validate webhook timestamps to prevent replay attacks (reject if >5 min old)

## ReDoS Prevention

- **MUST** set timeouts on regex operations processing user input
- **MUST NOT** use nested quantifiers on user-controlled input (e.g., `(a+)+`, `(a|b)*c`)
- **SHOULD** prefer non-backtracking regex engines (RE2, rust regex) for user input
- **SHOULD** limit input length before applying regex patterns

## Agent and Autonomy Security

- **MUST** define autonomy levels explicitly: SUGGEST (recommend only) / CONFIRM (human approves) / BOUNDED (pre-approved scope) / AUTONOMOUS (full delegation)
- **MUST** require human confirmation for destructive operations regardless of autonomy level
- **MUST** validate agent outputs before execution -- treat agent responses as untrusted input
- **MUST** implement session isolation -- agents should not access other agents' working directories or memory
- **MUST** log all agent actions with full context (tool called, parameters, result, reasoning)
- **SHOULD** implement cooldown timers between destructive operations
- **SHOULD** detect and flag agent hallucination (claims of actions not reflected in system state)
