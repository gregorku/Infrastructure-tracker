#!/usr/bin/env bash

###############################################################################
#
# GPS-tracker Project
#
# File:
#   scripts/lib/tests/summary.sh
#
# Description:
#   Print GPS-tracker test summary.
#
###############################################################################

###############################################################################
# Test summary
###############################################################################

test_summary()
{
    print_section "Finished"

    ok "GPS-tracker tests completed."

    echo

    info "Review the output above for warnings or failures."

    echo

    ok "Test summary completed."
}