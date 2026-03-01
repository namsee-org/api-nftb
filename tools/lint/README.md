# Lint Tools

Shared linting configuration and runner for all Go modules in the monorepo.

## Files

| File | Purpose |
|---|---|
| `.golangci.yml` | Shared golangci-lint config (Zalando best practices) |
| `run.sh` | Runs the linter across all Go modules |

## Usage

```bash
# Lint all modules
./tools/lint/run.sh

# Lint all modules with auto-fix
./tools/lint/run.sh --fix

# Or use the Makefile
make lint
make lint-fix
```

## Enabled Linters

| Category | Linters |
|---|---|
| **Bug Detection** | errcheck, gosec, bodyclose, nilerr, sqlclosecheck |
| **Code Style** | gofmt, goimports, revive, misspell, unconvert |
| **Code Quality** | govet, staticcheck, ineffassign, unused, prealloc, gocritic |
| **Complexity** | cyclop (max 15), gocognit (max 20), funlen (max 80 lines) |
| **Error Handling** | wrapcheck, errorlint |

## Customization

Edit `.golangci.yml` to adjust rules. See [golangci-lint docs](https://golangci-lint.run/usage/linters/) for all available linters.
