# AGENTS.md

Personal Omarchy dotfiles for `MrRoiz`, branched from a plain Arch + Hyprland
repo and now trimmed to the Omarchy setup only. Managed with **GNU Stow**,
pushed to `github.com:MrRoiz/.dotfiles` (`feat/omarchy-setup`). No
test/lint/CI tooling exists in this repo.

## Project-wide look and feel (rule)

**The whole system must look like one thing: the Ayu Dark palette.** Every component that draws color — bar, notifications, terminal, launcher, lock screen, session menu, GTK, window borders, herdr, … — uses the Ayu Dark tokens defined under [Colors](#colors). Do **not** introduce a new palette, and do **not** settle for a vendored/app-provided named theme that does not match (e.g. Catppuccin, off-the-shelf `ayu` variants): if an app only offers named themes, add explicit color overrides so it lands on the Ayu Dark tokens. When you touch any config, bring its colors closer to Ayu Dark; if a gap is too large to fix in the moment, leave a clear note rather than copying the off-palette value forward. Consistency across apps beats per-app cleverness.

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

**There is no single theme source.** Only **herdr** (and parts of the
Omarchy bar that inherit from omarchy's own theme) follow the intended
**Ayu Dark** palette. The remaining dotfiles configs that ship color
(kitty, GTK) diverge, see [Divergences](#divergences-known-debt--converge-these-to-ayu-dark-do-not-extend-them).
Changing the theme means touching herdr + the Omarchy bar selector +
optionally the divergent configs.

### Ayu Dark palette (reference: herdr + omarchy bar)

| Role | Hex |
|---|---|
| Background | `#0D1017` |
| Surface (tooltip/card darker) | `#131721` |
| Border / hairline | `#1B2028` |
| Hover / raised | `#1A1F29` |
| Foreground | `#BFBDB6` |
| Muted / inactive | `#565B66` |
| Gold (accent) | `#E6B450` |
| Blue | `#39BAE6` |
| Green | `#7FD962` |
| Orange | `#FFB454` |
| Red | `#F07178` |

Additional Ayu hues: cyan `#95E6CB` and purple `#D2A6FF` are used by herdr
(agent "done" + branch labels); bright blue `#59C2FF` is still unused.

### Color roles (deliberate — do not overuse)

- **Gold `#E6B450` = active/current only**: Omarchy bar's focused clock /
  today highlight; in herdr it is the "working" agent state.
- **Blue `#39BAE6` = interactive / attention accents only**: in herdr it
  is the accent — active tab, focused pane border, mode bar/overlay
  highlights, and unseen/finished notifications. Do not spread blue.
- **Green `#7FD962`** = healthy/idle (herdr idle agent); **orange
  `#FFB454`** = warning (herdr interrupted); **red `#F07178`** = critical
  / blocked. Everything else is foreground `#BFBDB6` / muted `#565B66`.
- Design constraints enforced by the owner: color is a signal, not
  decoration. One accent per role.

### Where colors live

- `config/herdr/.config/herdr/config.toml` — `[theme.custom]` sets every
  Ayu Dark token (surfaces, text, accent, semantic roles); `theme.name`
  is only a base and is fully overridden. `accent = #39BAE6` (Ayu blue)
  drives the active tab *and* the focused pane border/highlights — herdr
  has a single accent token, so it can't be scoped to tabs alone. Reload
  with `herdr server reload-config`, validate with `herdr config check`.
- `omarchy-bar set omarchy.clock format "..."` — the bar's clock widget
  and its calendar pop-up colors are themed by Omarchy itself; the
  setup script only sets the clock format string to match the text
  format the dotfiles used to print under waybar
  (`{0:%b %d} {0:%I:%M%p}` -> `MMM dd hh:mmAP`).

### Divergences (known debt — converge these to Ayu Dark; do not extend them)

- **kitty** (`config/kitty/.config/kitty/current-theme.conf`) is a *separate* palette: bg `#0e1419`, fg `#e5e1cf`, cursor `#f19618`, plus 16 ANSI colors. Editing herdr does **not** change kitty.
- **GTK** is a generated theme whose accent is `#5b9bf8`; the Omarchy ISO
  already sets `Adwaita-dark` via `gsettings` during its first-boot
  provisioning, so the generated CSS is not re-applied by this setup.
