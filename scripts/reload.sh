#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/reload.sh
#
# Description:
#   Reload Monitoring-Grafana containers.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Directories
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################################################
# Configuration
###############################################################################

source "${SCRIPT_DIR}/config.sh"

###############################################################################
# Core libraries
###############################################################################

source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/docker-compose.sh"

###############################################################################
# Help
###############################################################################

show_help()
{
cat <<EOF
Monitoring-Grafana Project

Usage:

    ./scripts/reload.sh [OPTION]

Options:

    --pull
        Pull Docker images before reload.

    -h, --help
        Show this help.

Description:

    Reload the Monitoring-Grafana Docker stack.

EOF
}

###############################################################################
# Main
###############################################################################

case "${1:-}" in
    "")
        ;;
    --pull)
        print_header "Pulling Docker images"

        compose_cmd pull
        ;;
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        fail "Unknown option: ${1}"
        ;;
esac

print_header "Monitoring-Grafana reload"

###############################################################################
# Deploy
###############################################################################

"${SCRIPT_DIR}/deploy.sh"

###############################################################################
# Reload containers
###############################################################################

print_section "Reload containers"

compose_reload

ok "Containers recreated."

###############################################################################
# Post deployment
###############################################################################

"${SCRIPT_DIR}/post-deploy.sh"

###############################################################################
# Tests
###############################################################################

"${SCRIPT_DIR}/test.sh"

print_footer "Reload finished."