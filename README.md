# dotfiles

Personal dotfiles for the
[Omarchy](https://github.com/omacom/omarchy) `quattro` channel. The repo is
trimmed to the Omarchy-only setup — stow packages, the shell stack, and
the entrypoint all target Omarchy's stack.

## TODO: move AUR packages to OPR

These packages are still installed via `yay` in `scripts/omarchy.sh`.
The end goal is to package each one into
[`omacom/omarchy-pkgs`](https://github.com/omacom/omarchy-pkgs) so
`omarchy-pkg-add` can pick them up (the OPR is the canonical install
path on Omarchy; the script falls back to `yay` only because these
have not landed there yet).

- [x] `yaak-bin` — API client (PR open: [omacom/omarchy-pkgs#1147](https://github.com/omacom/omarchy-pkgs/pull/1147))
- [x] `ngrok` — Tunneling / reverse proxy (PR open: [omacom/omarchy-pkgs#1145](https://github.com/omacom/omarchy-pkgs/pull/1145))
- [ ] `helium-browser-bin` — Browser (currently commented out in the
      script; would need a PR before this is usable).

## Quick Install

The setup is invoked directly from the omarchy-zsh package-managed shell
on an existing Omarchy install. Clone the repo, then run the script:

```bash
git clone https://github.com/MrRoiz/.dotfiles.git ~/.dotfiles
~/.dotfiles/scripts/omarchy.sh
```

The script clones the dotfiles into `~/.dotfiles` and runs
`scripts/omarchy.sh`. The script is idempotent (each step
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
   - `omarchy-install-dev-env node` / `... python` plus `mise use --global
     herdr terraform terragrunt` for the toolchains — Omarchy preinstalls
     mise (`mise-bin`) and puts its shims on `PATH`, so node, python (`uv`
     comes with it), herdr, terraform and terragrunt are all mise-managed
     instead of Arch/AUR packages (no nvm). The Omarchy `herdr` package is
     dropped so the client and server always track the latest upstream
     release.
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
     `zsh/aliases/git.sh` fill the gap left by dropping omz's `git`
     plugin; oh-my-zsh and p10k are intentionally not used.
   - `yay` for AUR-only packages (`ngrok`, `yaak-bin`,
     with `helium-browser-bin` commented out as a TODO to PR into OPR)
3. **Configures**:
   - Stows only the packages whose apps are installed on Omarchy
     (`kitty`, `herdr`, `opencode`, `mega`, `starship`) and removes
     `~/.config/<pkg>` for them and for the dropped apps
     (`hyprland`, `swaync`, `vicinae`, `waybar`, `wlogout`, `satty`,
     `sherlock`) so `stow` does not conflict. The `wireplumber` package is
     stowed separately for the headset-mic helper (see
     [Headset microphone](#headset-microphone)) so Omarchy's own
     WirePlumber configs are preserved.
   - Sets `omarchy-default-browser zen` and `omarchy-default-terminal
     kitty` (the same commands the Omarchy launcher's defaults menu uses).
   - `omarchy bar set omarchy.clock format "MMM dd hh:mmAP"` — matches
     the clock text format the dotfiles used to print under waybar
     (`{0:%b %d} {0:%I:%M%p}`).
   - 1Password trusts `zen-bin` (the Zen browser process name).
   - rnvim drops `omarchy-nvim` (the prebuilt LazyVim config Omarchy
     ships) and replaces `~/.config/nvim` with the user's rnvim setup.

## Headset microphone

The 3.5 mm combo jack is a single socket for both headphones and a headset
microphone. The sound card actually exposes **two microphones behind that one
socket**: the internal mic and the headset's mic. Linux sees them as
two *ports* — think "input choices" — of the same microphone device.

Omarchy's audio panel lists microphone **devices**, not ports, so the headset
mic has no row to click. It also falls back to the internal mic after the
headset is unplugged and plugged back in.

A WirePlumber rule (`api.acp.auto-port`) was tried first, but it did not
restore the headset port after a replug on the ALC256 codec.

So the repo installs a tiny user service, `omarchy-headset-mic`, which watches
the headphone jack and selects the matching input:

| Jack state | Microphone used |
| --- | --- |
| headset plugged in | headset mic (`analog-input-headset-mic`) |
| headset unplugged | internal mic (`analog-input-internal-mic`) |

It is installed even if the headset is unplugged during setup: the headset
mic may only appear when something is plugged in, and the service waits for
it. On machines without that port or jack control it does nothing, and it
never touches output, Bluetooth, or other audio devices.

It runs as a per-user service. To turn it off:

```bash
systemctl --user disable --now omarchy-headset-mic.service
```

The service does **not** set input volume. On the ALC256 codec 100% adds +30 dB
of capture gain plus +30 dB of analog boost and clips; lower the input once in
the Omarchy audio panel. Around 40% is the highest level without the analog
boost, and WirePlumber remembers it per port.

## Window focus with HJKL

`SUPER + H/J/K/L` focuses windows and `SUPER + SHIFT + H/J/K/L` swaps them.
The three Omarchy defaults that used J/K/L moved:

| Old | New |
| --- | --- |
| `Super + J` toggle split | `Super + Alt + J` |
| `Super + K` keybindings | `Super + Ctrl + Shift + K` |
| `Super + L` workspace layout | `Super + Alt + L` |

`bindings.lua` in the `hypr` package unbinds the original `SUPER + J/K/L`,
rebinds the displaced actions above, then adds the HJKL keys. No Fn layer
needed.

## Layout

- `scripts/omarchy.sh` — the only installer; self-contained
  (does not source other scripts/setup files).
- `config/bin/.local/bin/restow` — restow every managed package from
  `~/.dotfiles` (main packages + `hypr` + `wireplumber` + `starship`).
- `config/hypr/.config/hypr/{looknfeel,input,bindings,monitors}.lua` —
  personal Hyprland overrides. The `hypr` package is stowed file-by-file so
  the rest of Omarchy's Hyprland config stays managed by Omarchy.
- `config/<app>/.config/<app>/…` — Stow packages. Only the ones whose
  apps are installed on Omarchy are stowed (see `STOW_PACKAGES` in
  `omarchy.sh`). The `mega` package ships the user systemd unit that
  `omarchy.sh` enables after stow; the `starship` package ships the prompt
  config as the single file `~/.config/starship.toml`.
- `zsh/aliases/{git,docker,tools}.sh`, `zsh/functions.sh`, `zsh/setup.sh` —
  sourced by `omarchy.sh` after the omarchy-zsh template. The git aliases in
  `aliases/git.sh` fill the gap left by dropping omz's `git` plugin.

## Notes

- herdr is installed via mise (`mise use -g herdr@latest`) specifically so it
  always runs the latest upstream release instead of the lagging Omarchy
  package. Update it with `mise upgrade herdr`, not `herdr update`, so mise
  keeps ownership of the binary; restart/reattach Herdr afterwards.
- Monitor layout: laptop `eDP-1` on the left (`0x0`) and HDMI `HDMI-A-1` on
  the right (`1920x-300`). The HDMI sits higher; adjust the `-300` offset in
  `config/hypr/.config/hypr/monitors.lua`.
- Node, Python and terraform/terragrunt are mise-managed. The global versions
  live in `~/.config/mise/config.toml` (written by `mise use --global`) and
  per-project versions come from a project `mise.toml`/`.tool-versions`; nvm
  is not installed and `zsh/setup.sh` has no version-manager hook. Node also
  reads `.nvmrc`/`.node-version` (idiomatic version files are enabled for
  `node`), installing a missing version on first use.
- p10k and oh-my-zsh are not used. The prompt is `omarchy-zsh`'s
  starship; history-search, syntax-highlighting and the omadots
  aliases come from the omarchy-zsh package; nothing extra is layered on top.
- On Omarchy the login shell stays bash and zsh launches through the
  bash exec-zsh drop-in that `omarchy-setup-zsh` writes. Do not `chsh`
  to zsh — see
  [discussion #2495](https://github.com/omacom/omarchy/discussions/2495).
- The non-omarchy installer's `scripts/setup/{setup,system,packages,
  dotfiles,utils}.sh` and the unused stow packages / config-templates
  are not part of this repo.
