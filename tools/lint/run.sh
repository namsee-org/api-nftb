#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# Lint Runner
# Runs golangci-lint across all Go modules in the monorepo
# using the shared config in tools/lint/.golangci.yml
# ──────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/.golangci.yml"
GOLANGCI_LINT_VERSION="v2.9.0"

# Ensure GOPATH/bin is in PATH (takes priority over Homebrew)
export GOBIN="${GOBIN:-$(go env GOPATH)/bin}"
export PATH="${GOBIN}:${PATH}"

# Disable go.work so each module lints independently
export GOWORK=off

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ── Install golangci-lint if missing ─────────────────────────
ensure_golangci_lint() {
    if ! command -v golangci-lint &> /dev/null; then
        log_info "Installing golangci-lint ${GOLANGCI_LINT_VERSION}..."
        go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@${GOLANGCI_LINT_VERSION}
    fi
}

# macOS-compatible relpath
relpath() {
    python3 -c "import os; print(os.path.relpath('$1', '$2'))"
}

# ── Main ─────────────────────────────────────────────────────
main() {
    local fix_flag=""
    if [[ "${1:-}" == "--fix" ]]; then
        fix_flag="--fix"
        log_info "Running with --fix enabled"
    fi

    ensure_golangci_lint

    local exit_code=0

    # Find all go.mod files and lint each module independently
    while IFS= read -r gomod; do
        local module_dir
        module_dir="$(dirname "${gomod}")"
        local rel_dir
        rel_dir="$(relpath "${module_dir}" "${ROOT_DIR}")"

        # Skip vendor directories
        [[ "${module_dir}" == *vendor* ]] && continue

        log_info "Linting ${rel_dir}..."
        (
            cd "${module_dir}"
            golangci-lint run --config "${CONFIG_FILE}" ${fix_flag} ./...
        ) || exit_code=1
        log_info "✅ Done: ${rel_dir}"
    done < <(find "${ROOT_DIR}" -name "go.mod" -not -path "*/vendor/*")

    if [[ ${exit_code} -eq 0 ]]; then
        log_info "🎉 All modules passed linting!"
    else
        log_error "❌ Some modules have lint issues"
    fi

    return ${exit_code}
}

main "$@"
