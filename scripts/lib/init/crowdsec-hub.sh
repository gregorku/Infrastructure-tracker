#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/init/crowdsec-hub.sh
#
# Description:
#   Install and update CrowdSec collections.
#
###############################################################################

###############################################################################
# Required CrowdSec collections
###############################################################################

CROWDSEC_COLLECTIONS=(
    "crowdsecurity/linux"
    "crowdsecurity/sshd"
    "crowdsecurity/traefik"
    "crowdsecurity/whitelist-good-actors"
)

###############################################################################
# Install CrowdSec Hub collections
###############################################################################

init_crowdsec_hub()
{
    print_section "CrowdSec Hub"

    require_container_running "crowdsec"

    local collection

    for collection in "${CROWDSEC_COLLECTIONS[@]}"; do

        if docker_exec crowdsec \
            cscli collections inspect "${collection}" >/dev/null 2>&1; then

            ok "Collection already installed: ${collection}"

        else

            info "Installed collection ${collection}..."

            docker_exec crowdsec \
                cscli collections install "${collection}"

            ok "Installed collection: ${collection}"
        fi
    done
    ok "CrowdSec Hub ready."
}