#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/env/sync.sh
#
# Description:
#   Create or synchronize .env with .env.example.
#
# Responsibilities:
#   - Create .env on first run
#   - Preserve user values
#   - Preserve comments
#   - Preserve blank lines
#   - Preserve variable order
#   - Apply environment policy
#
###############################################################################

###############################################################################
# Synchronize environment
###############################################################################

env_sync()
{
    ###########################################################################
    # First run
    ###########################################################################

    if [[ ! -f "${ENV_FILE}" ]]; then

        log_info "Environment file not found."
        log_info "Creating .env from .env.example..."

        cp "${ENV_EXAMPLE_FILE}" "${ENV_FILE}"

        log_success "Environment file created."
        log_warn "Please edit '${ENV_FILE}' before running deploy.sh."

        return 0
    fi

    ###########################################################################
    # Load current environment
    ###########################################################################

    declare -A ENV_CURRENT
    declare -A ENV_EXAMPLE

    env_read_current ENV_CURRENT
    env_read_example ENV_EXAMPLE

    local output=""
    local line
    local key
    local example_value
    local current_value
    local value
    local policy
    local differences=0

    log_info "Synchronizing .env..."

    while IFS= read -r line || [[ -n "${line}" ]]; do

        #######################################################################
        # Preserve blank lines
        #######################################################################

        if [[ -z "${line}" ]]; then
            output+=$'\n'
            continue
        fi

        #######################################################################
        # Preserve comments
        #######################################################################

        if [[ "${line}" =~ ^[[:space:]]*# ]]; then
            output+="${line}"$'\n'
            continue
        fi

        #######################################################################
        # Ignore invalid lines
        #######################################################################

        [[ "${line}" == *=* ]] || continue

        #######################################################################
        # Parse variable
        #######################################################################

        key="${line%%=*}"
        example_value="${line#*=}"

        policy="$(env_variable_policy "${key}")"
        current_value="${ENV_CURRENT[$key]-}"

        #######################################################################
        # Apply policy
        #######################################################################

        case "${policy}" in

            framework)
                value="${example_value}"
                ;;

            user|generated)

                if [[ -n "${current_value}" ]]; then
                    value="${current_value}"
                else
                    value="${example_value}"
                fi
                ;;

            *)

                fail "Unknown environment policy: ${policy}"
                ;;

        esac

        #######################################################################
        # Report differences
        #######################################################################

        if [[ "${policy}" == "user" ]] \
            && [[ -n "${current_value}" ]] \
            && [[ "${current_value}" != "${example_value}" ]]; then

            log_info "${key} differs"

            printf "       .env         : %s\n" "${current_value}"
            printf "       .env.example : %s\n" "${example_value}"
            printf "       Keeping user value.\n\n"

            ((differences++))
        fi

        output+="${key}=${value}"$'\n'

    done < "${ENV_EXAMPLE_FILE}"

    ###########################################################################
    # Summary
    ###########################################################################

    if (( differences == 0 )); then
        log_success "No user variable differences found."
    elif (( differences == 1 )); then
        log_info "1 user variable differs from .env.example."
    else
        log_info "${differences} user variables differ from .env.example."
    fi

    env_write_file <<< "${output}"

    log_success ".env synchronized."
}