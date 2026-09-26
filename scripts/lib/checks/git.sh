#!/usr/bin/env bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   scripts/lib/checks/git.sh
#
# Description:
#   Git validation functions.
#
###############################################################################

###############################################################################
# Require Git
###############################################################################

require_git()
{
    require_command git
}

###############################################################################
# Verify Git repository
###############################################################################

check_git_repository()
{
    git -C "${PROJECT_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
        || fail "Project directory is not a Git repository."
}

###############################################################################
# Verify Git working tree
###############################################################################

check_git_worktree()
{
    git -C "${PROJECT_ROOT}" diff --quiet \
        || fail "Working tree contains uncommitted changes."

    git -C "${PROJECT_ROOT}" diff --cached --quiet \
        || fail "Index contains staged but uncommitted changes."
}

###############################################################################
# Verify Git environment
###############################################################################

check_git_environment()
{
    check_environment

    require_git

    check_git_repository

    ok "Git environment OK."
}