#!/usr/bin/env bash

set -euo pipefail

install_python_stack() {
  local manifest_path="$REPO_ROOT/manifests/uv-tools.txt"
  local entry
  local tool_name
  local python_version

  log_section "Installing Python via uv"

  command -v uv >/dev/null 2>&1 || activate_mise_tools uv

  require_command uv "uv is required after installation, but was not found on PATH."

  uv python install 3.12
  uv python pin 3.12
  uv python install --default 3.12

  log_section "Installing uv tools"
  while IFS= read -r entry; do
    tool_name="${entry%%|*}"
    python_version="${entry#*|}"

    if [[ "$tool_name" == "$python_version" ]]; then
      uv tool install "$tool_name"
    else
      uv python install "$python_version"
      uv tool install --python "$python_version" "$tool_name"
    fi
  done < <(read_manifest "$manifest_path")

  if [[ -n "${ZSH_VERSION:-}" ]]; then
    uv generate-shell-completion zsh
  fi
}