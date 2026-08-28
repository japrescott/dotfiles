#!/usr/bin/env bash

set -euo pipefail

install_node_stack() {
  local nvm_dir="$HOME/.nvm"
  local manifest_path="$REPO_ROOT/manifests/npm-global.txt"
  local package_name

  log_section "Installing Node.js via nvm"

  if [[ ! -d "$nvm_dir" ]]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  fi

  export NVM_DIR="$nvm_dir"
  # shellcheck disable=SC1090
  source "$NVM_DIR/nvm.sh"

  nvm install --lts
  nvm use --lts

  log_section "Installing global npm packages"
  while IFS= read -r package_name; do
    npm install -g "$package_name"
  done < <(read_manifest "$manifest_path")
}