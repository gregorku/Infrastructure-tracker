#!/usr/bin/env bash
deploy_validate_compose() {
    print_section "Compose validation"
    check_compose_configuration
}
deploy_compose() {
    print_section "Monitoring-Grafana"
    log_info "Pulling images..."
    compose_pull
    log_info "Starting stack..."
    compose_up
    log_success "Monitoring-Grafana deployed."
}
