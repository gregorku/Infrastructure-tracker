#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/env/writer.sh
#
# Description:
#   Environment file writer.
#
# Responsibilities:
#   - Backup current .env
#   - Create temporary .env
#   - Write synchronized .env
#   - Replace original .env
#
###############################################################################

###############################################################################
# Backup file
#
# Arguments:
#   $1 - Source file
#   $2 - Backup prefix
#
###############################################################################

backup_file()
{
    local source="$1"
    local prefix="$2"

    [[ -f "${source}" ]] || return

    local backup

    backup="${prefix}-$(date +%Y%m%d-%H%M%S)"

    cp "${source}" "${backup}"

    ok "Backup created: $(basename "${backup}")"
}

###############################################################################
# Write synchronized environment
#
# Arguments:
#   stdin - Complete .env content
#
###############################################################################

env_write_file()
{
    backup_file "${ENV_FILE}" "${ENV_BACKUP_PREFIX}"

    cat > "${ENV_TMP_FILE}"

    mv "${ENV_TMP_FILE}" "${ENV_FILE}"

    ok ".env written."
}