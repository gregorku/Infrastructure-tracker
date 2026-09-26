#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/post-deploy/summary.sh
#
# Description:
#   Post-deployment summary.
#
###############################################################################

post_deploy_summary()
{
    print_footer "Post deployment completed."

    echo

    info "Next step:"
    info "  ./scripts/test.sh"

    echo
}