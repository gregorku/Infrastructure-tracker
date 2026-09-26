#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana
#
# File:
#   scripts/update-env.sh
#
# Description:
#   Create or synchronize the project .env file.
#
# Workflow:
#   - Check environment.
#   - If .env does not exist:
#       * create it from .env.example
#       * inform the user
#       * finish successfully
#   - If .env exists:
#       * synchronize it with .env.example
#       * preserve existing values
#       * add new variables
#       * remove obsolete variables
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

###############################################################################
# Environment library
###############################################################################

source "${SCRIPT_DIR}/lib/env/load.sh"

###############################################################################
# Main
###############################################################################

print_header "Updating .env"

check_environment

env_sync

print_footer ".env ready."