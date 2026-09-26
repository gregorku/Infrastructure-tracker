#!/usr/bin/env bash
###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/tests/environment.sh
#
# Description:
#   Environment validation tests.
#
###############################################################################

test_environment()
{
    print_section ".env"

    require_file "${STACK_DIR}/.env"

    ok ".env OK."
}