#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/dotfiles"

if [[ -z "$(git status --porcelain)" ]]; then
  echo "nothing to sync"
  exit 0
fi

git add -A
git commit -m "sync: auto-config update $(date +%Y-%m-%d-%H%M)"
git push
