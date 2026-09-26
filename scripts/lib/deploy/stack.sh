#!/usr/bin/env bash
#
# File: scripts/lib/deploy/stack.sh
#
# Description:
#   Synchronize the deployment stack with the current Git repository.
#
# Responsibilities:
#   - synchronize compose.yaml
#   - synchronize configs/
#   - synchronize secrets/
#   - synchronize all DEPLOY_ITEMS
#   - remove deleted files
#
# This function should be executed before every docker compose deployment.

deploy_sync_stack() {
    print_section "Synchronize stack"
    log_info "Synchronizing Monitoring-Grafana stack..."

    mkdir -p "${STACK_DIR}"

    for item in "${DEPLOY_ITEMS[@]}"; do
        local src="${GIT_DIR}/${item}"
        local dst="${STACK_DIR}/${item}"

        if [[ ! -e "${src}" ]]; then
            log_error "Missing deployment item: ${src}"
            return 1
        fi

        if command -v rsync >/dev/null 2>&1; then

            if [[ -d "${src}" ]]; then
                mkdir -p "${dst}"

                rsync \
                    -a \
                    --delete \
                    "${src}/" \
                    "${dst}/"

            else
                install -Dm644 "${src}" "${dst}"
            fi

        else

            rm -rf "${dst}"
            cp -a "${src}" "${dst}"

        fi

        log_info "Synchronized ${item}"
    done

    log_success "Monitoring-Grafana stack synchronized."
}