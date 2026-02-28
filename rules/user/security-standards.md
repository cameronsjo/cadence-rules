<!-- managed by rules — changes will be overwritten by /rules:init-user -->
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
