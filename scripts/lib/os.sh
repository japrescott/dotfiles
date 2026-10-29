#!/usr/bin/env bash

set -euo pipefail

OS_FAMILY=""
PACKAGE_MANAGER=""

detect_platform() {
  case "$(uname -s)" in
    Darwin)
      OS_FAMILY="macos"
      PACKAGE_MANAGER="brew"
      ;;
    Linux)
      if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
      fi

      case "${ID:-}" in
        ubuntu)
          OS_FAMILY="ubuntu"
          PACKAGE_MANAGER="apt"
          ;;
        *)
          echo "Unsupported Linux distribution: ${ID:-unknown}" >&2
          exit 1
          ;;
      esac
      ;;
    *)
      echo "Unsupported operating system: $(uname -s)" >&2
      exit 1
      ;;
  esac
}