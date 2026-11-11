# AGENTS.md

Personal Omarchy dotfiles for `MrRoiz`, branched from a plain Arch + Hyprland
repo and now trimmed to the Omarchy setup only. Managed with **GNU Stow**,
pushed to `github.com:MrRoiz/.dotfiles` (`feat/omarchy-setup`). No
test/lint/CI tooling exists in this repo.

## Project-wide look and feel (rule)

**The whole system follows the Omarchy theme selected on the machine** — bar, notifications, terminal, launcher, lock screen, session menu, GTK, window borders, prompt, … Do **not** hardcode a palette in these dotfiles and do **not** vendor an off-theme named theme (e.g. Catppuccin): configs that draw color must reference the active theme's colors (ANSI names for terminal output, theme variables where an app offers them) so `omarchy theme set` re-themes everything with no dotfiles change. If an app only offers named themes, map it to the active theme; if a gap cannot be closed now, leave a clear note rather than pinning fixed values. Consistency with the selected Omarchy theme beats per-app cleverness.

## Change boundaries (rule)

**All changes must be made through this dotfiles repo.** Read-only exploration outside `~/.dotfiles` is allowed. Do **not** modify anything outside `~/.dotfiles` without explicit approval from the dev; unapproved external modifications are never allowed. Apply external changes by adding them to the repo and Stowing/installing from here, not by editing the live path directly.

## Minimal diffs (rule)

**NEVER modify something there is no need to modify — it only adds noise to the diff.** Change only the lines the task actually requires. Do **not** reformat, re-align, re-indent, re-wrap, or re-order unrelated code, comments, or whitespace, and never commit whitespace-only churn (e.g. collapsing comment padding, sorting keys, "tidying" a block you did not need to touch). If you spot unrelated drift, leave it as-is and mention it — do not fold it into the change. A diff should contain only the intended edits so review stays focused.

## Gaps and bugs (rule)

- Known gaps against upstream Omarchy are tracked in `KNOWN-GAPS.md`; the `gap-watch` skill re-checks them and retires local workarounds once a fix lands in stable.
- When a possible bug comes up — in conversation or while working here — use the `validate-gap` skill before calling it a bug: confirm it reproduces, rule out this repo's own overrides, and check the Omarchy repos for an existing issue or PR. If it is a real bug, add it to `KNOWN-GAPS.md` with its upstream ref and the condition that closes it; if it is caused by our config, fix it here instead.
- Do not file an upstream issue, remove a workaround, or change a config during validation without asking first.

## How it is wired

- `scripts/omarchy.sh` — the only installer. Self-contained: it does
  not source other scripts/setup files (those were the non-omarchy
  installer modules, now removed).
- `config/<app>/.config/<app>/…` — one **Stow package per app**; the
  omarchy setup stows only the packages whose apps it installs (see
  `STOW_PACKAGES` in `omarchy.sh`).
- `agent/` — shared instructions and skills, kept once for both tools:
  - `agent/instructions/` — shared instructions, one file per concern:
    `PRINCIPLES.md` (what good code is: YAGNI, KISS, readability),
    `ORGANIZATION.md` (layout, placement, conventions), `MODULARITY.md`
    (file/function size, coupling, seams), `CONFIGURATION.md` (constants,
    config, secrets), `CHANGES.md` (diff discipline, self-review), `GIT.md`
    (signed commits, 1Password-gated push/pull), `NOTIFY.md` (phone
    notifications), and `COMMUNICATION.md` (answer style; questions are not
    instructions). OpenCode loads them through `instructions` in
    `opencode.json`; Claude Code imports them from `~/.claude/CLAUDE.md`
    (`config/claude` package). A rule that fits no existing file gets its own
    instruction file and is added to both loaders.
  - `agent/skills/` — shared skills: `polish` (quality-only cleanup of the
    changed diff) and `commit` (atomic commits in the project's style,
    Conventional Commits by default). OpenCode loads the directory through
    `skills` in `opencode.json`; `config/claude` links each skill into
    `~/.claude/skills`, the only directory skills are read from. A new skill
    needs that link; project-only skills stay in `.opencode/skills`.
- `zsh/` — sourced by the Omarchy setup after the omarchy-zsh template.
  `setup.sh` chains the user's aliases / functions. The prompt is
  omarchy-zsh's starship and zsh-syntax-highlighting + history-search
  come from omarchy-zsh's zoptions; `zsh/setup.sh` adds dim history
  autosuggestions from the `zsh-autosuggestions` package (`fg=8`, so it
  follows the theme). p10k and oh-my-zsh are
  intentionally not used.

## Commands

- Install / re-run: `~/.dotfiles/scripts/omarchy.sh`
- Restow everything: `restow` (all managed packages from `~/.dotfiles`, including `hypr`, `wireplumber`, `starship`, `spotify`, `omarchy-themes`, `omarchy-menu` and `claude`)
- Re-stow after adding/removing files: `cd ~/.dotfiles/config && stow --restow -t "$HOME" <pkg>` (use the `STOW_PACKAGES` list from `omarchy.sh`, not `*`)
- Omarchy bar clock format: `omarchy-bar set omarchy.clock format "<Qt format>"`
- Menu extension: run `omarchy menu refresh` after editing `~/.config/omarchy/extensions/omarchy-menu.jsonc` (the Stow symlink is not watched through the repo).
- ntfy: `omarchy-ntfy show` prints the channel id; `omarchy-ntfy send "Title" "Body"` pushes a notification. The channel lives in `~/.config/ntfy-sender/config.json` (0600) and is never tracked in the repo.
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

- herdr comes from the Omarchy package, so `pacman -Syu` and `omarchy update`
  upgrade it; restart/reattach the client and server afterwards. It is not
  mise-managed (unlike aws-cli, gh, just, sops, terraform and terragrunt), so
  the client and server both run `/usr/bin/herdr`.
- Herdr panes start zsh via `terminal.default_shell`; bash's exec-zsh drop-in
  only fires at `SHLVL 1`, so panes would otherwise be bash and miss
  zsh-syntax-highlighting.
- The login shell on Omarchy is bash; zsh launches through the
  `omarchy-setup-zsh` drop-in (bash `exec`s zsh). Do not `chsh` to zsh
  — see https://github.com/omacom/omarchy/discussions/2495.
- `config/spotify/.config/spotify-flags.conf` pins `--ozone-platform=wayland`
  because Spotify 1.3.4.258's bundled libcef pairs `EGL_PLATFORM_WAYLAND_EXT`
  with an X11 `Display*`, segfaulting the GPU helper in
  `dri2_initialize_wayland` on every launch. Drop the flag once Spotify ships
  a fixed build (a native Wayland window also changes the class to `spotify`).
- `megacmd` is a pacman package from MEGA's own repo `[DEB_Arch_Extra]`
  (`https://mega.nz/linux/repo/Arch_Extra/$arch`), configured in
  `/etc/pacman.conf` — a machine-level change this repo does not manage.
  Because that repo provides it, `pacman -Syu` and `omarchy update` upgrade
  megacmd with the rest of the system, and it must not appear in `pacman -Qm`.
  `install_and_setup_mega` only downloads the tarball and runs `pacman -U`,
  which registers the package locally but adds no repo, so without the
  `[DEB_Arch_Extra]` entry the install is foreign and never updates.
- `config/opencode/.config/opencode/` — only `opencode.json` + `tui.json` are tracked. `package.json`, `package-lock.json`, `node_modules/`, `bun.lock` are **OpenCode-generated artifacts** (gitignored). Never commit them.
- `~/.config/<app>` is usually a **symlink into the repo** (Stow). Tools that copy into `~/.config` write *through* the symlink into the repo, so re-sourcing the affected tool picks the change up.
- The `omarchy-themes` and `omarchy-menu` packages stow into `~/.config/omarchy`, which Omarchy owns. `omarchy.sh` and `restow` create `~/.config/omarchy/themes` and `~/.config/omarchy/extensions` first so Stow descends into them instead of folding the whole directory into a repo symlink (which would make Omarchy write its own configs into the repo).
- `omarchy.sh`: the Arch repos and the Omarchy package repo are reached through `omarchy-pkg-add`; AUR packages are not installed by the script.
- Commit style is Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`), as seen in `git log`.

## Colors

**Single source of truth: the Omarchy theme selected on the machine.** No
palette is defined in this repo, except the custom Ayu Dark theme below; configs
reference the active theme's colors.

- Terminal and prompt (kitty, starship) — kitty includes
  `~/.local/state/omarchy/current/theme/kitty.conf`, the palette Omarchy
  regenerates from the theme's `colors.toml`; starship uses ANSI color names
  only (`red`, `green`, `yellow`, `cyan`, `bright-black`, …), so both follow
  `omarchy theme set` with no dotfiles change.
- Bar, notifications, launcher, lock screen, GTK — themed by Omarchy itself;
  this setup only sets text/format options (e.g. the bar clock format), never
  colors.
- `omarchy-themes` (Stow package) installs a custom **Ayu Dark** theme at
  `~/.config/omarchy/themes/ayu-dark/`, because Omarchy ships none. Its
  `colors.toml` defines the palette (bg `#0b0e14`, accent `#59c2ff` — the Ayu
  blue — matching `Shatur/neovim-ayu`'s ayu_dark body colours used by rnvim),
  and Omarchy generates every app's colors from it, so it remains the single
  source of truth. It ships one background
  (`backgrounds/g8dqvl-sunset-ridges.jpg`, 2560x1440), which is also the tile
  the theme selector uses; extra images can go in
  `~/.config/omarchy/backgrounds/ayu-dark/`.
- Known gap: `config/herdr/.config/herdr/config.toml` still pins fixed values
  under `[theme.custom]` because herdr has no Omarchy theme integration. Treat
  it as debt: do not extend fixed values to other configs, and converge herdr
  when a supported mapping exists.
