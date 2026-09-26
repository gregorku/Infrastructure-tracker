#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/post-deploy.sh
#
# Description:
#   Configure services after the stack is running.
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
# Environment library
###############################################################################

source "${SCRIPT_DIR}/lib/env/load.sh"

###############################################################################
# Post-deployment modules
###############################################################################

source "${SCRIPT_DIR}/lib/post-deploy/crowdsec.sh"
source "${SCRIPT_DIR}/lib/post-deploy/metabase.sh"
source "${SCRIPT_DIR}/lib/post-deploy/summary.sh"

###############################################################################
# Main
###############################################################################

print_header "Monitoring-Grafana post deployment"

#
# Verify environment.
#
check_environment

#
# Verify Docker.
#
check_docker_environment

#
# Configure CrowdSec.
#
post_deploy_crowdsec

#
# Configure Metabase.
#
post_deploy_metabase

#
# Print summary.
#
post_deploy_summary