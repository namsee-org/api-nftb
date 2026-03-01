.PHONY: lint lint-fix lint-install api-lint api-gen test build clean

# ──────────────────────────────────────────────
# Linting (uses shared config: tools/lint/.golangci.yml)
# ──────────────────────────────────────────────

GOLANGCI_LINT_VERSION := v2.9.0
LINT_CONFIG           := tools/lint/.golangci.yml

## Install golangci-lint
lint-install:
	@echo "Installing golangci-lint $(GOLANGCI_LINT_VERSION)..."
	@go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@$(GOLANGCI_LINT_VERSION)

## Run linter across all modules
lint:
	@./tools/lint/run.sh

## Run linter with auto-fix across all modules
lint-fix:
	@./tools/lint/run.sh --fix

# ──────────────────────────────────────────────
# OpenAPI (Zalando guidelines validation)
# ──────────────────────────────────────────────

SPECTRAL_CONFIG := tools/openapi-gen/.spectral.yml

## Validate OpenAPI specs against Zalando guidelines
api-lint:
	@echo "Validating OpenAPI specs..."
	npx -y @stoplight/spectral-cli@latest lint api/*.yaml --ruleset $(SPECTRAL_CONFIG)

## Generate Go code from OpenAPI specs
api-gen:
	@./tools/openapi-gen/generate.sh

# ──────────────────────────────────────────────
# Test & Build
# ──────────────────────────────────────────────

## Run all tests
test:
	go test -v -race -cover ./...

## Build the service binary
build:
	go build -o bin/server ./cmd/server

## Remove build artifacts
clean:
	rm -rf bin/

# ──────────────────────────────────────────────
# Help
# ──────────────────────────────────────────────

## Show available targets
help:
	@echo "Available targets:"
	@echo "  make lint-install  Install golangci-lint"
	@echo "  make lint          Run Go linter across all modules"
	@echo "  make lint-fix      Run Go linter with auto-fix"
	@echo "  make api-lint      Validate OpenAPI specs (Zalando rules)"
	@echo "  make api-gen       Generate Go code from OpenAPI specs"
	@echo "  make test          Run all tests"
	@echo "  make build         Build server binary"
	@echo "  make clean         Remove build artifacts"
