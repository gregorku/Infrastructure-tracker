#!/usr/bin/env bash
###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/tests/networks.sh
#
# Description:
#   Docker network validation tests.
#
###############################################################################

test_networks()
{
    print_section "Docker networks"

    docker_network_exists "${NETWORK_INTERNAL}" \
        || fail "Missing Docker network: ${NETWORK_INTERNAL}"

    docker_network_exists "${NETWORK_TRAEFIK}" \
        || fail "Missing Docker network: ${NETWORK_TRAEFIK}"

    ok "Docker networks OK."
}