---
notice: "Maintained by the rules plugin. Source: github.com/cameronsjo/rules"
paths:
  - "**/*.java"
  - "**/pom.xml"
  - "**/build.gradle"
  - "**/build.gradle.kts"
---

# Java Standards

**Runtime:** Java 21 LTS | **Framework:** Spring Boot 3.3+ | **Build:** Gradle 8.x (Kotlin DSL)

## Patterns

```java
// Records for immutable data (16+)
public record User(String id, String name, String email, Instant createdAt) {
    public User {
        Objects.requireNonNull(id, "id must not be null");
    }
}

// Pattern matching with switch (21+)
String describe(Object obj) {
    return switch (obj) {
        case Integer i when i > 0 -> "positive: " + i;
        case String s -> "string: " + s;
        case null -> "null value";
        default -> "unknown";
    };
}

// Virtual threads for I/O (21+)
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    var futures = users.stream()
        .map(user -> executor.submit(() -> processUser(user)))
        .toList();
}

// Structured concurrency (JEP 533, preview in JDK 25–27) — companion to virtual threads;
// MAY adopt where appropriate, prefer once it finalizes
try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
    var userFuture  = scope.fork(() -> userRepo.findById(id));
    var orderFuture = scope.fork(() -> orderRepo.findByUser(id));
    scope.join().throwIfFailed();
    return new UserProfile(userFuture.get(), orderFuture.get());
}

// Structured logging
logger.info("Fetching user: userId={}", userId);
```

## Anti-patterns

```java
// ❌ Mutable POJO, string concat logging, platform threads for I/O
public class User { private String name; public void setName(String n) { name = n; } }
logger.info("Processing " + user.getName());
ExecutorService executor = Executors.newFixedThreadPool(100);

// ✅ Immutable record, parameterized logging, virtual threads
public record User(String name) {}
logger.info("Processing user: name={}", user.name());
ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();
```

## Security

- **MUST** use `PreparedStatement` for all SQL (never string concatenation)
- **MUST** use `ObjectInputFilter` when deserializing -- allowlist expected classes
- **MUST** disable XXE: `factory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true)`
- **MUST** use `java.security.SecureRandom` for tokens (not `java.util.Random`)
- **MUST** use BCrypt or Argon2 for password hashing (not MD5/SHA)
- **MUST NOT** use string concatenation in SQL -- use `ProcessBuilder` with arg list for commands
- **MUST NOT** expose Spring Boot Actuator endpoints without authentication
- **SHOULD** use `@Valid` and Bean Validation for all API inputs
- **SHOULD** configure JNDI lookup restrictions in Log4j2 (`log4j2.formatMsgNoLookups=true`)
- **SHOULD** use module system for sandboxing in Java 21+
- **MAY** adopt structured concurrency (JEP 533, seventh preview targeting JDK 27) alongside virtual threads where it simplifies fan-out/fan-in; prefer it once it finalizes — do not use in production code that cannot accept preview-API churn
