#!/usr/bin/env bash
#
# File: scripts/lib/init/stack.sh
#
# Description:
#   Initial preparation of the Monitoring-Grafana deployment stack.
#
# Responsibilities:
#   - create STACK_DIR
#   - copy all deployment items from the Git repository
#   - overwrite any previous content
#
# This function is intended to be called ONLY from init.sh.
# For regular deployments use deploy_sync_stack().

init_stack() {
    print_section "Project stack"
    log_info "Preparing Monitoring-Grafana stack..."

    mkdir -p "${STACK_DIR}"

    for item in "${DEPLOY_ITEMS[@]}"; do
        local src="${GIT_DIR}/${item}"
        local dst="${STACK_DIR}/${item}"

        if [[ ! -e "${src}" ]]; then
            log_error "Missing deployment item: ${src}"
            return 1
        fi

        rm -rf "${dst}"
        cp -a "${src}" "${dst}"

        log_info "Copied ${item}"
    done

    log_success "Monitoring-Grafana stack prepared."
}