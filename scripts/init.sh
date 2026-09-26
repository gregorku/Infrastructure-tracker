#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/init.sh
#
# Description:
#   Initialize Monitoring-Grafana project.
#
# Responsibilities:
#   - Verify environment
#   - Prepare project directories
#   - Prepare project stack
#   - Create Docker networks
#   - Prepare service layouts
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
source "${SCRIPT_DIR}/lib/filesystem.sh"
source "${SCRIPT_DIR}/lib/docker.sh"
source "${SCRIPT_DIR}/lib/git.sh"

###############################################################################
# Checks
###############################################################################

source "${SCRIPT_DIR}/lib/checks/load.sh"

###############################################################################
# Initialization modules
###############################################################################

source "${SCRIPT_DIR}/lib/init/directories.sh"
source "${SCRIPT_DIR}/lib/init/stack.sh"
source "${SCRIPT_DIR}/lib/init/networks.sh"
source "${SCRIPT_DIR}/lib/init/traefik.sh"
source "${SCRIPT_DIR}/lib/init/crowdsec.sh"
source "${SCRIPT_DIR}/lib/init/metabase.sh"
source "${SCRIPT_DIR}/lib/init/watchtower.sh"
source "${SCRIPT_DIR}/lib/init/summary.sh"

###############################################################################
# Main
###############################################################################

print_header "Monitoring-Grafana initialization"

#
# Verify environment.
#
check_environment

#
# Prepare project directories.
#
init_directories

#
# Prepare project stack.
#
init_stack

#
# Create Docker networks.
#
init_networks

#
# Prepare Traefik layout.
#
init_traefik

#
# Prepare CrowdSec layout.
#
init_crowdsec

#
# Prepare Metabase layout.
#
init_metabase

#
# Prepare Watchtower layout.
#
init_watchtower

#
# Print summary.
#
init_summary