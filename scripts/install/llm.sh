#!/usr/bin/env bash

set -euo pipefail

install_llm_runtime_links() {
  local manifest_path="$REPO_ROOT/manifests/llm-runtimes.txt"
  local runtime

  log_section "Linking managed LLM runtime files"

  while IFS= read -r runtime; do
    install_llm_runtime_manifest "$runtime"
  done < <(read_manifest "$manifest_path")
}

import_llm_runtime_files() {
  local manifest_path="$REPO_ROOT/manifests/llm-runtimes.txt"
  local runtime

  log_section "Importing existing LLM runtime files into the repo"

  while IFS= read -r runtime; do
    import_llm_runtime_manifest "$runtime"
  done < <(read_manifest "$manifest_path")
}

install_llm_runtime_manifest() {
  local runtime="$1"
  local manifest_path="$REPO_ROOT/manifests/llm-${runtime}-links.txt"
  local entry
  local source_path
  local target_path

  if [[ ! -f "$manifest_path" ]]; then
    echo "Missing LLM manifest for runtime: $runtime" >&2
    exit 1
  fi

  log_section "Linking $runtime runtime files"

  while IFS= read -r entry; do
    source_path="${entry%%|*}"
    target_path="${entry#*|}"
    link_dotfile "$REPO_ROOT/$source_path" "$HOME/$target_path"
  done < <(read_manifest "$manifest_path")
}

import_llm_runtime_manifest() {
  local runtime="$1"
  local manifest_path="$REPO_ROOT/manifests/llm-${runtime}-links.txt"
  local entry
  local source_path
  local target_path

  if [[ ! -f "$manifest_path" ]]; then
    echo "Missing LLM manifest for runtime: $runtime" >&2
    exit 1
  fi

  log_section "Importing $runtime runtime files"

  while IFS= read -r entry; do
    source_path="${entry%%|*}"
    target_path="${entry#*|}"
    import_llm_path "$REPO_ROOT/$source_path" "$HOME/$target_path"
  done < <(read_manifest "$manifest_path")
}

import_llm_path() {
  local source_path="$1"
  local target_path="$2"
  local backup_path

  if [[ ! -e "$target_path" && ! -L "$target_path" ]]; then
    echo "No local path to import: $target_path"
    return
  fi

  if [[ -L "$target_path" ]]; then
    local existing_target
    existing_target="$(readlink "$target_path")"
    if [[ "$existing_target" == "$source_path" ]]; then
      echo "Already managed by dotfiles: $target_path"
      return
    fi
  fi

  if [[ -e "$source_path" || -L "$source_path" ]]; then
    backup_path="${source_path}.pre-import.$(date +%Y%m%d%H%M%S)"
    mv "$source_path" "$backup_path"
    echo "Backed up repo source $source_path to $backup_path"
  fi

  mkdir -p "$(dirname "$source_path")"

  if [[ -d "$target_path" && ! -L "$target_path" ]]; then
    cp -R -L "$target_path" "$source_path"
  else
    cp -L "$target_path" "$source_path"
  fi

  echo "Imported $target_path -> $source_path"
}