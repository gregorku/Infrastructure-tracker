#!/usr/bin/env bash

###############################################################################
# GPS Tracker
###############################################################################

init_gpstracker()
{
    print_section "GPS Tracker"

    #
    # This step runs before update-env.sh, so .env may not exist yet.
    # GPS_TRACKER_IMAGE/GPS_TRACKER_VERSION are "framework" variables
    # (see scripts/lib/env/policy.sh) - their value in .env is always
    # synchronized from .env.example, so it is safe to read it directly
    # from .env.example here.
    #

    local image
    local version

    image="$(env_get_example "GPS_TRACKER_IMAGE")"
    version="$(env_get_example "GPS_TRACKER_VERSION")"

    [[ -n "${image}" ]] \
        || fail "GPS_TRACKER_IMAGE is not defined in .env.example."

    [[ -n "${version}" ]] \
        || fail "GPS_TRACKER_VERSION is not defined in .env.example."

    #
    # The container runs as the non-root user "gps" (uid/gid 10001), so the
    # bind-mounted data directory must be writable by it. Without this the
    # SQLite database cannot be created and the container restarts forever.
    #

    mkdir -p "${GPS_TRACKER_DIR}"
    chown -R 10001:10001 "${GPS_TRACKER_DIR}"
    chmod 750 "${GPS_TRACKER_DIR}"

    log_ok "Data directory ready: ${GPS_TRACKER_DIR} (uid 10001)"

    log_info "Preparing GPS Tracker image..."

    docker build \
        -t "${image}:${version}" \
        "${STACK_DIR}/gps-tracker"

    log_ok "GPS Tracker image ready: ${image}:${version}"
}
