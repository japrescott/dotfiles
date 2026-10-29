#!/usr/bin/env bash

set -euo pipefail

init_git_submodules() {
  log_section "Initializing git submodules"
  git -C "$REPO_ROOT" submodule update --init --recursive
}