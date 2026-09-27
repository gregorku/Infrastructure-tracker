#!/usr/bin/env bash

###############################################################################
#
# GPS-tracker Project
#
# File:
#   scripts/lib/tests/compose.sh
#
# Description:
#   Docker Compose validation tests.
#
###############################################################################

###############################################################################
# Test Docker Compose
###############################################################################

test_compose()
{
    print_section "Docker Compose"

    check_compose_configuration
}