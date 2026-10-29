#!/usr/bin/env bash

set -euo pipefail

install_system_packages() {
  log_section "Installing system packages"

  case "$PACKAGE_MANAGER" in
    brew)
      install_brew_packages
      ;;
    apt)
      install_apt_packages
      ;;
    *)
      echo "Unsupported package manager: $PACKAGE_MANAGER" >&2
      exit 1
      ;;
  esac
}

install_brew_packages() {
  local manifest_path="$REPO_ROOT/manifests/brew.txt"
  local formulae=()
  local casks=()
  local entry
  local package_type
  local package_name

  require_command brew "Homebrew is required to install packages on macOS."

  while IFS= read -r entry; do
    package_type="${entry%%|*}"
    package_name="${entry#*|}"

    if [[ "$package_type" == "$package_name" ]]; then
      package_type="formula"
    fi

    case "$package_type" in
      formula)
        if ! brew list --formula "$package_name" >/dev/null 2>&1; then
          formulae+=("$package_name")
        fi
        ;;
      cask)
        if ! brew list --cask "$package_name" >/dev/null 2>&1; then
          casks+=("$package_name")
        fi
        ;;
      *)
        echo "Unknown brew package type: $package_type" >&2
        exit 1
        ;;
    esac
  done < <(read_manifest "$manifest_path")

  if [[ ${#formulae[@]} -gt 0 ]]; then
    brew install "${formulae[@]}"
  fi

  if [[ ${#casks[@]} -gt 0 ]]; then
    brew install --cask "${casks[@]}"
  fi

  if [[ ${#formulae[@]} -eq 0 && ${#casks[@]} -eq 0 ]]; then
    echo "All Homebrew packages are already installed."
  fi
}

install_apt_packages() {
  local manifest_path="$REPO_ROOT/manifests/apt.txt"
  local packages=()
  local package_name

  require_command sudo "sudo is required to install packages on Ubuntu."
  require_command apt-get "apt-get is required to install packages on Ubuntu."

  while IFS= read -r package_name; do
    if ! dpkg -s "$package_name" >/dev/null 2>&1; then
      packages+=("$package_name")
    fi
  done < <(read_manifest "$manifest_path")

  if [[ ${#packages[@]} -gt 0 ]]; then
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
  else
    echo "All apt packages are already installed."
  fi
}