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