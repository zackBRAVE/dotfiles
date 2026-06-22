#!/usr/bin/env bash
#
# bootstrap.sh — set up this machine from the dotfiles repo.
#
# Prerequisites: brew + the apps (nvim, ghostty, ghost-complete, yazi, zed, starship) installed.
#
set -euo pipefail

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
  stow -v "$pkg" 2>/dev/null || echo "  (skipped $pkg)"
done

# 4. Link agent skills to agent skill directories
echo "==> Linking agent skills..."
CLAUDE_SKILLS="$HOME/.claude/skills"
CODEX_SKILLS="$HOME/.codex/skills"
mkdir -p "$CLAUDE_SKILLS" "$CODEX_SKILLS"

for skill in "$DOTFILES_DIR"/.agent/skills/*/; do
  name=$(basename "$skill")
  ln -sfn "$skill" "$CLAUDE_SKILLS/$name"
  ln -sfn "$skill" "$CODEX_SKILLS/$name"
done

# 5. Set up includeIf so future commits use the personal email
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

# 6. Set up launchd auto-sync (macOS)
PLIST="$HOME/Library/LaunchAgents/com.zackbrave.dotfiles-sync.plist"
if [[ ! -f "$PLIST" ]]; then
  echo "==> Installing launchd auto-sync..."
  mkdir -p "$HOME/Library/LaunchAgents"
  cp "$DOTFILES_DIR/bin/com.zackbrave.dotfiles-sync.plist" "$PLIST"
  launchctl load "$PLIST"
fi

echo "==> Done. Configs are live at $DOTFILES_DIR"
