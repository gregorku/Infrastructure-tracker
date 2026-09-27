#!/usr/bin/env bash

###############################################################################
# GPS Tracker
###############################################################################

init_gpstracker()
{
    log_info "Preparing GPS Tracker image..."

    docker build \
        -t "${GPS_TRACKER_IMAGE}:${GPS_TRACKER_VERSION}" \
        "${STACK_DIR}/gps-tracker"

    log_ok "GPS Tracker image ready."
}