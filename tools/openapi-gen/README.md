# OpenAPI Code Generator

Generates Go server stubs and types from OpenAPI 3.x specs using [oapi-codegen](https://github.com/oapi-codegen/oapi-codegen).

## Usage

```bash
# From the repo root
./tools/openapi-gen/generate.sh
```

## How It Works

1. Scans `api/*.yaml` for OpenAPI specs
2. Matches each spec to a service by filename (e.g., `todo-service.yaml` → `services/todo-service/`)
3. Generates two files in `services/<name>/internal/handler/`:
   - `types_gen.go` — request/response types from the OpenAPI schema
   - `server_gen.go` — chi-router server interface

## Naming Convention

The spec filename **must** match the service directory name:

| Spec File | Service Directory |
|---|---|
| `api/todo-service.yaml` | `services/todo-service/` |
| `api/user-service.yaml` | `services/user-service/` |

## Prerequisites

- Go 1.26+
- `oapi-codegen` (auto-installed by the script)
