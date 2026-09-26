#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/env/validate.sh
#
# Description:
#   Validate environment configuration.
#
###############################################################################

###############################################################################
# Validate environment file
###############################################################################

env_validate()
{
    declare -A ENV

    env_read_current ENV

    local variable

    for variable in "${!ENV_POLICY[@]}"
    do
        case "$(env_variable_policy "${variable}")" in

            generated)

                #
                # Generated variables are optional.
                #
                continue
                ;;

        esac

    [[ -v ENV["$variable"] ]] \
        || fail "Missing variable: ${variable}"

done
}