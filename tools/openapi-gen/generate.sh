#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# OpenAPI Code Generator
# Generates Go server stubs from OpenAPI 3.x specs in api/
# Uses oapi-codegen (https://github.com/oapi-codegen/oapi-codegen)
# ──────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
API_DIR="${ROOT_DIR}/api"
OAPI_CODEGEN_VERSION="v2.4.1"

# Ensure GOPATH/bin is in PATH so go-installed binaries are found
export GOBIN="${GOBIN:-$(go env GOPATH)/bin}"
export PATH="${GOBIN}:${PATH}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ── Install oapi-codegen if missing ──────────────────────────
install_oapi_codegen() {
    if ! command -v oapi-codegen &> /dev/null; then
        log_info "Installing oapi-codegen ${OAPI_CODEGEN_VERSION}..."
        go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@${OAPI_CODEGEN_VERSION}
    else
        log_info "oapi-codegen already installed: $(oapi-codegen --version 2>/dev/null || echo 'unknown version')"
    fi
}

# ── Generate code for a single spec ──────────────────────────
generate_for_spec() {
    local spec_file="$1"
    local service_name
    service_name="$(basename "${spec_file}" .yaml)"

    local service_dir="${ROOT_DIR}/services/${service_name}"
    local output_dir="${service_dir}/internal/handler"

    if [[ ! -d "${service_dir}" ]]; then
        log_warn "Service directory not found for '${service_name}', skipping: ${service_dir}"
        return 0
    fi

    mkdir -p "${output_dir}"

    log_info "Generating types for ${service_name}..."
    oapi-codegen \
        -generate types \
        -package handler \
        -o "${output_dir}/types_gen.go" \
        "${spec_file}"

    log_info "Generating server interface for ${service_name}..."
    oapi-codegen \
        -generate chi-server \
        -package handler \
        -o "${output_dir}/server_gen.go" \
        "${spec_file}"

    log_info "✅ Generated code for ${service_name}"
}

# ── Main ─────────────────────────────────────────────────────
main() {
    log_info "Starting OpenAPI code generation..."

    install_oapi_codegen

    if [[ ! -d "${API_DIR}" ]]; then
        log_error "API directory not found: ${API_DIR}"
        log_info  "Create OpenAPI specs in api/ (e.g., api/todo-service.yaml)"
        exit 1
    fi

    local spec_count=0
    for spec_file in "${API_DIR}"/*.yaml; do
        [[ -f "${spec_file}" ]] || continue
        generate_for_spec "${spec_file}"
        ((spec_count++))
    done

    if [[ ${spec_count} -eq 0 ]]; then
        log_warn "No OpenAPI specs found in ${API_DIR}"
        log_info "Create specs like: api/todo-service.yaml"
    else
        log_info "🎉 Generated code for ${spec_count} spec(s)"
    fi
}

main "$@"
