#!/usr/bin/env bash

set -euo pipefail

sync_dotfiles_and_skills() {
  local action="${1:-check}"
  local quiet="${2:-}"

  if [[ "$action" == "--quiet" ]]; then
    action="check"
    quiet="--quiet"
  fi

  case "$action" in
    check|pull|reinject)
      ;;
    *)
      echo "Unknown sync action: $action" >&2
      echo "Use one of: check, pull, reinject" >&2
      return 1
      ;;
  esac

  [[ -z "$quiet" || "$quiet" == "--quiet" ]] || {
    echo "Unknown sync option: $quiet" >&2
    return 1
  }
  DOTFILES_SYNC_QUIET="$quiet"

  require_command git "Git is required to check for updates."

  if [[ "$action" == "reinject" ]]; then
    install_skills
    return 0
  fi

  if [[ "$action" == "pull" ]] && ! git_worktree_is_clean "$REPO_ROOT"; then
    sync_notice "dotfiles has local changes; not pulling because skill pins would need updating."
    return 1
  fi

  sync_git_repository "$REPO_ROOT" "dotfiles" "$action"
  sync_authored_skill_repositories "$action"

  if [[ "$action" == "pull" ]]; then
    update_authored_skills_lock
    install_skills
  else
    report_missing_authored_skill_links
  fi
}

sync_authored_skill_repositories() {
  local action="$1"
  local entry package commit scope agents skill_names repository

  while IFS= read -r entry; do
    IFS='|' read -r package commit scope agents skill_names <<< "$entry"
    repository="$(authored_skill_repo_path "$package")"

    if [[ ! -d "$repository/.git" && "$action" == "pull" ]]; then
      mkdir -p "$AUTHORED_SKILLS_ROOT"
      git clone --quiet "$package" "$repository"
      sync_status "Installed $repository."
    fi

    sync_git_repository "$repository" "$(basename "$repository") skills" "$action"
  done < <(read_manifest "$REPO_ROOT/manifests/skills.lock")
}

sync_git_repository() {
  local repository="$1"
  local label="$2"
  local action="$3"
  local upstream local_commit upstream_commit

  if [[ ! -d "$repository/.git" ]]; then
    sync_notice "$label is not installed: $repository"
    return 0
  fi

  if ! git -C "$repository" remote get-url origin >/dev/null 2>&1; then
    sync_notice "$label has no origin remote: $repository"
    return 0
  fi

  if ! git -C "$repository" fetch --quiet --prune origin; then
    sync_notice "Could not check $label for updates."
    return 0
  fi

  upstream="$(git -C "$repository" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"
  [[ -n "$upstream" ]] || upstream="$(git -C "$repository" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [[ -z "$upstream" ]] || ! git -C "$repository" rev-parse --verify --quiet "$upstream" >/dev/null; then
    sync_notice "Could not determine the tracked branch for $label."
    return 0
  fi

  if ! git_worktree_is_clean "$repository"; then
    sync_notice "$label has local changes; leaving it untouched."
    return 0
  fi

  local_commit="$(git -C "$repository" rev-parse HEAD)"
  upstream_commit="$(git -C "$repository" rev-parse "$upstream")"
  if [[ "$local_commit" == "$upstream_commit" ]]; then
    sync_status "$label is up to date."
  elif git -C "$repository" merge-base --is-ancestor "$local_commit" "$upstream_commit"; then
    if [[ "$action" == "pull" ]]; then
      git -C "$repository" merge --ff-only "$upstream"
      sync_status "Updated $label."
    else
      sync_notice "$label has an update ready. Run: dotfiles-sync pull"
    fi
  elif git -C "$repository" merge-base --is-ancestor "$upstream_commit" "$local_commit"; then
    sync_notice "$label is ahead of its remote; leaving it untouched."
  else
    sync_notice "$label has diverged from its remote; leaving it untouched."
  fi
}

git_worktree_is_clean() {
  local repository="$1"

  git -C "$repository" diff --quiet &&
    git -C "$repository" diff --cached --quiet &&
    [[ -z "$(git -C "$repository" ls-files --others --exclude-standard)" ]]
}

authored_skill_repo_path() {
  local package="$1"
  printf '%s/%s\n' "$AUTHORED_SKILLS_ROOT" "$(basename "$package" .git)"
}

update_authored_skills_lock() {
  local manifest_path="$REPO_ROOT/manifests/skills.lock"
  local temporary_manifest line package commit scope agents skill_names repository current_commit

  temporary_manifest="$(mktemp)"
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
      printf '%s\n' "$line" >> "$temporary_manifest"
      continue
    fi

    IFS='|' read -r package commit scope agents skill_names <<< "$line"
    repository="$(authored_skill_repo_path "$package")"
    current_commit="$(git -C "$repository" rev-parse HEAD)"
    [[ "$commit" == "$current_commit" ]] || sync_status "Pinned $package to $current_commit."
    printf '%s|%s|%s|%s|%s\n' "$package" "$current_commit" "$scope" "$agents" "$skill_names" >> "$temporary_manifest"
  done < "$manifest_path"

  mv "$temporary_manifest" "$manifest_path"
}

report_missing_authored_skill_links() {
  local entry package commit scope agents skill_names repository skill_file source_dir skill_name target_dir
  local missing=0

  while IFS= read -r entry; do
    IFS='|' read -r package commit scope agents skill_names <<< "$entry"
    repository="$(authored_skill_repo_path "$package")"
    [[ -d "$repository/.git" ]] || continue

    while IFS= read -r skill_file; do
      source_dir="$(dirname "$skill_file")"
      skill_name="$(basename "$source_dir")"
      is_requested_skill "$skill_name" "$skill_names" || continue
      target_dir="$HOME/.agents/skills/$skill_name"
      [[ -L "$target_dir" && "$(readlink "$target_dir")" == "$source_dir" ]] && continue
      sync_notice "Skill link needs reinjection: $skill_name. Run: dotfiles-sync reinject"
      missing=1
    done < <(find "$repository" -path '*/SKILL.md' -type f | sort)
  done < <(read_manifest "$REPO_ROOT/manifests/skills.lock")

  [[ "$missing" == "0" ]] && sync_status "Authored skill links are up to date."
}

sync_status() {
  [[ "${DOTFILES_SYNC_QUIET:-}" == "--quiet" ]] || printf '%s\n' "$1"
}

sync_notice() {
  printf '%s\n' "$1"
}