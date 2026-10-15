# dotfiles

Personal dotfiles for the
[Omarchy](https://github.com/omacom/omarchy) `quattro` channel. The repo is
trimmed to the Omarchy-only setup — stow packages, the shell stack, and
the `install.sh` entrypoint all target Omarchy's stack.

## TODO: move AUR packages to OPR

These packages are still installed via `yay` in `scripts/omarchy.sh`.
The end goal is to package each one into
[`omacom/omarchy-pkgs`](https://github.com/omacom/omarchy-pkgs) so
`omarchy-pkg-add` can pick them up (the OPR is the canonical install
path on Omarchy; the script falls back to `yay` only because these
have not landed there yet).

- [x] `yaak-bin` — API client (PR open: `omacom/omarchy-pkgs#1147`)
- [x] `ngrok` — Tunneling / reverse proxy (PR open: `omacom/omarchy-pkgs#1145`)
- [ ] `helium-browser-bin` — Browser (currently commented out in the
      script; would need a PR before this is usable from `install.sh`)

## Quick Install

```bash
curl -s https://raw.githubusercontent.com/MrRoiz/.dotfiles/feat/omarchy-setup/install.sh > /tmp/install.sh && bash /tmp/install.sh
```

`install.sh` clones the `feat/omarchy-setup` branch into `~/.dotfiles`
and runs `scripts/omarchy.sh`. The script is idempotent (each step
short-circuits when its work is already done) and prints a sectioned
output (boxed headers, ruled steps, status glyphs).

If you already have the repo checked out:

```bash
bash ~/.dotfiles/scripts/omarchy.sh
```

## What `omarchy.sh` does

1. **Personal cleaner** — runs `omarchy-webapp-remove-all` (drops every
   bundled web app), then `omarchy-pkg-drop cliamp moonlight-qt`. TUI
   desktop apps and the mise stubs (claude, opencode, gh, ...) are
   kept on purpose, the opposite of the upstream
   [`omarchy-remove-preinstalls`](https://github.com/omacom/omarchy/blob/quattro/bin/omarchy-remove-preinstalls).
2. **Installs** the personal package set through omarchy commands:
   - `omarchy-pkg-add` for repo + OPR packages
   - `omarchy-install-browser zen` / `omarchy-install-terminal kitty` /
     `omarchy-install-dev-env rust` for the apps with dedicated installers
     (Steam, Spotify and Zed are **not** installed here — the Omarchy
     launcher pulls them in on first open via `omarchy-install-and-launch`)
   - `omarchy-zsh` (+ `omarchy-setup-zsh`) for the shell — installs the
     omarchy-zsh template, makes bash exec zsh, and brings Omarchy's
     starship-based shell config. omarchy-zsh's `zoptions` already
     covers history-search (up/down arrow), zsh-syntax-highlighting and
     fzf file/git/variable widgets, and its `shell/all` ships the
     omadots aliases (ls/cd/git/d/t/n/open). The git aliases in
     `zsh/aliases.sh` fill the gap left by dropping omz's `git`
     plugin; oh-my-zsh and p10k are intentionally not used.
   - `yay` for AUR-only packages (`proton-vpn-gtk-app`, `yaak-bin`,
     with `helium-browser-bin` commented out as a TODO to PR into OPR)
3. **Configures**:
   - Stows only the packages whose apps are installed on Omarchy
     (`kitty`, `herdr`, `opencode`, `mega`) and removes
     `~/.config/<pkg>` for them and for the dropped apps
     (`hyprland`, `swaync`, `vicinae`, `waybar`, `wlogout`, `satty`,
     `sherlock`) so `stow` does not conflict.
   - Sets `omarchy-default-browser zen` and `omarchy-default-terminal
     kitty` (the same commands the Omarchy launcher's defaults menu uses).
   - `omarchy bar set omarchy.clock format "MMM dd hh:mmAP"` — matches
     the clock text format the dotfiles used to print under waybar
     (`{0:%b %d} {0:%I:%M%p}`).
   - 1Password trusts `zen` (the OPR zen-browser-bin binary,
     `/usr/bin/zen`).
   - rnvim drops `omarchy-nvim` (the prebuilt LazyVim config Omarchy
     ships) and replaces `~/.config/nvim` with the user's rnvim setup.

## Layout

- `install.sh` — curl entrypoint.
- `scripts/omarchy.sh` — the only installer; self-contained
  (does not source other scripts/setup files).
- `config/<app>/.config/<app>/…` — Stow packages. Only the ones whose
  apps are installed on Omarchy are stowed (see `STOW_PACKAGES` in
  `omarchy.sh`). The `mega` package ships the user systemd unit that
  `omarchy.sh` enables after stow.
- `zsh/{aliases,functions,setup}.sh` — sourced by `omarchy.sh` after the
  omarchy-zsh template. The git aliases in `aliases.sh` fill the gap
  left by dropping omz's `git` plugin.

## Notes

- p10k and oh-my-zsh are not used. The prompt is `omarchy-zsh`'s
  starship; history-search, syntax-highlighting and the omadots
  aliases come from the omarchy-zsh package; nothing extra is layered on top.
- On Omarchy the login shell stays bash and zsh launches through the
  bash exec-zsh drop-in that `omarchy-setup-zsh` writes. Do not `chsh`
  to zsh — see
  [discussion #2495](https://github.com/omacom/omarchy/discussions/2495).
- The repo branches off the prior plain-Arch installer; the
  `feat/omarchy-setup` branch removes everything that does not serve
  Omarchy (`scripts/setup/{setup,system,packages,dotfiles,utils}.sh`,
  `wallpapers/`, `scripts/change-wallpaper.sh`, and the unused stow
  packages). The `config-templates/` directory was emptied (the mega
  systemd unit moved to the `config/mega/` stow package).
