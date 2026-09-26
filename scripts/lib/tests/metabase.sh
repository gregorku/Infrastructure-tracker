#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/tests/metabase.sh
#
# Description:
#   Test Metabase deployment.
#
###############################################################################

###############################################################################
# Test Metabase
###############################################################################

test_metabase()
{
    print_section "Metabase"

    ###########################################################################
    # PostgreSQL
    ###########################################################################

    require_container_running "${POSTGRES_METABASE_SERVICE}"

    ok "PostgreSQL container OK."

    ###########################################################################
    # Metabase
    ###########################################################################

    require_container_running "${METABASE_SERVICE}"

    ok "Metabase container OK."

    ###########################################################################
    # Directories
    ###########################################################################

    ensure_directory "${DATA_DIR}/metabase/postgres/data"

    ok "PostgreSQL data directory OK."

    ensure_directory "${DATA_DIR}/metabase/metabase/data"

    ok "Metabase data directory OK."

    ensure_directory "${DATA_DIR}/metabase/metabase/plugins"

    ok "Plugins directory OK."

    ensure_directory "${DATA_DIR}/metabase/metabase/logs"

    ok "Logs directory OK."

    ensure_directory "${DATA_DIR}/metabase/metabase/backups"

    ok "Backups directory OK."
}