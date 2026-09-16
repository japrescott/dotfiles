#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$REPO_ROOT/scripts/lib/common.sh"
source "$REPO_ROOT/scripts/lib/os.sh"
source "$REPO_ROOT/scripts/install/packages.sh"
source "$REPO_ROOT/scripts/install/submodules.sh"
source "$REPO_ROOT/scripts/install/links.sh"
source "$REPO_ROOT/scripts/install/llm.sh"
source "$REPO_ROOT/scripts/install/skills.sh"
source "$REPO_ROOT/scripts/install/sync.sh"
source "$REPO_ROOT/scripts/install/node.sh"
source "$REPO_ROOT/scripts/install/python.sh"

usage() {
  cat <<'EOF'
Usage: ./install.sh [all|packages|submodules|links|skills|skills-update|skills-projects|sync|llm|llm-import|node|python]

Commands:
  all         Run the full bootstrap flow.
  packages    Install OS-level packages from manifests.
  submodules  Initialize and update git submodules.
  links       Create dotfile symlinks defined in manifests.
  skills      Install SHA-pinned shared skills from the lock manifest.
  skills-update Refresh shared-skill pins after reviewing upstream changes.
  skills-projects Install private project-specific skills from the lock manifest.
  sync        Check for updates; use `sync pull` to update clean repos or `sync reinject` to restore missing skill links.
  llm         Symlink managed LLM runtime files into user config directories.
  llm-import  Import existing local LLM runtime files into the repo-owned sources.
  node        Install nvm, Node.js LTS, and npm global tools.
  python      Install uv, pinned Python versions, and uv tools.
EOF
}

main() {
  local command="${1:-all}"
  shift || true

  detect_platform

  case "$command" in
    all)
      install_system_packages
      init_git_submodules
      install_dotfile_links
      install_node_stack
      install_skills
      install_llm_runtime_links
      install_python_stack
      ;;
    packages)
      install_system_packages
      ;;
    submodules)
      init_git_submodules
      ;;
    links)
      install_dotfile_links
      ;;
    skills)
      install_skills
      ;;
    skills-update)
      update_skills_lock
      ;;
    skills-projects)
      install_project_skills
      ;;
    sync)
      sync_dotfiles_and_skills "$@"
      ;;
    llm)
      install_llm_runtime_links
      ;;
    llm-import)
      import_llm_runtime_files
      ;;
    node)
      install_node_stack
      ;;
    python)
      install_python_stack
      ;;
    -h|--help|help)
      usage
      return 0
      ;;
    *)
      echo "Unknown command: $command" >&2
      usage >&2
      exit 1
      ;;
  esac

  log_section "Bootstrap complete"
}

main "$@"