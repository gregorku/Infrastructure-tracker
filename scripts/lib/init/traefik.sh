#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/init/traefik.sh
#
# Description:
#   Initialize Traefik directory structure.
#
###############################################################################

init_traefik()
{
    print_section "Traefik"

    ensure_directory "${TRAEFIK_DIR}"

    ensure_directory "${TRAEFIK_DIR}/acme"
    ensure_directory "${TRAEFIK_DIR}/logs"
    ensure_directory "${TRAEFIK_DIR}/users"
    ensure_directory "${TRAEFIK_DIR}/crowdsec"

    ensure_file_mode \
        "${TRAEFIK_DIR}/acme/acme.json" \
        600

    ok "Traefik layout ready."
}