# AGENTS.md

Personal Arch Linux + Hyprland dotfiles for `MrRoiz`. Managed with **GNU Stow**, pushed to `github.com:MrRoiz/.dotfiles` (`main`). No test/lint/CI tooling exists in this repo.

## Project-wide look and feel (rule)

**The whole system must look like one thing: the Ayu Dark palette.** Every component that draws color — bar, notifications, terminal, launcher, lock screen, session menu, GTK, window borders, herdr, … — uses the Ayu Dark tokens defined under [Colors](#colors). Do **not** introduce a new palette, and do **not** settle for a vendored/app-provided named theme that does not match (e.g. Catppuccin, off-the-shelf `ayu` variants): if an app only offers named themes, add explicit color overrides so it lands on the Ayu Dark tokens. When you touch any config, bring its colors closer to Ayu Dark; if a gap is too large to fix in the moment, leave a clear note rather than copying the off-palette value forward. Consistency across apps beats per-app cleverness.

## How it is wired

- `install.sh` — curl entrypoint. Ensures `git`, clones/pulls to `~/.dotfiles`, then runs `scripts/setup/setup.sh`.
- `scripts/setup/setup.sh` — the real installer. Sources `system.sh`, `packages.sh`, `dotfiles.sh`, `utils.sh`; runs under `set -e`.
- `config/<app>/.config/<app>/…` — one **Stow package per app**; `stow --restow -t "$HOME" *` run from inside `config/` links them into `~/.config`. Editing repo files edits the live config.
- `config-templates/` — **not stowed**; consumed by the installer (`sddm`, `mega`, `zsh`).
- `zsh/*.sh` — sourced from `config-templates/zsh/.zshrc`, which the installer copies to `~/.zshrc` if absent.
- `wallpapers/` + `scripts/change-wallpaper.sh` (must run as root; sets the gitignored `wallpapers/actual` symlink and the SDDM background).

## Commands

- Install / re-run: `bash ~/.dotfiles/install.sh`
- Re-stow after adding/removing files: `cd ~/.dotfiles/config && stow --restow -t "$HOME" *`
- Hyprland reload (Lua config + window/layer rules): `hyprctl reload`
- Waybar: config `killall -SIGUSR2 waybar`, CSS `killall -SIGUSR1 waybar`; full restart `pkill waybar; hyprctl dispatch exec waybar`. Keybind: `SUPER+R`.
- swaync: CSS `swaync-client -rs`, config `swaync-client -R`; **restart** (`pkill swaync; swaync`) to pick up layer/namespace changes (e.g. blur rules).
- herdr: `herdr server reload-config` applies `config.toml` (theme/UI) to the running server; `herdr config check` validates it.
- Validate JSON/JSONC: `python3 -c "import json;json.load(open('<file>'))"` — `waybar/config.jsonc` contains **no comments**, so it must stay valid JSON.

## Gotchas

- **Hyprland config is Lua**, not hyprlang. Entry `hyprland.lua` loads `hyprland-conf/*.lua`, which use the `hl.*` API (`hl.bind`, `hl.window_rule`, `hl.layer_rule`, …). Exception: `hyprlock.conf`, `hypridle.conf`, `hyprpaper.conf` are still legacy `.conf`.
- `config/opencode/.config/opencode/` — only `opencode.json` + `tui.json` are tracked. `package.json`, `package-lock.json`, `node_modules/`, `bun.lock` are **OpenCode-generated artifacts** (gitignored). Never commit them.
- `~/.config/<app>` is usually a **symlink into the repo** (Stow). Tools that copy into `~/.config` write *through* the symlink into the repo; `swaync-client -rs` etc. pick changes up because of this.
- The GTK theme files (`config/gtk/.config/gtk-4.0/gtk*.css`, ~9k lines) are **generated** — do not hand-edit.
- `scripts/setup/utils.sh: install_package` calls `yay -S … --needed`; there is no plain-`pacman` path.
- Waybar's `custom/notifications` uses a long-running `swaync-client -swb` subscription; if the DND icon goes stale, restart waybar (not just reload).
- Commit style is Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`), as seen in `git log`.

## Colors

**There is no single theme source.** Only **waybar**, **swaync** and **herdr** follow the intended **Ayu Dark** palette; other configs diverge (see below) and must be converged per the [rule above](#project-wide-look-and-feel-rule). Changing "the theme" means touching several files.

### Ayu Dark palette (reference: waybar + swaync + herdr)

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

Additional Ayu hues: cyan `#95E6CB` and purple `#D2A6FF` are used by herdr (agent "done" + branch labels); bright blue `#59C2FF` is still unused.

### Color roles (deliberate — do not overuse)

- **Gold `#E6B450` = active/current only** (waybar): active/focused workspace number (on `#1A1F29` chip), calendar month header + "today". In herdr gold is the "working" agent state. Used sparingly.
- **Blue `#39BAE6` = interactive / attention accents only**: swaync drawer interactive (DND-on switch, scrollbar hover); in herdr it is the accent — active tab, focused pane border, mode bar/overlay highlights, and unseen/finished notifications. Do **not** spread blue across the bar — "blue everywhere" was explicitly rejected.
- **Red `#F07178` = critical/urgent only**: battery/temperature critical, urgent workspace (soft tint `rgba(240,113,120,0.16)` + red number), notification dot. In waybar the active/focused rules are ordered *after* `.urgent`, so an active+urgent workspace stays gold.
- **Green `#7FD962`** = healthy/idle (waybar battery; herdr idle agent); **orange `#FFB454`** = warning (waybar battery; herdr interrupted); **red `#F07178`** also marks a blocked agent. Everything else is foreground `#BFBDB6` / muted `#565B66`.
- Design constraints enforced by the owner: color is a signal, not decoration. Prefer **subtle backgrounds + accent text** over saturated fills (the filled workspace pill was rejected). One accent per role.

### Where colors live

- `config/waybar/.config/waybar/style.css` — bar styling + the roles above.
- `config/waybar/.config/waybar/config.jsonc` — calendar `<span color=…>` for months/weeks/weekdays/today, and the notification icon spans.
- `config/swaync/.config/swaync/style.css` — drawer/popup theme; `--cc-bg` panel, `--noti-bg*` cards, `--noti-bg-focus: transparent` (removes the focus halo), `--group-collapse-tranistion` (expand speed).
- `config/herdr/.config/herdr/config.toml` — `[theme.custom]` sets every Ayu Dark token (surfaces, text, accent, semantic roles); `theme.name` is only a base and is fully overridden. `accent = #39BAE6` (Ayu blue) drives the active tab *and* the focused pane border/highlights — herdr has a single accent token, so it can't be scoped to tabs alone. Reload with `herdr server reload-config`, validate with `herdr config check`.

### Divergences (known debt — converge these to Ayu Dark; do not extend them)

- **kitty** (`config/kitty/.config/kitty/current-theme.conf`) is a *separate* palette: bg `#0e1419`, fg `#e5e1cf`, cursor `#f19618`, plus 16 ANSI colors. Editing waybar does **not** change kitty.
- **vicinae** uses named themes, not hex: `ayu-dark` / `vicinae-light` (`settings.json`).
- **Hyprland borders** (`look-and-feel.lua`): active `rgba(33ccffee)`/`rgba(00ff99ee)`, inactive `rgba(595959aa)` — not the Ayu set.
- **hyprlock** (`hyprlock.conf`) uses Catppuccin colors (`##cdd6f480`, `##f38ba8`).
- **wlogout** (`style.css`) is off-theme (`#1E1E1E`, purple `#3700B3`).
- **GTK** is a generated theme whose accent is `#5b9bf8`; the installer sets `Adwaita-dark` via `gsettings` (`scripts/setup/system.sh: setup_theme`).
