#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/deploy/sync.sh
#
# Description:
#   Synchronize the Monitoring-Grafana repository to the Docker stack directory.
#
###############################################################################

###############################################################################
# Synchronize one file or directory
#
# Arguments:
#   $1 - File or directory relative to GIT_DIR
#
###############################################################################

deploy_sync_item()
{
    local item="$1"

    require_file_or_directory "${GIT_DIR}/${item}"

    rsync \
        --archive \
        --delete \
        "${GIT_DIR}/${item}" \
        "${STACK_DIR}/"

    ok "Synchronized: ${item}"
}

###############################################################################
# Synchronize complete stack
###############################################################################

deploy_sync_stack()
{
    print_section "Synchronizing stack"

    require_directory "${STACK_DIR}"

    local item

    for item in "${DEPLOY_ITEMS[@]}"; do
        deploy_sync_item "${item}"
    done

    ###########################################################################
    # Create .env on first deployment
    ###########################################################################

    if [[ ! -f "${STACK_DIR}/.env" ]]; then

        require_file "${STACK_DIR}/.env.example"

        cp \
            "${STACK_DIR}/.env.example" \
            "${STACK_DIR}/.env"

        ok ".env created from .env.example"

    fi

    ###########################################################################
    # Verify synchronized stack
    ###########################################################################

    require_file "${STACK_DIR}/compose.yml"

    require_directory "${STACK_DIR}/compose"
    require_directory "${STACK_DIR}/configs"

    require_file "${STACK_DIR}/.env.example"

    ok "Stack synchronized."
}