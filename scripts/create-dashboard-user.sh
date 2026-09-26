#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/create-dashboard-user.sh
#
# Description:
#   Create or update the Traefik Dashboard BasicAuth user.
#
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################################################
# Configuration
###############################################################################

source "${SCRIPT_DIR}/config.sh"

###############################################################################
# Libraries
###############################################################################

source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/filesystem.sh"

###############################################################################
# Configuration
###############################################################################

readonly USERS_DIR="${DATA_DIR}/traefik/users"
readonly HTPASSWD_FILE="${USERS_DIR}/dashboard.htpasswd"

###############################################################################
# Main
###############################################################################

print_section "Create Dashboard User"

check_environment

require_command htpasswd

###############################################################################
# Prepare directory
###############################################################################

ensure_directory "${USERS_DIR}"

###############################################################################
# Username
###############################################################################

read -rp "Username [admin]: " USERNAME

USERNAME="${USERNAME:-admin}"

###############################################################################
# Password
###############################################################################

echo
info "Creating password for '${USERNAME}'..."

htpasswd -cB "${HTPASSWD_FILE}" "${USERNAME}"

chmod 600 "${HTPASSWD_FILE}"

###############################################################################
# Finished
###############################################################################

echo

ok "Dashboard credentials updated."

info "User : ${USERNAME}"
info "File : ${HTPASSWD_FILE}"

echo

info "Next step:"
info "Redeploy the Monitoring-Grafana stack from Dockge."