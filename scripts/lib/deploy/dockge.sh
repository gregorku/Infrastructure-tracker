#!/usr/bin/env bash
deploy_dockge() {
    print_section "Dockge"
    if docker_container_running "${DOCKGE_CONTAINER}"; then
        log_success "Dockge is already running."
        return
    fi
    log_info "Installing Dockge..."
    "${SCRIPT_DIR}/install-dockge.sh"
}
