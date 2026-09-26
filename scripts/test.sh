#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/test.sh
#
# Description:
#   Run Monitoring-Grafana framework tests.
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

###############################################################################
# Checks library
###############################################################################

source "${SCRIPT_DIR}/lib/checks/load.sh"

###############################################################################
# Environment library
###############################################################################

source "${SCRIPT_DIR}/lib/env/load.sh"

###############################################################################
# Test modules
###############################################################################

source "${SCRIPT_DIR}/lib/tests/project.sh"
source "${SCRIPT_DIR}/lib/tests/stack.sh"
source "${SCRIPT_DIR}/lib/tests/environment.sh"
source "${SCRIPT_DIR}/lib/tests/compose.sh"
source "${SCRIPT_DIR}/lib/tests/docker.sh"
source "${SCRIPT_DIR}/lib/tests/dockge.sh"
source "${SCRIPT_DIR}/lib/tests/networks.sh"
source "${SCRIPT_DIR}/lib/tests/dashboard-security.sh"

###############################################################################
# Services
###############################################################################

source "${SCRIPT_DIR}/lib/tests/traefik.sh"
source "${SCRIPT_DIR}/lib/tests/crowdsec.sh"
source "${SCRIPT_DIR}/lib/tests/metabase.sh"
source "${SCRIPT_DIR}/lib/tests/post-deploy.sh"
source "${SCRIPT_DIR}/lib/tests/watchtower.sh"
source "${SCRIPT_DIR}/lib/tests/summary.sh"

###############################################################################
# Main
###############################################################################

print_header "Monitoring-Grafana test"

check_environment
check_docker_environment

test_project
test_stack
test_environment
test_compose
test_docker
test_dockge
test_networks
test_dashboard_security

###############################################################################
# Services
###############################################################################

#
# Traefik
#
test_traefik
#
# CrowdSec
#
test_crowdsec

#
# Metabase
#
test_metabase

#
# Watchtower
#
test_watchtower

#
# Post deployment
#
test_post_deploy

test_summary