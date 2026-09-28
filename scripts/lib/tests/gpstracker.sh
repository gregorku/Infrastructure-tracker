#!/usr/bin/env bash

###############################################################################
# GPS Tracker
###############################################################################

test_gps_tracker()
{
    log_info "Testing GPS Tracker..."

    #
    # GPS_TRACKER_IMAGE/GPS_TRACKER_VERSION/GPS_DOMAIN/GPS_DATA_DIR live in
    # .env, which is consumed by Docker Compose via --env-file and is never
    # sourced into these scripts. Read the values we need with env_get()
    # instead of dereferencing them as (unset) shell variables.
    #

    local gps_tracker_image
    local gps_tracker_version
    local gps_domain
    local gps_data_dir

    gps_tracker_image="$(env_get "GPS_TRACKER_IMAGE")"
    gps_tracker_version="$(env_get "GPS_TRACKER_VERSION")"
    gps_domain="$(env_get "GPS_DOMAIN")"
    gps_data_dir="$(env_get "GPS_DATA_DIR")"

    local image="${gps_tracker_image}:${gps_tracker_version}"
    local container="gps-tracker"

    # -------------------------------------------------------------------------
    # Docker image
    # -------------------------------------------------------------------------

    if docker image inspect "${image}" >/dev/null 2>&1; then
        log_ok "GPS Tracker image exists: ${image}"
    else
        log_error "GPS Tracker image missing: ${image}"
        return 1
    fi

    # -------------------------------------------------------------------------
    # Container
    # -------------------------------------------------------------------------

    if docker container inspect "${container}" >/dev/null 2>&1; then
        log_ok "GPS Tracker container exists."
    else
        log_error "GPS Tracker container missing."
        return 1
    fi

    # -------------------------------------------------------------------------
    # Container state
    # -------------------------------------------------------------------------

    local state

    state="$(docker inspect \
        --format '{{.State.Status}}' \
        "${container}")"

    if [[ "${state}" == "running" ]]; then
        log_ok "GPS Tracker container is running."
    else
        log_error "GPS Tracker container is not running: ${state}"
        return 1
    fi

    # -------------------------------------------------------------------------
    # Health
    # -------------------------------------------------------------------------

    local health

    health="$(docker inspect \
        --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' \
        "${container}")"

    case "${health}" in
        healthy)
            log_ok "GPS Tracker healthcheck is healthy."
            ;;
        starting)
            log_warn "GPS Tracker healthcheck is still starting."
            ;;
        unhealthy)
            log_error "GPS Tracker healthcheck is unhealthy."
            return 1
            ;;
        none)
            log_warn "GPS Tracker has no healthcheck."
            ;;
        *)
            log_error "Unknown GPS Tracker health state: ${health}"
            return 1
            ;;
    esac

    # -------------------------------------------------------------------------
    # Docker networks
    # -------------------------------------------------------------------------

    if docker inspect \
        --format '{{json .NetworkSettings.Networks}}' \
        "${container}" |
        grep -q '"bridge-moje"'; then

        log_ok "GPS Tracker connected to bridge-moje."
    else
        log_error "GPS Tracker is not connected to bridge-moje."
        return 1
    fi

    if docker inspect \
        --format '{{json .NetworkSettings.Networks}}' \
        "${container}" |
        grep -q '"traefik-moje"'; then

        log_ok "GPS Tracker connected to traefik-moje."
    else
        log_error "GPS Tracker is not connected to traefik-moje."
        return 1
    fi

    # -------------------------------------------------------------------------
    # GPS domain
    # -------------------------------------------------------------------------

    if [[ -n "${gps_domain}" ]]; then
        log_ok "GPS Tracker domain configured: ${gps_domain}"
    else
        log_error "GPS_DOMAIN is not configured."
        return 1
    fi

    # -------------------------------------------------------------------------
    # GPS data directory
    # -------------------------------------------------------------------------

    if [[ -n "${gps_data_dir}" ]]; then
        log_ok "GPS Tracker data directory configured: ${gps_data_dir}"
    else
        log_error "GPS_DATA_DIR is not configured."
        return 1
    fi

    log_ok "GPS Tracker tests passed."
}