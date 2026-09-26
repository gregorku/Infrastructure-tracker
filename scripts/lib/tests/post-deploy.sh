#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/tests/post-deploy.sh
#
# Description:
#   Verify post deployment configuration.
#
###############################################################################

###############################################################################
# Test post deployment
###############################################################################

test_post_deploy()
{
    print_section "Post Deployment"

    ###############################################################################
    # CrowdSec bouncer key
    ###############################################################################

    ensure_file "${CROWDSEC_BOUNCER_KEY_FILE}"

    ensure_file_mode "${CROWDSEC_BOUNCER_KEY_FILE}" 600

    ok "CrowdSec bouncer key OK."

    ###########################################################################
    # CrowdSec bouncer
    ###########################################################################

    if docker exec "${CROWDSEC_SERVICE}" \
        cscli bouncers list \
        | awk '{print $1}' \
        | grep -qx "${CROWDSEC_BOUNCER_NAME}"
    then
        ok "CrowdSec bouncer OK."
    else
        fail "CrowdSec bouncer missing."
    fi
}