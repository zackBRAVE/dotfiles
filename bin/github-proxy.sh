#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  "")
    echo "Usage: $(basename "$0") <proxy-prefix>"
    echo "       $(basename "$0") --unset"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") https://gh-proxy.org/    # Set proxy"
    echo "  $(basename "$0") --unset                   # Remove proxy"
    exit 1
    ;;
  --unset)
    key=$(git config --global --get-regexp "url\..*\.insteadOf" 2>/dev/null \
      | grep "https://github.com/" | head -1 | cut -d' ' -f1 || true)
    if [ -n "$key" ]; then
      git config --global --unset "$key"
      echo "GitHub proxy removed"
    else
      echo "No GitHub proxy configured"
    fi
    ;;
  *)
    key="url.${1}https://github.com/.insteadOf"
    git config --global --replace-all "$key" "https://github.com/"
    echo "GitHub proxy set: ${1}https://github.com/"
    ;;
esac
