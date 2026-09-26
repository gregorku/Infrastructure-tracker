#!/usr/bin/env bash
#
# ==============================================================================
# Monitoring-Grafana
# Docker Network Initialization
# ==============================================================================
#
# Purpose:
#   Create all required Docker bridge networks for the Monitoring-Grafana project.
#
# Description:
#   - Creates Docker networks only if they do not already exist.
#   - Uses network parameters defined in config.sh.
#   - Safe to run multiple times (idempotent).
#
# Required variables (config.sh):
#   NETWORK_INTERNAL
#   NETWORK_INTERNAL_SUBNET
#   NETWORK_INTERNAL_GATEWAY
#
#   NETWORK_TRAEFIK
#   NETWORK_TRAEFIK_SUBNET
#   NETWORK_TRAEFIK_GATEWAY
#
# Required modules:
#   logging.sh
#
# Exported functions:
#   init_networks
#
# ==============================================================================

###############################################################################
# Create Docker network
###############################################################################

create_docker_network() {

    local network_name="$1"
    local subnet="$2"
    local gateway="$3"

    if docker network inspect "${network_name}" >/dev/null 2>&1; then
        log_info "Docker network '${network_name}' already exists."
        return 0
    fi

    log_info "Creating Docker network '${network_name}'..."

    docker network create \
        --driver bridge \
        --subnet "${subnet}" \
        --gateway "${gateway}" \
        "${network_name}" \
        >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        log_success "Docker network '${network_name}' created."
    else
        log_error "Failed to create Docker network '${network_name}'."
        return 1
    fi
}

###############################################################################
# Initialize Docker networks
###############################################################################

init_networks() {

    log_step "Docker networks"

    create_docker_network \
        "${NETWORK_INTERNAL}" \
        "${NETWORK_INTERNAL_SUBNET}" \
        "${NETWORK_INTERNAL_GATEWAY}"

    create_docker_network \
        "${NETWORK_TRAEFIK}" \
        "${NETWORK_TRAEFIK_SUBNET}" \
        "${NETWORK_TRAEFIK_GATEWAY}"
    log_success "Docker networks ready."
}