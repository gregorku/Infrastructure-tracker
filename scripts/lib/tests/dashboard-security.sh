#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/tests/dashboard-security.sh
#
# Description:
#   Dashboard security validation.
#
###############################################################################

test_dashboard_security()
{
    print_section "Dashboard authentication"

    require_directory "${DATA_DIR}/traefik/users"

    require_file "${DATA_DIR}/traefik/users/dashboard.htpasswd"

    ok "Dashboard credentials OK."
}