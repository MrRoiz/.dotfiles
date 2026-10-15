#!/usr/bin/env bash

# =============================================================================
# Omarchy Setup Script
# =============================================================================
# Runs on top of an Omarchy installation:
#   1. Removes preinstalled Omarchy apps we don't use (personal cleaner).
#   2. Installs the personal package set, always through omarchy commands.
#   3. Ports dotfiles (stow), zsh, defaults, and the status bar clock.
#
# Usage:
#   Direct:  bash ~/.dotfiles/scripts/omarchy.sh
#
# Omarchy commands used:
#   - omarchy-pkg-add <pkgs...>      non-interactive install (Arch repos +
#                                    the Omarchy package repo)
#   - omarchy-pkg-drop <pkgs...>     non-interactive remove
#   - omarchy-webapp-remove-all      removes every Chromium web app
#
# The login shell intentionally stays bash: the SDDM -> wayland-session ->
# /etc/profile.d boot chain expects it
# (https://github.com/omacom/omarchy/discussions/2495). Zsh comes through the
# official omarchy-zsh package: omarchy-setup-zsh makes ~/.bashrc exec zsh and
# loads Omarchy's shell config (starship prompt replaces p10k), with the
# dotfiles aliases/functions appended after that template. zsh launches
# through the bash exec-zsh drop-in that omarchy-setup-zsh writes.
# =============================================================================

set -e

# Constants
DOTFILES_REPO="https://github.com/MrRoiz/.dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
SCRIPT_DIR="$DOTFILES_DIR/scripts"

# Stow packages applied on Omarchy. The rest of config/ (hyprland, swaync,
# vicinae, waybar, wlogout, satty, sherlock) is dropped because those apps
# are no longer installed here — Omarchy's own stack replaces them or they
# were never omarchy-relevant.
STOW_PACKAGES=(kitty herdr opencode mega)

# =============================================================================
# Local Helpers
# =============================================================================
# The Omarchy setup is self-contained: it does not source the other scripts
# in scripts/setup/ (those are the non-omarchy installer's helpers and pull
# in functions irrelevant here, like stow_dotfiles / setup_sddm). The few
# helpers the flow still needs are inlined below.

# AUR install: omarchy-pkg-aur-install is an interactive fzf picker, so go
# straight through yay.
install_package() {
  print_step "Installing (yay): $1"
  yay -S $1 --needed
}

# rnvim: drop Omarchy's prebuilt LazyVim config (omarchy-nvim) and replace it
# with the user's rnvim setup. omarchy-nvim ships ~/.config/nvim as part of
# its PKGBUILD, so removing the package also removes the dir; we defensively
# wipe it before cloning rnvim in case the package has already been
# removed but the dir is still there.
install_rnvim() {
  print_header "INSTALLING PACKAGES - RNVIM CONFIGURATION"

  print_substep "Removing omarchy-nvim (LazyVim prebuilt config)..."
  omarchy-pkg-drop omarchy-nvim

  rm -rf "$HOME/.config/nvim"

  if [ -d "$HOME/.config/nvim" ]; then
    print_substep "rnvim already installed, pulling latest changes..."
    git -C "$HOME/.config/nvim" pull
  else
    git clone https://github.com/MrRoiz/rnvim.git "$HOME/.config/nvim"
    print_substep "rnvim installed!"
  fi
}

# Mega: same flow as the non-omarchy installer — guided, asks before
# anything destructive. The systemd unit ships as a user service in the
# `mega` stow package (config/mega/.config/systemd/user/mega-cmd.service)
# and is enabled with `systemctl --user` after stow runs.
install_and_setup_mega() {
  print_header "INSTALLING PACKAGES - MEGA"

  if command -v mega-cmd &>/dev/null; then
    print_substep "Mega cmd is already installed"
    return
  fi

  read -p "Do you want to install and setup Mega? [y/N] " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Yy]$ ]] && return

  wget https://mega.nz/linux/repo/Arch_Extra/x86_64/megacmd-x86_64.pkg.tar.zst -P /tmp && \
    sudo pacman -U "/tmp/megacmd-x86_64.pkg.tar.zst"

  MEGA_SYNC_FOLDER="$HOME/Mega"
  mkdir -p $MEGA_SYNC_FOLDER

  echo ""
  read -p "Enter your Mega email: " -r mega_email
  read -s -p "Enter your Mega password: " -r mega_password
  echo ""

  mega-login "$mega_email" --password "$mega_password"
  mega-sync $MEGA_SYNC_FOLDER /

  # The unit is enabled in the configuration phase (after stow has linked
  # ~/.config/systemd/user/mega-cmd.service into place). The install above
  # has populated ~/.config/Mega; the daemon picks that up on next start.
  print_substep "Mega configured (systemd enable runs after stow)"
}

# Clone the dotfiles repo at $DOTFILES_DIR if it isn't there already.
check_or_clone_dotfiles() {
  print_step "Checking/Cloning dotfiles repository"
  if [ -d "$DOTFILES_DIR" ]; then
    print_substep "dotfiles repo already exists"
  else
    print_substep "Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
}

# =============================================================================
# Terminal Style
# =============================================================================
# Plain-text sectioned output: big boxed headers, ruled steps, indented
# substeps, ✓ / ✗ / ! status glyphs. No colors: the user will pick a palette
# later, and palette references in the install path only get in the way of
# that choice. The glyphs (◆ ▸ · ✓ ✗ !) survive the removal — they're text,
# not color.

G_DIA='◆'; G_STEP='▸'; G_SUB='·'; G_OK='✓'; G_FAIL='✗'; G_WARN='!'

H_BAR='════════════════════════════════════════════════════════════════════════════════'
S_BAR='──────────────────────────────────────────────────────────────────────────────────'

print_header() {
  local title="$1"
  printf '\n'
  printf '╔%s╗\n'  "$H_BAR"
  printf '║  %s %s\n' "$G_DIA" "$title"
  printf '╚%s╝\n'  "$H_BAR"
  printf '\n'
}

print_step() {
  printf '\n'
  printf '%s\n' "$S_BAR"
  printf '%s  %s\n' "$G_STEP" "$1"
  printf '%s\n' "$S_BAR"
}

print_substep() {
  printf '    →  %s\n' "$1"
}

print_ok()    { printf '    %s   %s\n' "$G_OK"   "$1"; }
print_warn()  { printf '    %s   %s\n' "$G_WARN" "$1"; }
print_fail()  { printf '    %s   %s\n' "$G_FAIL" "$1"; }

print_done() {
  local title="$1"
  printf '\n'
  printf '╔%s╗\n'  "$H_BAR"
  printf '║  %s %s\n' "$G_OK" "$title"
  printf '╚%s╝\n'  "$H_BAR"
  printf '\n'
}

show_banner() {
  printf '\n'
  printf '   ┌──────────────────────────────────────────────────────────┐\n'
  printf '   │                                                          │\n'
  printf '   │  %s OMARCHY  personal setup                            │\n' "$G_DIA"
  printf '   │  cleaner · omarchy install commands · stow               │\n'
  printf '   │                                                          │\n'
  printf '   └──────────────────────────────────────────────────────────┘\n'
  printf '\n'
}

# =============================================================================
# Omarchy Preinstalls Cleaner
# =============================================================================
# Personal cleaner, based on upstream bin/omarchy-remove-preinstalls with
# two tweaks: TUI desktop apps are KEPT (upstream also runs
# omarchy-tui-remove-all) and the mise stubs are KEPT (claude, opencode,
# gh, ...). Both happen by simply not running the corresponding upstream
# commands — the result is fewer packages removed than upstream drops.
# =============================================================================

clean_omarchy_preinstalls() {
  print_header "REMOVING OMARCHY PREINSTALLS"

  if ! gum confirm --affirmative "Yes" --negative "No" "Remove preinstalled Omarchy apps (all web apps + unused packages)?"; then
    print_warn "Skipping preinstall cleanup"
    return
  fi

  print_substep "Removing all web apps..."
  omarchy-webapp-remove-all

  # Mark preinstalls as handled so Omarchy does not re-provision them.
  mkdir -p ~/.local/state/omarchy
  touch ~/.local/state/omarchy/preinstalls-removed

  # Only the explicitly unwanted ones: cliamp and moonlight-qt. Everything
  # else upstream drops (aether, pinta, obsidian, omacut, monologue, omacalc,
  # omawrite, hype, signed, ...) stays.
  print_substep "Dropping unused preinstalled packages..."
  omarchy-pkg-drop cliamp moonlight-qt
  print_ok "Removed cliamp and moonlight-qt"
}

# =============================================================================
# Omarchy Package Installation
# =============================================================================
# Everything not already preinstalled by Omarchy's base set. Skipped on
# purpose (omarchy-base.packages already provides them): docker,
# docker-compose, docker-buildx, tmux, fzf, jq, eza, btop,
# ripgrep, imagemagick, nvim, unzip, man-db, gnome-keyring, wl-clipboard,
# sddm, yay, mise, herdr, localsend, noto-fonts (+cjk/+emoji),
# brightnessctl, bluez, starship, zoxide, nautilus.
#
# Also NOT installed here because the Omarchy stack replaces them:
#   - vicinae-bin (Omarchy's own quickshell launcher)
#   - swaync      (Omarchy handles notifications itself)
#   - swayosd     (omarchy-osd)
#   - better-control-git (omarchy-bluetooth-device / omarchy-network-*)
#   - satty      (omarchy-capture-* -> the preinstalled omasnap app)
#   - seahorse   (gnome-keyring is preinstalled; 1Password covers secrets)
# =============================================================================

omarchy_pkg_add() {
  print_step "Installing via omarchy-pkg-add: $1"
  omarchy-pkg-add $1
}

install_omarchy_packages() {
  print_header "INSTALLING PACKAGES - OMARCHY"

  # Compositor / Hyprland essentials
  # Omarchy already provides the hyprland stack (hyprpaper/hyprlock/hypridle,
  # qt6-wayland), its own polkit agent, and the screenshot flow
  # (omarchy-capture-* -> omasnap; grim/slurp are preinstalled, no satty
  # needed). gnome-keyring is preinstalled; 1Password covers secrets, so the
  # seahorse GUI is skipped too.

  # Multimedia (mpv ships in omarchy-base.packages, so no vlc; imv is the
  # preinstalled image viewer; omarchy records through gpu-screen-recorder)
  omarchy_pkg_add "obs-studio"

  # Fonts — omarchy ships ttf-jetbrains-mono-nerd-basic (smaller icon set);
  # the full Nerd Font adds the rest of the Material Design / FA / etc.
  # glyphs the basic variant strips. kitty config uses "JetBrainsMono NF".
  omarchy_pkg_add "ttf-jetbrains-mono-nerd"

  # Steam, Spotify and Zed are not pre-installed here. The Omarchy launcher
  # installs them lazily on first open via omarchy-install-and-launch (which
  # runs the install halves — lib32 GPU drivers for Steam, the package, and
  # the omarchy-lifecycle-dispatch post-install hook — then launches the
  # app). Pre-installing them in setup would do the same work twice.

  # Terminal
  # kitty is installed through omarchy-install-terminal in the configuration
  # phase, after stow, so it becomes the default terminal without Omarchy
  # copying its default kitty config over the stowed one.

  # Utilities
  # 1password (+1password-cli) and its Chromium extension are installed by
  # omarchy-install-service-1password, which omarchy-launch-1password runs
  # automatically on first launch.
  omarchy_pkg_add "typora"             # Omarchy package repo
  omarchy_pkg_add "slack-desktop"      # Omarchy package repo
  omarchy_pkg_add "veracrypt"

  # Devtools
  # terraform/terragrunt/aws-cli-v2/proton-vpn-gtk-app/nvm straight from the Arch repos
  # (aws-cli-v2 is the official [extra] v2 package). mise is preinstalled
  # on Omarchy (omarchy-base.packages: mise-bin) and is reserved for
  # node / Claude / opencode / gh stubs — we don't pin terraform or
  # terragrunt through it.
  omarchy_pkg_add "github-cli dbeaver just packer"
  omarchy_pkg_add "terraform terragrunt aws-cli-v2 nvm proton-vpn-gtk-app"
  omarchy_pkg_add "sops wget bind"
  omarchy_pkg_add "uv lazydocker"

  # Apps installed through their dedicated Omarchy app installer. Zen
  # stays because it doesn't auto-launch; rust goes through mise.
  omarchy-install-browser zen         # installs zen-browser-bin + chromium policies
  omarchy-install-dev-env rust
}

install_omarchy_aur_packages() {
  # omarchy-pkg-add / omarchy-install-app use pacman and do not fall back
  # to AUR. omarchy-pkg-aur-install is the dedicated AUR path but it runs
  # `yay -Slqa | fzf` as a picker (args are ignored), so it's interactive-
  # only. We run `yay -S` directly (the same invocation omarchy-pkg-aur-
  # install uses after the picker).
  print_header "INSTALLING PACKAGES - AUR"

  # install_package "helium-browser-bin"   # skipped: AUR-only; TODO is to PR it into
                                         # omacom/omarchy-pkgs first, then switch to
                                         # omarchy-pkg-add (mirrors the yaak-bin#1147 path)
  install_package "ngrok"                   # pending in omarchy-pkgs#1145
  install_package "yaak-bin"                # pending in omarchy-pkgs#1147
}

setup_omarchy_docker() {
  print_header "SETTING UP DOCKER (OMARCHY)"

  # docker / docker-compose / docker-buildx ship in omarchy-base.packages.
  print_substep "Enabling docker service..."
  sudo systemctl enable --now docker

  # Omarchy's sudoless-docker setup (asks y/N via gum).
  omarchy-setup-security-sudoless-docker
}

# =============================================================================
# Zsh
# =============================================================================
# Zsh switches through the official omarchy-zsh package. omarchy-setup-zsh
# backs up the rc files, installs Omarchy's template ~/.zshrc (zoptions +
# shared shell config loading the starship prompt) and appends the bash
# exec-zsh drop-in, so the login shell stays bash. The dotfiles' own
# aliases/functions are appended after the template via zsh/setup.sh
# (which also sources nvm and the .nvmrc autoload). omz is intentionally
# NOT installed: its features overlap with omarchy-zsh's zoptions
# (history search, syntax highlighting, fzf widgets, omadots aliases) and
# the missing pieces are kept minimal in the dotfiles' own aliases.
# =============================================================================

setup_omarchy_zsh() {
  print_header "SETTING UP ZSH"

  omarchy_pkg_add "omarchy-zsh"
  omarchy-setup-zsh

  local zshrc="$HOME/.zshrc"
  if ! grep -q "dotfiles/zsh/setup.sh" "$zshrc"; then
    cat >> "$zshrc" <<'EOF'

# Dotfiles zsh: nvm + .nvmrc autoload, aliases, functions.
source "$HOME/.dotfiles/zsh/setup.sh"
EOF
  fi
}

# =============================================================================
# Status Bar Clock
# =============================================================================
# Omarchy quattro ships its own bar (no waybar); the clock format is set
# with `omarchy-bar set`. Matches the dotfiles waybar clock text
# `{0:%b %d} {0:%I:%M%p}` -> "Oct 15 10:30PM".
#
# NOTE: right-clicking the clock cycles the built-in formats and writes the
# choice back to shell.json, which would replace this custom format.
# =============================================================================

setup_omarchy_bar_clock() {
  print_header "SETTING UP BAR CLOCK"

  # Qt format: MMM=abbrev month, dd=padded day, hh=12h padded, AP=AM/PM
  omarchy-bar set omarchy.clock format "MMM dd hh:mmAP"
}

setup_omarchy_1password_browsers() {
  print_header "TRUSTING BROWSERS IN 1PASSWORD"

  # OPR zen-browser-bin installs /usr/bin/zen (zen-bin is the old AUR name).
  sudo mkdir -p /etc/1password
  sudo touch /etc/1password/custom_allowed_browsers
  echo "zen" | sudo tee /etc/1password/custom_allowed_browsers >/dev/null
  sudo chown root:root /etc/1password/custom_allowed_browsers
  sudo chmod 755 /etc/1password/custom_allowed_browsers
}

# Set zen as the default browser and kitty as the default terminal via the
# same commands the Omarchy launcher uses. Idempotent (both just write the
# value every time; no launches).
setup_omarchy_defaults() {
  print_header "SETTING OMARCHY DEFAULTS"

  omarchy-default-browser zen
  omarchy-default-terminal kitty
}

# Stow only the packages whose apps are still installed/configured on Omarchy,
# and wipe their ~/.config entries first so stow does not refuse on the files
# Omarchy ships there by default.
stow_personal_dotfiles() {
  print_step "Stowing personal dotfiles"

  for pkg in "${STOW_PACKAGES[@]}"; do
    rm -rf "$HOME/.config/$pkg"
  done
  # Drop .config dirs whose apps are not installed on Omarchy.
  for pkg in hyprland swaync vicinae waybar wlogout satty sherlock; do
    rm -rf "$HOME/.config/$pkg"
  done

  cd "$DOTFILES_DIR/config"
  stow --restow -t "$HOME" "${STOW_PACKAGES[@]}"
  cd "$HOME"
  print_ok "Stowed: ${STOW_PACKAGES[*]}"
}

# =============================================================================
# Main Script Execution
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if ! command -v omarchy &>/dev/null; then
    echo "Error: this script must run on an Omarchy system, 'omarchy' not found." >&2
    exit 1
  fi

  print_header "OMARCHY PERSONAL SETUP"
  show_banner

  # multilib is enabled by Omarchy's base install (default/pacman/pacman-*.conf
  # ships it; install/post-install/pacman.sh copies the file in place).

  # -- Remove Preinstalls --
  clean_omarchy_preinstalls

  # -- Install Packages --
  install_omarchy_packages
  install_omarchy_aur_packages
  install_and_setup_mega
  setup_omarchy_docker

  # -- Configuration --
  print_header "CONFIGURATION"
  # Git identity is already set by Omarchy's install/user/git.sh.
  check_or_clone_dotfiles
  # Stow only the packages that apply to Omarchy (see STOW_PACKAGES); this
  # also removes the old .config entries Omarchy shipped so stow does not
  # conflict, plus the dirs for apps we no longer install here.
  stow_personal_dotfiles
  # Mega's user systemd unit was just stowed into ~/.config/systemd/user;
  # enable + start it now that the file is in place.
  if command -v mega-cmd &>/dev/null; then
    systemctl --user enable --now mega-cmd
  fi
  # rnvim drops omarchy-nvim and replaces ~/.config/nvim with the user's
  # rnvim setup.
  install_rnvim
  # Install kitty as the Omarchy default terminal; runs after stow so the
  # stowed kitty.conf wins over Omarchy's default one.
  omarchy-install-terminal kitty
  # swaync and the battery-warning timer are not used here: Omarchy handles
  # notifications and low-battery warnings with its own shell.
  setup_omarchy_bar_clock
  setup_omarchy_defaults
  setup_omarchy_1password_browsers
  # zsh last: it appends to ~/.zshrc, so anything that ever wanted to
  # touch the file would land in a clean spot.
  setup_omarchy_zsh

  print_done "SETUP COMPLETE!"
fi
