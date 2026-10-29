#!/usr/bin/env bash

set -euo pipefail

install_node_stack() {
  local manifest_path="$REPO_ROOT/manifests/npm-global.txt"
  local package_name

  log_section "Installing Node.js via mise"

  activate_mise_tools node

  log_section "Installing global npm packages"
  while IFS= read -r package_name; do
    npm install -g "$package_name"
  done < <(read_manifest "$manifest_path")
}
