#!/usr/bin/env bash

set -euo pipefail

install_dotfile_links() {
  local manifest_path="$REPO_ROOT/manifests/links.txt"
  local entry
  local source_path
  local target_path

  log_section "Creating dotfile symlinks"

  while IFS= read -r entry; do
    source_path="${entry%%|*}"
    target_path="${entry#*|}"
    link_dotfile "$REPO_ROOT/$source_path" "$HOME/$target_path"
  done < <(read_manifest "$manifest_path")
}

link_dotfile() {
  local source_path="$1"
  local target_path="$2"
  local backup_path

  mkdir -p "$(dirname "$target_path")"

  if [[ -L "$target_path" ]]; then
    local existing_target
    existing_target="$(readlink "$target_path")"
    if [[ "$existing_target" == "$source_path" ]]; then
      echo "Link already up to date: $target_path"
      return
    fi
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    if [[ "${DOTFILES_OVERWRITE:-0}" != "1" ]]; then
      echo "Warning: existing path left untouched: $target_path"
      echo "  Import or reconcile it with $source_path before linking."
      echo "  Rerun with DOTFILES_OVERWRITE=1 to back it up and replace it."
      return
    fi

    backup_path="${target_path}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$target_path" "$backup_path"
    echo "Backed up $target_path to $backup_path"
  fi

  ln -s "$source_path" "$target_path"
  echo "Linked $target_path -> $source_path"
}