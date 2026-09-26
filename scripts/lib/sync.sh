#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/sync.sh
#
# Description:
#   Synchronize files from Git repository to Docker stack directory.
#
###############################################################################

###############################################################################
# Synchronize one file or directory
#
# Usage:
#   sync_item compose.yml
#   sync_item compose
#   sync_item configs
#
###############################################################################

sync_item() {

    local item="$1"

    require_file_or_directory "${GIT_DIR}/${item}"

    rsync \
        -a \
        --delete \
        "${GIT_DIR}/${item}" \
        "${STACK_DIR}/"

    ok "Synced ${item}"
}

###############################################################################
# Synchronize complete stack
#
# Usage:
#   sync_stack
#
###############################################################################

sync_stack() {

    for item in "${DEPLOY_ITEMS[@]}"; do
        sync_item "${item}"
    done
}

###############################################################################
# Verify Git project
#
# Verify that all files and directories defined in DEPLOY_ITEMS exist.
#
###############################################################################

verify_project() {

    local item

    for item in "${DEPLOY_ITEMS[@]}"; do
        require_file_or_directory "${GIT_DIR}/${item}"
    done

    ok "Project structure OK."
}