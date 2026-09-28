#!/usr/bin/env bash

###############################################################################
#
# GPS-tracker Project
#
# File:
#   scripts/lib/env/policy.sh
#
# Description:
#   Environment variable policies.
#
###############################################################################

###############################################################################
# Policies
#
# framework
#   Always synchronized from .env.example.
#
# user
#   Keep user value if already configured.
#
# generated
#   Never overwrite automatically generated values.
#
###############################################################################

declare -gA ENV_POLICY

###############################################################################
# General
###############################################################################

ENV_POLICY[TZ]="user"

###############################################################################
# Docker Compose
###############################################################################

ENV_POLICY[COMPOSE_PROJECT_NAME]="framework"

###############################################################################
# Traefik
###############################################################################

ENV_POLICY[TRAEFIK_VERSION]="framework"
ENV_POLICY[TRAEFIK_ACME_EMAIL]="user"
ENV_POLICY[TRAEFIK_DOMAIN]="user"

###############################################################################
# CrowdSec
###############################################################################

ENV_POLICY[CROWDSEC_VERSION]="framework"
ENV_POLICY[CROWDSEC_BOUNCER_KEY]="generated"

###############################################################################
# Metabase
###############################################################################

ENV_POLICY[METABASE_VERSION]="framework"

ENV_POLICY[PUBLIC_ADMIN_URL]="user"

ENV_POLICY[POSTGRES_VERSION]="framework"

ENV_POLICY[METABASE_DB_NAME]="user"
ENV_POLICY[METABASE_DB_USER]="user"
ENV_POLICY[METABASE_DB_PASSWORD]="user"

###############################################################################
# Watchtower
###############################################################################

ENV_POLICY[WATCHTOWER_VERSION]="framework"

###############################################################################
# GPS Tracker
###############################################################################

ENV_POLICY[GPS_TRACKER_IMAGE]="framework"
ENV_POLICY[GPS_TRACKER_VERSION]="framework"

ENV_POLICY[GPS_DOMAIN]="user"
ENV_POLICY[GPS_API_TOKEN]="user"
ENV_POLICY[GPS_DEFAULT_DEVICE_NAME]="user"
ENV_POLICY[GPS_ADMIN_USER]="user"
ENV_POLICY[GPS_ADMIN_PASSWORD]="user"

###############################################################################
# Static IP addresses
###############################################################################

ENV_POLICY[IP_TRAEFIK]="user"
ENV_POLICY[IP_CROWDSEC]="user"
ENV_POLICY[IP_METABASE]="user"

ENV_POLICY[IP_TRAEFIK_PUBLIC]="user"
ENV_POLICY[IP_GPS_TRACKER]="user"

###############################################################################
# Persistent data
###############################################################################

ENV_POLICY[DATA_DIR]="user"
ENV_POLICY[GPS_DATA_DIR]="user"

###############################################################################
# Logging
###############################################################################

ENV_POLICY[LOG_MAX_SIZE]="framework"
ENV_POLICY[LOG_MAX_FILES]="framework"

###############################################################################
# Return variable policy
#
# Arguments:
#   $1 - Variable name
#
###############################################################################

env_variable_policy()
{
    local variable="$1"

    printf '%s\n' "${ENV_POLICY[$variable]:-user}"
}

###############################################################################
# Variable exists in policy
#
# Arguments:
#   $1 - Variable name
#
###############################################################################

env_is_known_variable()
{
    local variable="$1"

    [[ -v ENV_POLICY["$variable"] ]]
}