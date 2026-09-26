#!/usr/bin/env bash
#
# File: scripts/lib/deploy/restart.sh
#
# Description:
#   Restart services that require reloading static configuration.
#
# Responsibilities:
#   - restart services after stack synchronization
#   - ensure static configuration files are reloaded
#
# This function should be executed after docker compose up.

deploy_restart_services() {
    print_section "Restart services"

    local services=()

    # Services with static configuration
    [[ -d "${STACK_DIR}/configs/traefik" ]] && services+=(traefik)

    if (( ${#services[@]} == 0 )); then
        log_info "No services require restart."
        return 0
    fi

    log_info "Restarting services: ${services[*]}"

    docker compose \
        -f "${STACK_DIR}/compose.yml" \
        restart "${services[@]}"

    log_success "Static configuration reloaded."
}