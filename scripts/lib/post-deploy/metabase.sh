#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/post-deploy/metabase.sh
#
# Description:
#   Verify Metabase after deployment.
#
###############################################################################

###############################################################################
# Verify Metabase
###############################################################################

post_deploy_metabase()
{
    print_section "Metabase"

    local db_user
    local db_name
    local timeout

    db_user="$(env_get METABASE_DB_USER)"
    db_name="$(env_get METABASE_DB_NAME)"

    ###########################################################################
    # Verify PostgreSQL container
    ###########################################################################

    require_container_running "${POSTGRES_METABASE_SERVICE}"

    ok "PostgreSQL container OK."

    ###########################################################################
    # Wait for PostgreSQL
    ###########################################################################

    info "Waiting for PostgreSQL..."

    timeout=60

    until docker_exec "${POSTGRES_METABASE_SERVICE}" \
        pg_isready \
        -U "${db_user}" \
        -d "${db_name}" >/dev/null 2>&1
    do
        ((timeout--))

        ((timeout > 0)) \
            || fail "PostgreSQL startup timeout."

        sleep 2
    done

    ok "PostgreSQL ready."

    ###########################################################################
    # Wait for Metabase
    ###########################################################################

    require_container_running "${METABASE_SERVICE}"

    ok "Metabase container OK."

    info "Waiting for Metabase..."

    timeout=60

    until docker_exec "${METABASE_SERVICE}" \
        wget -q --spider http://localhost:3000/api/health
    do
        ((timeout--))

        ((timeout > 0)) \
            || fail "Metabase startup timeout."

        sleep 2
    done

    ok "Metabase ready."
}