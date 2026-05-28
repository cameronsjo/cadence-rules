---
notice: "Maintained by the rules plugin. Source: github.com/cameronsjo/rules"
paths:
  - "**/*.proto"
---

# Protocol Buffers / gRPC Standards

- **Syntax**: proto3 for existing projects; Edition 2024 for new projects (tooling still maturing)
- **Linting**: buf lint
- **Breaking Change Detection**: buf breaking
- **Code Generation**: buf generate
- **Documentation**: protoc-gen-doc

## Core Requirements

- **MUST** never reuse field numbers (even after deletion)
- **MUST** never change field numbers once in use
- **MUST** never change field types (breaks deserialization)
- **MUST** use `reserved` for deleted field numbers and names
- **MUST** document all messages, fields, and services
- **MUST** use field numbers 1-15 for frequently-set fields (1 byte)
- **MUST NOT** use field numbers 19000-19999 (reserved by protobuf)
- **SHOULD** leave gaps in field numbers for future high-frequency fields
- **SHOULD** use proto3 for existing projects — changing syntax in an established schema is disruptive
- **SHOULD** evaluate Edition 2024 for new projects; it supersedes Edition 2023 as the current protobuf edition, but migration tooling is still maturing — verify buf and language runtime support before adopting
- **SHOULD** use buf for linting and breaking change detection

## Field Numbering Strategy

```protobuf
message User {
  // 1-15: High-frequency fields (1-byte encoding)
  string id = 1;
  string email = 2;
  string name = 3;
  // Reserve 4-10 for future high-frequency fields

  // 16+: Lower-frequency fields (2-byte encoding)
  string phone = 16;
  string address = 17;
  google.protobuf.Timestamp created_at = 18;
  google.protobuf.Timestamp updated_at = 19;

  // Reserved: Never reuse these
  reserved 100, 101;
  reserved "legacy_field", "old_name";
}
```

## Documentation Template

```protobuf
syntax = "proto3";

package mycompany.myservice.v1;

option go_package = "github.com/mycompany/myservice/gen/go/v1";
option java_package = "com.mycompany.myservice.v1";

import "google/protobuf/timestamp.proto";

// UserService provides user management operations.
//
// This service handles user CRUD operations and authentication.
service UserService {
  // GetUser retrieves a user by their unique identifier.
  //
  // Returns NOT_FOUND if the user does not exist.
  rpc GetUser(GetUserRequest) returns (GetUserResponse);

  // CreateUser creates a new user account.
  //
  // Returns ALREADY_EXISTS if email is already registered.
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);
}

// GetUserRequest is the request message for GetUser.
message GetUserRequest {
  // The unique identifier of the user to retrieve.
  // Format: ULID (26 characters)
  string user_id = 1;
}

// GetUserResponse is the response message for GetUser.
message GetUserResponse {
  // The requested user.
  User user = 1;
}

// User represents a user account in the system.
message User {
  // Unique identifier for the user.
  // Format: ULID (26 characters)
  string id = 1;

  // Email address (unique across all users).
  string email = 2;

  // Display name shown in the UI.
  string display_name = 3;

  // When the user account was created.
  google.protobuf.Timestamp created_at = 16;
}
```

## Backwards Compatibility Rules

### Safe Changes (Non-Breaking)
```protobuf
// ✅ Adding new fields
message User {
  string id = 1;
  string email = 2;
  string phone = 3;  // NEW - safe to add
}

// ✅ Adding new enum values (at end)
enum Status {
  STATUS_UNSPECIFIED = 0;
  STATUS_ACTIVE = 1;
  STATUS_INACTIVE = 2;
  STATUS_SUSPENDED = 3;  // NEW - safe to add
}

// ✅ Adding new RPC methods
service UserService {
  rpc GetUser(GetUserRequest) returns (GetUserResponse);
  rpc DeleteUser(DeleteUserRequest) returns (DeleteUserResponse);  // NEW
}
```

### Breaking Changes (Avoid)
```protobuf
// ❌ Changing field number
message User {
  string id = 1;
  string email = 3;  // WAS 2 - breaks deserialization
}

// ❌ Changing field type
message User {
  int64 id = 1;  // WAS string - BREAKS DESERIALIZATION
}

// ❌ Reusing deleted field number
message User {
  string id = 1;
  // email was field 2, now deleted
  string phone = 2;  // REUSING 2 - BREAKS OLD DATA
}

// ❌ Renaming enum values
enum Status {
  UNSPECIFIED = 0;  // WAS STATUS_UNSPECIFIED - BREAKS JSON
}
```

### Proper Deletion
```protobuf
message User {
  string id = 1;
  // string legacy_email = 2;  // DELETED
  string email = 3;

  // Prevent reuse of deleted fields
  reserved 2;
  reserved "legacy_email";
}
```

## Enum Best Practices

```protobuf
enum UserStatus {
  // Always have UNSPECIFIED as 0 (proto3 default)
  USER_STATUS_UNSPECIFIED = 0;

  // Prefix values with enum name (avoids collisions)
  USER_STATUS_ACTIVE = 1;
  USER_STATUS_INACTIVE = 2;
  USER_STATUS_SUSPENDED = 3;
}
```

## buf.yaml Configuration

```yaml
version: v2
modules:
  - path: proto
    name: buf.build/mycompany/myservice
lint:
  use:
    - DEFAULT
  except:
    - PACKAGE_VERSION_SUFFIX
breaking:
  use:
    - FILE
```

## Anti-patterns

- ❌ Reusing field numbers (even after deletion)
- ❌ Changing field types
- ❌ Missing documentation on messages/fields
- ❌ Using 1-15 for rarely-used fields
- ❌ Enum without `_UNSPECIFIED = 0` value
- ❌ Enum values without prefix (causes naming collisions)
- ❌ No `reserved` for deleted fields
- ❌ Changing field names (breaks JSON serialization)
