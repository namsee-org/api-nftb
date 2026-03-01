# Platform Monorepo

A Go microservices monorepo following [Zalando RESTful API & Engineering Guidelines](https://opensource.zalando.com/restful-api-guidelines/).

## Repository Structure

```
todolist-api/
├── go.work                        # Go workspace file (Go 1.26+)
├── go.work.sum
├── Makefile                       # Top-level build/lint/test commands
├── README.md
├── .github/
│   └── workflows/
│       ├── ci.yml                 # Shared CI pipeline
│       └── deploy.yml
│
├── api/                           # OpenAPI specs (API-first design)
│   ├── todo-service.yaml
│   ├── user-service.yaml
│   └── notification-service.yaml
│
├── deploy/                        # Kubernetes / Helm / Terraform manifests
│   ├── todo-service/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── user-service/
│   └── notification-service/
│
├── pkg/                           # Shared libraries across services
│   ├── middleware/                 # Common HTTP middleware (auth, logging, tracing)
│   │   ├── go.mod
│   │   ├── auth.go
│   │   ├── correlation.go         # X-Flow-ID / X-Request-ID
│   │   └── logging.go
│   ├── httputil/                  # Shared HTTP helpers
│   │   ├── go.mod
│   │   ├── problem.go            # RFC 7807 Problem Details
│   │   ├── pagination.go         # Cursor-based pagination helpers
│   │   └── response.go
│   ├── events/                    # Shared event schemas (Nakadi-style)
│   │   ├── go.mod
│   │   └── event.go
│   └── health/                    # Health check endpoint helpers
│       ├── go.mod
│       └── health.go
│
├── services/                      # Individual microservices
│   ├── todo-service/
│   │   ├── go.mod
│   │   ├── go.sum
│   │   ├── Dockerfile
│   │   ├── Makefile
│   │   ├── cmd/
│   │   │   └── server/
│   │   │       └── main.go
│   │   ├── internal/
│   │   │   ├── handler/           # HTTP handlers
│   │   │   │   ├── todo.go
│   │   │   │   └── routes.go
│   │   │   ├── service/           # Business logic layer
│   │   │   │   └── todo.go
│   │   │   ├── repository/        # Data access layer
│   │   │   │   └── todo.go
│   │   │   ├── model/             # Domain models
│   │   │   │   └── todo.go
│   │   │   └── config/
│   │   │       └── config.go
│   │   └── migrations/
│   │       ├── 001_init.up.sql
│   │       └── 001_init.down.sql
│   │
│   ├── user-service/
│   │   ├── go.mod
│   │   ├── Dockerfile
│   │   ├── cmd/
│   │   │   └── server/
│   │   │       └── main.go
│   │   └── internal/
│   │       ├── handler/
│   │       ├── service/
│   │       ├── repository/
│   │       └── model/
│   │
│   └── notification-service/
│       ├── go.mod
│       ├── Dockerfile
│       ├── cmd/
│       └── internal/
│
├── tools/                         # Build tools, code generators, linters
│   ├── openapi-gen/
│   └── lint/
│
└── scripts/                       # Helper scripts
    ├── generate.sh
    ├── lint.sh
    └── test-all.sh
```

## Zalando Guidelines Mapping

| Zalando Principle | Implementation |
|---|---|
| **API-First** | OpenAPI specs in `api/` are defined *before* code |
| **RFC 7807 Problem Details** | `pkg/httputil/problem.go` — standardized error responses |
| **X-Flow-ID** for tracing | `pkg/middleware/correlation.go` — propagates flow IDs across services |
| **Cursor-based pagination** | `pkg/httputil/pagination.go` — no offset-based pagination |
| **RESTful resource naming** | Enforced via OpenAPI specs (`/todos`, `/users`) |
| **Health endpoints** | `pkg/health/` — every service exposes `/health` |
| **Event-driven (Nakadi)** | `pkg/events/` — shared event schemas for async communication |

## Go Workspace

The monorepo uses [Go Workspaces](https://go.dev/doc/tutorial/workspaces) (`go.work`) to link all modules for local development:

```go
go 1.26

use (
    ./pkg/middleware
    ./pkg/httputil
    ./pkg/events
    ./pkg/health
    ./services/todo-service
    ./services/user-service
    ./services/notification-service
)
```

Each service and shared package has its own `go.mod`, allowing independent versioning and dependency management.

### Example Service Module

```go
// services/todo-service/go.mod
module github.com/namsee-org/platform/services/todo-service

go 1.26

require (
    github.com/namsee-org/platform/pkg/middleware v0.0.0
    github.com/namsee-org/platform/pkg/httputil v0.0.0
)
```

## Key Patterns

### RFC 7807 Problem Details

All services return errors using the [RFC 7807](https://datatracker.ietf.org/doc/html/rfc7807) standard:

```go
package httputil

type Problem struct {
    Type     string `json:"type"`
    Title    string `json:"title"`
    Status   int    `json:"status"`
    Detail   string `json:"detail,omitempty"`
    Instance string `json:"instance,omitempty"`
}

func WriteProblem(w http.ResponseWriter, p Problem) {
    w.Header().Set("Content-Type", "application/problem+json")
    w.WriteHeader(p.Status)
    json.NewEncoder(w).Encode(p)
}
```

### Service Internal Layout

Each service follows a clean layered architecture:

| Layer | Directory | Responsibility |
|---|---|---|
| **Handler** | `internal/handler/` | HTTP routing, request parsing, response writing |
| **Service** | `internal/service/` | Business logic, orchestration |
| **Repository** | `internal/repository/` | Database access, queries |
| **Model** | `internal/model/` | Domain entities and value objects |
| **Config** | `internal/config/` | Service-specific configuration |

## Getting Started

### Prerequisites

- Go 1.26+
- Docker
- Make

### Local Development

```bash
# Clone the repository
git clone https://github.com/namsee-org/platform.git
cd platform

# Download all dependencies
go work sync

# Run a specific service
cd services/todo-service
go run cmd/server/main.go

# Run all tests
./scripts/test-all.sh

# Generate code from OpenAPI specs
./scripts/generate.sh

# Lint all services
./scripts/lint.sh
```

### Building Docker Images

```bash
# Build a specific service
docker build -t todo-service:latest -f services/todo-service/Dockerfile .

# Or use Make
make build-todo-service
```

## Architecture Overview

```
┌────────────┐     ┌────────────┐     ┌─────────────────────┐
│   Client    │────▶│  API GW    │────▶│  todo-service       │
└────────────┘     └────────────┘     │  user-service       │
                                      │  notification-svc   │
                                      └──────────┬──────────┘
                                                 │
                                      ┌──────────▼──────────┐
                                      │  Event Bus (Nakadi)  │
                                      └─────────────────────┘
```

- **Services communicate** via REST (synchronous) and events (asynchronous)
- **Each service** owns its own database (Database-per-Service pattern)
- **Shared libraries** in `pkg/` provide cross-cutting concerns without coupling services

## Contributing

1. Define or update the OpenAPI spec in `api/` **first** (API-first)
2. Generate server stubs if using code generation
3. Implement business logic in the service's `internal/` package
4. Add tests and update migrations as needed
5. Submit a PR with changes scoped to your service
