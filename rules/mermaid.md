<!-- managed by rules — changes will be overwritten by /rules:init -->
---
paths:
  - "**/*.mermaid"
  - "**/*.mmd"
---

# Mermaid Diagram Standards

## Core Requirements

- **MUST** keep diagrams simple (< 15 nodes recommended)
- **MUST** use consistent naming conventions
- **MUST** use comments (`%%`) to document purpose
- **MUST** declare all nodes at the beginning before relationships
- **MUST** use descriptive node IDs (not A, B, C)
- **SHOULD** use classes for consistent styling
- **SHOULD** break complex diagrams into smaller components
- **SHOULD** use `elk` renderer for complex diagrams (9.4+)

## Diagram Type Selection

| Use Case | Diagram Type |
|----------|--------------|
| Process flows | `flowchart` |
| Sequential steps | `sequenceDiagram` |
| State machines | `stateDiagram-v2` |
| Class relationships | `classDiagram` |
| Data models | `erDiagram` |
| Timelines | `gantt` or `timeline` |
| Git history | `gitGraph` |
| Mindmaps | `mindmap` |
| Architecture | `C4Context` (C4 extension) |

## Flowchart Template

```mermaid
%%{init: {"theme": "default"}}%%
flowchart TD
    %% Node declarations with descriptive IDs
    start([Start])
    validate{Validate Input}
    process[Process Data]
    success([Success])
    error([Error])

    %% Relationships
    start --> validate
    validate -->|valid| process
    validate -->|invalid| error
    process --> success

    %% Styling
    classDef errorStyle fill:#f96,stroke:#333
    class error errorStyle
```

## Sequence Diagram Template

```mermaid
sequenceDiagram
    %% Participants declared first
    participant U as User
    participant A as API Gateway
    participant S as Service
    participant D as Database

    %% Interactions
    U->>+A: POST /users
    A->>+S: CreateUser(data)
    S->>+D: INSERT user
    D-->>-S: user_id
    S-->>-A: User created
    A-->>-U: 201 Created

    %% Notes for clarity
    Note over S,D: Transaction boundary
```

## Styling Best Practices

```mermaid
%%{init: {
    "theme": "base",
    "themeVariables": {
        "primaryColor": "#4f46e5",
        "primaryTextColor": "#fff",
        "primaryBorderColor": "#3730a3",
        "lineColor": "#6b7280",
        "secondaryColor": "#f3f4f6",
        "tertiaryColor": "#e5e7eb"
    }
}}%%
flowchart LR
    %% Use classes for consistent styling
    A[Component A]:::primary
    B[Component B]:::secondary
    C[Component C]:::primary

    A --> B --> C

    classDef primary fill:#4f46e5,stroke:#3730a3,color:#fff
    classDef secondary fill:#f3f4f6,stroke:#d1d5db,color:#1f2937
```

## Complexity Guidelines

### Keep It Simple
```mermaid
%% ✅ Good - Clear, focused
flowchart LR
    Input --> Process --> Output
```

### Split Complex Diagrams
```mermaid
%% Instead of one huge diagram, create linked diagrams:
%% 1. system-overview.mmd (high-level)
%% 2. auth-flow.mmd (detailed auth)
%% 3. data-flow.mmd (detailed data)
```

## Layout Tips

```mermaid
flowchart TD
    %% Use subgraphs to group related nodes
    subgraph Frontend
        UI[Web UI]
        Mobile[Mobile App]
    end

    subgraph Backend
        API[API Server]
        Worker[Background Worker]
    end

    subgraph Data
        DB[(Database)]
        Cache[(Redis)]
    end

    UI --> API
    Mobile --> API
    API --> DB
    API --> Cache
    Worker --> DB
```

## Entity Relationship

```mermaid
erDiagram
    %% Use clear relationship labels
    USER ||--o{ ORDER : places
    ORDER ||--|{ LINE_ITEM : contains
    PRODUCT ||--o{ LINE_ITEM : "appears in"

    USER {
        string id PK
        string email UK
        string name
    }

    ORDER {
        string id PK
        string user_id FK
        datetime created_at
    }
```

## State Diagram

```mermaid
stateDiagram-v2
    %% Clear state names
    [*] --> Draft
    Draft --> Pending: submit
    Pending --> Approved: approve
    Pending --> Rejected: reject
    Approved --> [*]
    Rejected --> Draft: revise
```

## Integration in Markdown

````markdown
## Architecture Overview

```mermaid
flowchart LR
    Client --> Gateway --> Service --> Database
```

See [detailed auth flow](./auth-flow.md) for authentication details.
````

## Anti-patterns

- ❌ Single-letter node IDs (`A`, `B`, `C`) - use descriptive names
- ❌ 20+ nodes in one diagram - split into multiple
- ❌ Missing comments - document complex logic
- ❌ Inline styles on every node - use `classDef`
- ❌ Inconsistent arrow styles - pick one convention
- ❌ Cramming everything into one diagram - link to details
