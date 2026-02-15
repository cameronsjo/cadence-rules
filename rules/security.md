---
paths:
  - "**/auth/**"
  - "**/security/**"
  - "**/login/**"
  - "**/oauth/**"
---

# Security Review Standards

## AI/LLM Security

- Validate/sanitize inputs before sending to LLM
- Never send PII to external LLMs without consent
- Instruction/data separation for prompt injection defense
- Monitor for jailbreak attempts

## References

- OWASP Top 10: https://owasp.org/Top10/
- OWASP LLM Top 10: https://owasp.org/www-project-top-10-for-large-language-model-applications/
