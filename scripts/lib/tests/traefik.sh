#!/usr/bin/env bash
###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/tests/traefik.sh
#
# Description:
#   Traefik validation tests.
#
###############################################################################

test_traefik()
{
    print_section "Traefik"

    #
    # Container
    #
    docker_container_running "${TRAEFIK_SERVICE}" \
        || fail "Traefik container is not running."

    ok "Traefik container OK."

    #
    # Dashboard must be protected.
    #
    local headers

    headers="$(
        docker_http_headers \
            "${TRAEFIK_SERVICE}" \
            "https://127.0.0.1:8443/dashboard/"
    )"

    echo "${headers}" \
        | grep -Eq "HTTP/1\.[01] (401|403)" \
        || fail "Dashboard protection is not enabled."

    ok "Dashboard protection OK."
}