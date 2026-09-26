#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/init/metabase.sh
#
# Description:
#   Initialize Metabase directories.
#
###############################################################################

init_metabase()
{
    print_section "Metabase"

    #
    # PostgreSQL
    #

    ensure_directory "${METABASE_DIR}/postgres"
    ensure_directory "${METABASE_DIR}/postgres/data"

    #
    # Metabase
    #

    ensure_directory "${METABASE_DIR}/metabase"
    ensure_directory "${METABASE_DIR}/metabase/data"
    ensure_directory "${METABASE_DIR}/metabase/plugins"
    ensure_directory "${METABASE_DIR}/metabase/logs"
    ensure_directory "${METABASE_DIR}/metabase/backups"

    ok "Metabase layout ready."
}