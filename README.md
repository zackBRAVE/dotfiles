# Personal macOS dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Config management (Stow)

- Each top-level directory at repo root is a stow package, mirroring the home directory layout (e.g., `nvim/.config/nvim/`)
- **Never edit symlinked targets in `~/*`** — edit files inside the repo, then re-stow
- `bootstrap.sh` runs `stow */` to link everything

## HJKL navigation convention

Custom directional keys used across tools:

| Key | Direction |
|-----|-----------|
| `j` | left |
| `k` | down |
| `l` | up |
| `;` | right |

Applied in: Neovim, Zed, Yazi, Lazygit. Karabiner remaps Right Cmd + h/j/k/l → arrows. Any other app that supports vim-like cursor movement should follow this convention where possible.

## Theme & font

- **Theme:** Vitesse (dark/light soft variants) — Neovim (`mini.base16`), Ghostty (`vitesse-dark-soft`/`vitesse-light-soft`), Zed (`Vitesse Refined Light Soft`/`Vitesse Refined Black Soft`). Any other theme-customizable app should follow the same color scheme.
- **Font:** `CaskaydiaCove Nerd Font` at size 14

## Bootstrap & sync

- `bootstrap.sh` — clones repo, installs stow, stows all packages, links agent skills, sets up git `includeIf` for personal email, installs launchd auto-sync
- Auto-sync (`bin/com.zackbrave.dotfiles-sync.plist`) runs `bin/sync-config.sh` every hour: commits any unstaged changes as `sync: auto-config update YYYY-MM-DD-HHMM` and pushes

## Git conventions

- Conventional commits: `feat:`, `fix:`, `chore:`, `optimize:`, `sync:`, `update`
- `includeIf` in `~/.gitconfig` routes `~/dotfiles/` to personal email (`zackbrave@outlook.com`)

## Common tasks

- **Modify existing config:** edit the file inside the repo package directory (e.g., `nvim/.config/nvim/init.lua`), then re-stow
- **Bootstrap a new machine:** install brew + apps, then run `bootstrap.sh`
