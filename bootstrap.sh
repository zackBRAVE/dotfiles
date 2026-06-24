#!/usr/bin/env bash
#
# bootstrap.sh — set up this machine from the dotfiles repo.
# Usage: bootstrap.sh [--adopt]
#
# Prerequisites: brew + the apps (nvim, ghostty, ghost-complete, yazi, zed, starship) installed.
#
set -euo pipefail

# Parse flags
ADOPT_MODE=false
for arg in "$@"; do
  case "$arg" in
    --adopt) ADOPT_MODE=true ;;
    --help|-h)
      echo "Usage: bootstrap.sh [--adopt]"
      echo "  --adopt  Adopt existing configs into the dotfiles repo (no prompts)"
      exit 0
      ;;
  esac
done

DOTFILES_REPO="${DOTFILES_REPO:-git@github.com:zackBRAVE/dotfiles.git}"
DOTFILES_DIR="$HOME/dotfiles"

echo "==> dotfiles bootstrap"

# 1. Install stow if missing
if ! command -v stow &>/dev/null; then
  echo "==> Installing stow..."
  brew install stow
fi

# 2. Clone (or pull) the dotfiles repo
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  echo "==> Updating existing dotfiles repo..."
  git -C "$DOTFILES_DIR" pull --ff-only
else
  echo "==> Cloning dotfiles repo..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# 3. Stow everything
echo "==> Stowing configs..."
cd "$DOTFILES_DIR"
for pkg in */; do
  pkg=${pkg%/}
  [[ "$pkg" == .* ]] && continue

  if $ADOPT_MODE; then
    stow -v --adopt "$pkg" 2>/dev/null || echo "  (skipped $pkg)"
  else
    warnings=$(stow -n "$pkg" 2>&1 || true)
    if echo "$warnings" | grep -qi "existing target"; then
      echo "==> $pkg has existing configs that would conflict:"
      echo "$warnings" | sed 's/^/  /'
      read -r -p "[a]dopt | [s]kip? " choice </dev/tty
      case "$choice" in
        a|A) stow -v --adopt "$pkg" 2>/dev/null || echo "  (skipped $pkg)" ;;
        *) echo "  (skipped $pkg)" ;;
      esac
    else
      stow -v "$pkg" 2>/dev/null || echo "  (skipped $pkg)"
    fi
  fi
done

# 4. Rebuild kbd-brightness if source changed (macOS only)
KBD_SRC="$HOME/.local/bin/kbd-brightness.m"
KBD_BIN="$HOME/.local/bin/kbd-brightness"
if [ -f "$KBD_SRC" ] && { [ ! -f "$KBD_BIN" ] || [ "$KBD_SRC" -nt "$KBD_BIN" ]; }; then
    echo "==> Rebuilding kbd-brightness..."
    clang -framework Foundation -F/System/Library/PrivateFrameworks \
          -framework CoreBrightness -O2 -o "$KBD_BIN" "$KBD_SRC"
fi

# Remind user to configure toggle app on this machine
if [ ! -f "$HOME/.config/toggle-frontmost-app/env" ]; then
    echo "==> ⚠  Create ~/.config/toggle-frontmost-app/env with:"
    echo "    TOGGLE_APP_NAME=<your-app>"
fi

# 5. Link agent skills to agent skill directories
echo "==> Linking agent skills..."
CLAUDE_SKILLS="$HOME/.claude/skills"
CODEX_SKILLS="$HOME/.codex/skills"
mkdir -p "$CLAUDE_SKILLS" "$CODEX_SKILLS"

for skill in "$DOTFILES_DIR"/.agent/skills/*/; do
  name=$(basename "$skill")
  ln -sfn "$skill" "$CLAUDE_SKILLS/$name"
  ln -sfn "$skill" "$CODEX_SKILLS/$name"
done

# 6. Set up includeIf so future commits use the personal email
GITCONFIG="$HOME/.gitconfig"
if ! grep -q "dotfiles" "$GITCONFIG" 2>/dev/null; then
  echo "==> Adding includeIf for personal email..."
  cat >> "$GITCONFIG" <<'EOF'

[includeIf "gitdir:~/dotfiles/"]
	path = ~/.gitconfig-personal
EOF
  cat > "$HOME/.gitconfig-personal" <<'EOF'
[user]
	name = Zack
	email = zackbrave@outlook.com
EOF
fi

# 7. Set up launchd auto-sync (macOS)
PLIST="$HOME/Library/LaunchAgents/com.zackbrave.dotfiles-sync.plist"
if [[ ! -f "$PLIST" ]]; then
  echo "==> Installing launchd auto-sync..."
  mkdir -p "$HOME/Library/LaunchAgents"
  cp "$DOTFILES_DIR/bin/com.zackbrave.dotfiles-sync.plist" "$PLIST"
  launchctl load "$PLIST"
fi

if $ADOPT_MODE; then
  echo "==> Configs adopted. Run 'git diff' to review changes, then commit."
fi

echo "==> Done. Configs are live at $DOTFILES_DIR"
