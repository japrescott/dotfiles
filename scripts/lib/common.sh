#!/usr/bin/env bash

set -euo pipefail

log_section() {
  local message="$1"
  printf '\n----------------------------\n%s\n' "$message"
}

read_manifest() {
  local manifest_path="$1"

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    printf '%s\n' "$line"
  done < "$manifest_path"
}

require_command() {
  local command_name="$1"
  local help_message="$2"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "$help_message" >&2
    exit 1
  fi
}

# Installs the named tools at the versions pinned in the repo's mise config and
# puts them on PATH for the rest of this run. Interactive shells get the same
# versions through `mise activate` in import.
activate_mise_tools() {
  require_command mise "mise is required. On macOS run ./install.sh packages; on Ubuntu install it from https://mise.jdx.dev/installing-mise.html#apt."

  export MISE_GLOBAL_CONFIG_FILE="$REPO_ROOT/.config/mise/config.toml"
  mise install "$@"
  eval "$(mise env --shell bash)"
}
