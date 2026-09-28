#!/usr/bin/env bash

###############################################################################
#
# GPS-tracker Project
#
# File:
#   scripts/lib/env/reader.sh
#
# Description:
#   Read environment configuration files.
#
# Responsibilities:
#   - Read .env.example
#   - Read .env
#   - Read arbitrary environment file
#
###############################################################################

###############################################################################
# Read environment file
#
# Arguments:
#   $1 - Environment file
#   $2 - Name of associative array
#
###############################################################################

env_read_file()
{
    local file="$1"
    local array_name="$2"

    env_parse_file "${file}" "${array_name}"
}

###############################################################################
# Read .env.example
#
# Arguments:
#   $1 - Name of associative array
#
###############################################################################

env_read_example()
{
    local array_name="$1"

    env_read_file \
        "${STACK_DIR}/.env.example" \
        "${array_name}"
}

###############################################################################
# Read .env
#
# Arguments:
#   $1 - Name of associative array
#
###############################################################################

env_read_current()
{
    local array_name="$1"

    env_read_file \
        "${STACK_DIR}/.env" \
        "${array_name}"
}

###############################################################################
# Load environment
#
# Description:
#   Load variables from .env into the current shell.
#
###############################################################################

env_load()
{
    [[ -f "${ENV_FILE}" ]] \
        || fail ".env not found."

    set -a

    # shellcheck disable=SC1090
    source "${ENV_FILE}"

    set +a
}

###############################################################################
# Get a single variable from an arbitrary environment file
#
# Description:
#   Reads one KEY=VALUE pair without sourcing the file, so it is safe
#   to call even under `set -u` and even before the file has been
#   loaded (or before it exists as a full shell environment).
#
# Arguments:
#   $1 - Environment file
#   $2 - Variable name
#
# Returns:
#   Variable value, or an empty string if not found
#
###############################################################################

env_get_from()
{
    local file="$1"
    local key="$2"

    [[ -f "${file}" ]] \
        || fail "Environment file not found: ${file}"

    awk -F= -v key="${key}" '
        $1 == key {
            print substr($0, index($0, "=") + 1)
            exit
        }
    ' "${file}"
}

###############################################################################
# Get environment variable
#
# Arguments:
#   $1 - Variable name
#
# Returns:
#   Variable value from .env
#
###############################################################################

env_get()
{
    local key="$1"

    env_get_from "${ENV_FILE}" "${key}"
}

###############################################################################
# Get environment variable from .env.example
#
# Description:
#   Used where a value is needed before .env has been created (e.g.
#   during ./scripts/init.sh, which runs before ./scripts/update-env.sh).
#   Only safe for "framework" policy variables, whose value in .env is
#   always synchronized from .env.example anyway.
#
# Arguments:
#   $1 - Variable name
#
# Returns:
#   Variable value from .env.example
#
###############################################################################

env_get_example()
{
    local key="$1"

    env_get_from "${ENV_EXAMPLE_FILE}" "${key}"
}