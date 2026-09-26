#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/tests/summary.sh
#
# Description:
#   Print Monitoring-Grafana test summary.
#
###############################################################################

###############################################################################
# Test summary
###############################################################################

test_summary()
{
    print_section "Finished"

    ok "Monitoring-Grafana tests completed."

    echo

    info "Review the output above for warnings or failures."

    echo

    ok "Test summary completed."
}