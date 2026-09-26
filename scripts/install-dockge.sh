#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/install-dockge.sh
#
# Description:
#   Creates a fresh Dockge container.
#
# Notes:
#   - Uses configuration from scripts/config.sh.
#   - Stores Dockge data in ${DOCKGE_DATA_DIR}.
#   - Uses ${STACKS_DIR} as the Dockge stacks directory.
#   - Existing Dockge container is removed before installation.
#
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/config.sh
source "${SCRIPT_DIR}/config.sh"

###############################################################################
# Remove existing container
###############################################################################

docker stop "${DOCKGE_CONTAINER}" >/dev/null 2>&1 || true
docker rm   "${DOCKGE_CONTAINER}" >/dev/null 2>&1 || true

###############################################################################
# Create required directories
###############################################################################

mkdir -p "${DOCKGE_DATA_DIR}"
mkdir -p "${STACKS_DIR}"

###############################################################################
# Start Dockge
###############################################################################

docker run -d \
    --name "${DOCKGE_CONTAINER}" \
    --restart unless-stopped \
    -p "${DOCKGE_PORT}:5001" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "${DOCKGE_DATA_DIR}:/app/data" \
    -v "${STACKS_DIR}:${STACKS_DIR}" \
    -e DOCKGE_STACKS_DIR="${STACKS_DIR}" \
    "${DOCKGE_IMAGE}"

###############################################################################
# Summary
###############################################################################

echo
echo "Dockge installed successfully."
echo
echo "Container : ${DOCKGE_CONTAINER}"
echo "Image     : ${DOCKGE_IMAGE}"
echo "Port      : ${DOCKGE_PORT}"
echo "Data dir  : ${DOCKGE_DATA_DIR}"
echo "Stacks    : ${STACKS_DIR}"
echo
echo "Open:"
echo "  http://<server>:${DOCKGE_PORT}"