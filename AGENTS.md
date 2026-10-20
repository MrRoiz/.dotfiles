# AGENTS.md

Personal Omarchy dotfiles for `MrRoiz`, branched from a plain Arch + Hyprland
repo and now trimmed to the Omarchy setup only. Managed with **GNU Stow**,
pushed to `github.com:MrRoiz/.dotfiles` (`feat/omarchy-setup`). No
test/lint/CI tooling exists in this repo.

## Project-wide look and feel (rule)

**The whole system follows the Omarchy theme selected on the machine** — bar, notifications, terminal, launcher, lock screen, session menu, GTK, window borders, prompt, … Do **not** hardcode a palette in these dotfiles and do **not** vendor an off-theme named theme (e.g. Catppuccin): configs that draw color must reference the active theme's colors (ANSI names for terminal output, theme variables where an app offers them) so `omarchy theme set` re-themes everything with no dotfiles change. If an app only offers named themes, map it to the active theme; if a gap cannot be closed now, leave a clear note rather than pinning fixed values. Consistency with the selected Omarchy theme beats per-app cleverness.

## Minimal diffs (rule)

**NEVER modify something there is no need to modify — it only adds noise to the diff.** Change only the lines the task actually requires. Do **not** reformat, re-align, re-indent, re-wrap, or re-order unrelated code, comments, or whitespace, and never commit whitespace-only churn (e.g. collapsing comment padding, sorting keys, "tidying" a block you did not need to touch). If you spot unrelated drift, leave it as-is and mention it — do not fold it into the change. A diff should contain only the intended edits so review stays focused.

## How it is wired

- `scripts/omarchy.sh` — the only installer. Self-contained: it does
  not source other scripts/setup files (those were the non-omarchy
  installer modules, now removed).
- `config/<app>/.config/<app>/…` — one **Stow package per app**; the
  omarchy setup stows only the packages whose apps it installs (see
  `STOW_PACKAGES` in `omarchy.sh`).
- `zsh/` — sourced by the Omarchy setup after the omarchy-zsh template.
  `setup.sh` chains the user's aliases / functions. The prompt is
  omarchy-zsh's starship and zsh-syntax-highlighting + history-search
  come from omarchy-zsh's zoptions; p10k and oh-my-zsh are
  intentionally not used.

## Development checkout vs installed setup

This checkout is the editing copy. The live setup runs from `~/.dotfiles`.
Workflow after changing files here:

1. Commit and push in this checkout.
2. Bring `~/.dotfiles` up to date. That checkout has two live-only edits to
   preserve: `zsh/setup.sh` uses `ZSH_PATH="$HOME/.dotfiles/zsh"`, and the
   `omarchy-setup-security-sudoless-docker` call is commented out. Save those,
   update the checkout, and reapply them.
3. Run `restow`.

`restow` stows every managed package from `~/.dotfiles/config`, including the
partial `hypr` and `wireplumber` packages and the single-file `starship`
package. Use
`~/.dotfiles/scripts/omarchy.sh` for a full install.

## Commands

- Install / re-run: `~/.dotfiles/scripts/omarchy.sh`
- Restow everything: `restow` (all managed packages from `~/.dotfiles`, including `hypr`, `wireplumber` and `starship`)
- Re-stow after adding/removing files: `cd ~/.dotfiles/config && stow --restow -t "$HOME" <pkg>` (use the `STOW_PACKAGES` list from `omarchy.sh`, not `*`)
- Omarchy bar clock format: `omarchy-bar set omarchy.clock format "<Qt format>"`
- herdr: `herdr server reload-config` applies `config.toml` (theme/UI) to the running server; `herdr config check` validates it.
- Validate JSON/JSONC: `python3 -c "import json;json.load(open('<file>'))"`

## Keymaps

- Window focus: `SUPER + H/J/K/L`; swap: `SUPER + SHIFT + H/J/K/L`.
- Screenshots: `SUPER + SHIFT + C` (the 60% keyboard has no PRINT key).
- Remapped to free those keys:
  - `SUPER + J` toggle split -> `SUPER + ALT + J`
  - `SUPER + K` keybindings -> `SUPER + CTRL + SHIFT + K`
  - `SUPER + L` workspace layout -> `SUPER + ALT + L`
- Config: `config/hypr/.config/hypr/bindings.lua` (`hypr` stow package).

## Gotchas

- herdr is installed via mise (`mise use -g herdr@latest`) so it always
  tracks the latest upstream release; the setup drops the lagging Omarchy
  package. Update with `mise upgrade herdr`, not `herdr update`, and
  restart/reattach the client/server afterwards.
- Herdr panes start zsh via `terminal.default_shell`; bash's exec-zsh drop-in
  only fires at `SHLVL 1`, so panes would otherwise be bash and miss
  zsh-syntax-highlighting.
- The login shell on Omarchy is bash; zsh launches through the
  `omarchy-setup-zsh` drop-in (bash `exec`s zsh). Do not `chsh` to zsh
  — see https://github.com/omacom/omarchy/discussions/2495.
- `config/opencode/.config/opencode/` — only `opencode.json` + `tui.json` are tracked. `package.json`, `package-lock.json`, `node_modules/`, `bun.lock` are **OpenCode-generated artifacts** (gitignored). Never commit them.
- `~/.config/<app>` is usually a **symlink into the repo** (Stow). Tools that copy into `~/.config` write *through* the symlink into the repo, so re-sourcing the affected tool picks the change up.
- `omarchy.sh`: the Arch repos and the Omarchy package repo are reached through `omarchy-pkg-add`; AUR packages are not installed by the script.
- Commit style is Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`), as seen in `git log`.

## Colors

**Single source of truth: the Omarchy theme selected on the machine.** No
palette is defined in this repo; configs reference the active theme's colors.

- Terminal and prompt (kitty, starship) — kitty includes
  `~/.local/state/omarchy/current/theme/kitty.conf`, the palette Omarchy
  regenerates from the theme's `colors.toml`; starship uses ANSI color names
  only (`red`, `green`, `yellow`, `cyan`, `bright-black`, …), so both follow
  `omarchy theme set` with no dotfiles change.
- Bar, notifications, launcher, lock screen, GTK — themed by Omarchy itself;
  this setup only sets text/format options (e.g. the bar clock format), never
  colors.
- Known gap: `config/herdr/.config/herdr/config.toml` still pins fixed values
  under `[theme.custom]` because herdr has no Omarchy theme integration. Treat
  it as debt: do not extend fixed values to other configs, and converge herdr
  when a supported mapping exists.
