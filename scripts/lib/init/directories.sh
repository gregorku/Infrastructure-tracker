#!/usr/bin/env bash

###############################################################################
#
# GPS-tracker Project
#
# File:
#   scripts/lib/init/directories.sh
#
# Description:
#   Prepare common GPS-tracker directories.
#
# Responsibilities:
#   - Create shared data directory
#   - Create service data directories
#
# Notes:
#   Docker Compose stack files are prepared by:
#       scripts/lib/init/stack.sh
#
###############################################################################

###############################################################################
# Initialize project directories
###############################################################################

init_directories()
{
    log_step "Project directories"

    #
    # Common data directory
    #
    ensure_directory "${DATA_DIR}"

    #
    # Service directories
    #
    ensure_directory "${TRAEFIK_DIR}"
    ensure_directory "${CROWDSEC_DIR}"
    ensure_directory "${WATCHTOWER_DIR}"
    ensure_directory "${METABASE_DIR}"
    ensure_directory "${GPS_TRACKER_DIR}"

    log_success "Project directories ready."
}