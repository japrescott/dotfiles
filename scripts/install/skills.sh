#!/usr/bin/env bash

set -euo pipefail

SKILLS_CLI_VERSION="1.5.23"
AUTHORED_SKILLS_ROOT="${AUTHORED_SKILLS_ROOT:-$HOME/Programming}"

install_skills() {
  local manifest_path="$REPO_ROOT/manifests/skills.lock"
  local entry
  local package
  local commit
  local scope
  local agents
  local skill_names
  local checkout_dir

  log_section "Linking pinned authored skills"
  require_command git "Git is required to install pinned skill sources."

  while IFS= read -r entry; do
    IFS='|' read -r package commit scope agents skill_names <<< "$entry"
    validate_skill_lock_entry "$package" "$commit" "$scope" "$agents" "$skill_names"
    [[ "$scope" == "global" ]] || {
      echo "Shared skill packages must use global scope: $package" >&2
      exit 1
    }
    checkout_dir="$(ensure_authored_skill_repo "$package" "$commit")"
    preflight_skill_package "$checkout_dir" "$package" "$commit" "$skill_names"
    link_authored_skill_entries "$checkout_dir" "$skill_names"
  done < <(read_manifest "$manifest_path")
}

install_project_skills() {
  local manifest_path="$REPO_ROOT/manifests/skills-projects.lock"
  local entry
  local project_path
  local package
  local commit
  local agents
  local skill_names
  local checkout_dir

  log_section "Installing pinned project skills"
  require_command npx "Node.js and npx are required to install skills. Run ./install.sh node first."
  require_command git "Git is required to verify pinned skill sources."

  while IFS= read -r entry; do
    IFS='|' read -r project_path package commit agents skill_names <<< "$entry"
    [[ -d "$project_path" ]] || {
      echo "Project path does not exist: $project_path" >&2
      exit 1
    }
    validate_skill_lock_entry "$package" "$commit" "project" "$agents" "$skill_names"
    checkout_dir="$(checkout_pinned_skill_package "$package" "$commit")"
    preflight_skill_package "$checkout_dir" "$package" "$commit" "$skill_names"
    (
      cd "$project_path"
      npx -y "skills@$SKILLS_CLI_VERSION" add "$checkout_dir" --agent "$agents" --skill "$skill_names" --yes </dev/null
    )
  done < <(read_manifest "$manifest_path")
}

install_skills_from_manifest() {
  local manifest_path="$1"
  local entry
  local package
  local commit
  local scope
  local agents
  local skill_names
  local scope_flag
  local checkout_dir

  log_section "Installing pinned skills from $(basename "$manifest_path")"
  require_command npx "Node.js and npx are required to install skills. Run ./install.sh node first."
  require_command git "Git is required to verify pinned skill sources."

  while IFS= read -r entry; do
    IFS='|' read -r package commit scope agents skill_names <<< "$entry"
    validate_skill_lock_entry "$package" "$commit" "$scope" "$agents" "$skill_names"
    checkout_dir="$(checkout_pinned_skill_package "$package" "$commit")"
    preflight_skill_package "$checkout_dir" "$package" "$commit" "$skill_names"

    case "$scope" in
      global)
        scope_flag="--global"
        ;;
      project)
        scope_flag=""
        ;;
      *)
        echo "Unknown skills scope: $scope" >&2
        exit 1
        ;;
    esac

    npx -y "skills@$SKILLS_CLI_VERSION" add "$checkout_dir" $scope_flag --agent "$agents" --skill "$skill_names" --yes </dev/null
  done < <(read_manifest "$manifest_path")
}

ensure_authored_skill_repo() {
  local package="$1"
  local commit="$2"
  local repo_name
  local checkout_dir
  local current_commit

  repo_name="$(basename "$package" .git)"
  checkout_dir="$AUTHORED_SKILLS_ROOT/$repo_name"
  mkdir -p "$AUTHORED_SKILLS_ROOT"

  if [[ ! -d "$checkout_dir/.git" ]]; then
    git clone --quiet "$package" "$checkout_dir"
  fi

  [[ "$(git -C "$checkout_dir" remote get-url origin)" == "$package" ]] || {
    echo "Unexpected origin for authored skills repo: $checkout_dir" >&2
    exit 1
  }

  current_commit="$(git -C "$checkout_dir" rev-parse HEAD)"
  [[ "$current_commit" == "$commit" ]] || {
    echo "Authored skills repo is not at its locked revision: $checkout_dir" >&2
    echo "  Expected: $commit" >&2
    echo "  Current:  $current_commit" >&2
    echo "  Run ./install.sh skills-update, review the change, then update this checkout manually." >&2
    exit 1
  }

  printf '%s\n' "$checkout_dir"
}

link_authored_skill_entries() {
  local checkout_dir="$1"
  local skill_names="$2"
  local skill_file
  local source_dir
  local skill_name

  while IFS= read -r skill_file; do
    source_dir="$(dirname "$skill_file")"
    skill_name="$(basename "$source_dir")"
    link_authored_skill "$source_dir" "$HOME/.agents/skills/$skill_name"
  done < <(find "$checkout_dir" -path '*/SKILL.md' -type f | sort)
}

link_authored_skill() {
  local source_dir="$1"
  local target_dir="$2"

  mkdir -p "$(dirname "$target_dir")"

  if [[ -L "$target_dir" ]] && [[ "$(readlink "$target_dir")" == "$source_dir" ]]; then
    echo "Authored skill link already up to date: $target_dir"
    return
  fi

  if [[ -e "$target_dir" || -L "$target_dir" ]]; then
    echo "Warning: existing skill left untouched: $target_dir"
    echo "  Reconcile it with $source_dir before replacing it with an authored skill link."
    return
  fi

  ln -s "$source_dir" "$target_dir"
  echo "Linked $target_dir -> $source_dir"
}

validate_skill_lock_entry() {
  local package="$1"
  local commit="$2"
  local scope="$3"
  local agents="$4"
  local skill_names="$5"

  [[ "$package" =~ ^https://github\.com/[^/]+/[^/]+$ ]] || {
    echo "Invalid skill package URL: $package" >&2
    exit 1
  }
  [[ "$commit" =~ ^[0-9a-f]{40}$ ]] || {
    echo "Skill package must be pinned to a 40-character commit SHA: $package" >&2
    exit 1
  }
  [[ -n "$scope" && -n "$agents" && -n "$skill_names" ]] || {
    echo "Incomplete skill lock entry for $package" >&2
    exit 1
  }
}

checkout_pinned_skill_package() {
  local package="$1"
  local commit="$2"
  local cache_root="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/skills"
  local package_name
  local checkout_dir
  local temporary_dir

  package_name="$(basename "$package" .git)"
  checkout_dir="$cache_root/$package_name/$commit"

  if [[ -d "$checkout_dir/.git" ]] && git -C "$checkout_dir" cat-file -e "${commit}^{commit}" 2>/dev/null; then
    git -C "$checkout_dir" checkout --quiet --detach "$commit"
    printf '%s\n' "$checkout_dir"
    return
  fi

  temporary_dir="$(mktemp -d)"
  git clone --quiet "$package" "$temporary_dir"
  git -C "$temporary_dir" checkout --quiet --detach "$commit"
  mkdir -p "$(dirname "$checkout_dir")"
  rm -rf "$checkout_dir"
  mv "$temporary_dir" "$checkout_dir"
  printf '%s\n' "$checkout_dir"
}

preflight_skill_package() {
  local checkout_dir="$1"
  local package="$2"
  local commit="$3"
  local skill_names="$4"
  local skill_file

  if ! find "$checkout_dir" -path '*/SKILL.md' -type f -print -quit | grep -q .; then
    echo "Pinned skill package contains no SKILL.md files: $package@$commit" >&2
    exit 1
  fi

  while IFS= read -r skill_file; do
    grep -q '^name:' "$skill_file" || {
      echo "Skill is missing a name in $skill_file" >&2
      exit 1
    }
    grep -q '^description:' "$skill_file" || {
      echo "Skill is missing a description in $skill_file" >&2
      exit 1
    }
  done < <(find "$checkout_dir" -path '*/SKILL.md' -type f | sort)

  if [[ "$skill_names" != "*" ]]; then
    IFS=',' read -r -a requested_skills <<< "$skill_names"
    local requested_skill
    for requested_skill in "${requested_skills[@]}"; do
      find "$checkout_dir" -path "*/$requested_skill/SKILL.md" -type f -print -quit | grep -q . || {
        echo "Pinned package does not contain requested skill: $requested_skill" >&2
        exit 1
      }
    done
  fi
}

update_skills_lock() {
  require_command git "Git is required to update skill pins."
  update_skill_lock_manifest "$REPO_ROOT/manifests/skills.lock" 0
  update_skill_lock_manifest "$REPO_ROOT/manifests/skills-projects.lock" 1
}

update_skill_lock_manifest() {
  local manifest_path="$1"
  local package_index="$2"
  local entry
  local package
  local commit
  local latest_commit
  local updated_manifest

  [[ -n "$(read_manifest "$manifest_path")" ]] || return 0

  log_section "Reviewing pins in $(basename "$manifest_path")"
  updated_manifest="$(mktemp)"
  trap "rm -f '$updated_manifest'" RETURN

  while IFS= read -r entry; do
    IFS='|' read -r -a fields <<< "$entry"
    package="${fields[$package_index]}"
    commit="${fields[$((package_index + 1))]}"
    latest_commit="$(git ls-remote "$package" HEAD | awk '{print $1}')"
    [[ -n "$latest_commit" ]] || {
      echo "No default-branch commit found for $package; leaving its pin unchanged." >&2
      printf '%s\n' "$entry" >> "$updated_manifest"
      continue
    }
    fields[$((package_index + 1))]="$latest_commit"
    (IFS='|'; printf '%s\n' "${fields[*]}") >> "$updated_manifest"
    if [[ "$commit" == "$latest_commit" ]]; then
      echo "Already pinned to latest: $package@$commit"
    else
      echo "Update available: $package $commit -> $latest_commit"
    fi
  done < <(read_manifest "$manifest_path")

  if [[ "${SKILLS_UPDATE_WRITE:-0}" == "1" ]]; then
    mv "$updated_manifest" "$manifest_path"
    trap - RETURN
    echo "Updated $manifest_path. Review and commit the pin changes before running ./install.sh skills."
  else
    echo "Set SKILLS_UPDATE_WRITE=1 to write the reviewed updates to $manifest_path."
  fi
}