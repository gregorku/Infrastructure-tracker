#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/deploy/summary.sh
#
# Description:
#   Deployment summary.
#
###############################################################################

###############################################################################
# Print deployment summary
###############################################################################

deploy_summary()
{
    print_section "Deployment completed"

    info "Repository : ${GIT_DIR}"
    info "Stack      : ${STACK_DIR}"

    echo

    info "Next step:"
    info "1. Open Dockge."
    info "2. Click Redeploy."

    ok "Deployment summary completed."
}