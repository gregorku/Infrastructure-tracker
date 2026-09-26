#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/tests/watchtower.sh
#
# Description:
#   Verify Watchtower deployment.
#
###############################################################################

###############################################################################
# Test Watchtower
###############################################################################

test_watchtower()
{
    print_section "Watchtower"

    ###########################################################################
    # Check if Watchtower is enabled
    ###########################################################################

    if ! docker_container_exists "${WATCHTOWER_SERVICE}"
    then
        info "Watchtower is not deployed."

        return 0
    fi

    ###########################################################################
    # Verify container
    ###########################################################################

    require_container_running "${WATCHTOWER_SERVICE}"

    ok "Watchtower container OK."

    ###########################################################################
    # Placeholder
    ###########################################################################

    info "Additional Watchtower tests are not implemented yet."

    ok "Watchtower test completed."
}