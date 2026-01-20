#! /usr/bin/env bash

# =============================================================================
# Arch Linux Setup Script
# =============================================================================
# This script automates the setup of a new Arch Linux installation.
# It installs the yay AUR helper, essential packages, and applies dotfiles.
#
# Usage: ./setup.sh
# =============================================================================

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

install_package() {
  yay -S $1 --needed
}

check_or_install_yay() {
  if command -v yay &>/dev/null; then
    echo "yay is already installed"
    yay # Upgrade system
    return
  fi

  sudo pacman -S --needed git base-devel

  # Build yay in a temporary directory
  local tmp_dir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
  cd "$tmp_dir/yay"
  makepkg -si --noconfirm

  # Remove installed yay build files
  cd "$HOME"
  rm -rf "$tmp_dir"

  yay # Upgrade system
}

enable_multilib() {
  # Enable multilib repository for 32-bit packages (required for Steam)
  if grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "multilib is already enabled"
    return
  fi

  # Uncomment [multilib] section
  sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
  sudo pacman -Sy
}

check_or_clone_dotfiles() {
  if [ -d "$HOME/.dotfiles" ]; then
    echo "dotfiles repo already exists"
  else
    git clone https://github.com/MrRoiz/.dotfiles.git "$HOME/.dotfiles"
  fi
}

stow_dotfiles() {
  install_package stow
  cd ~/.dotfiles/config
  stow --restow -t $HOME *
  cd ~
}

setup_zshrc() {
  local zshrc="$HOME/.zshrc"
  local dotfiles_export='export DOTFILES_PATH="$HOME/.dotfiles"'
  local source_line='source "$DOTFILES_PATH/zsh/setup.sh"'

  if ! grep -qF "$dotfiles_export" "$zshrc" 2>/dev/null; then
    # Prepend both lines to .zshrc (create if doesn't exist)
    echo -e "$dotfiles_export\n$source_line\n$(cat "$zshrc" 2>/dev/null)" >"$zshrc"
    echo "Added dotfiles setup to .zshrc"
  else
    echo ".zshrc already configured"
  fi
}

install_docker() {
  install_package "docker docker-compose docker-buildx"
  sudo systemctl enable --now docker
  getent group docker || sudo groupadd docker
  sudo usermod -aG docker $USER
}

setup_sddm_autologin() {
  local config_file="/etc/sddm.conf.d/autologin.conf"
  local expected_content="[Autologin]
User=$USER
Session=hyprland"

  if [[ -f "$config_file" ]] && [[ "$(cat "$config_file")" == "$expected_content" ]]; then
    echo "SDDM autologin already configured"
    return
  fi

  sudo mkdir -p /etc/sddm.conf.d
  echo "$expected_content" | sudo tee "$config_file" >/dev/null
  echo "SDDM autologin configured for $USER with hyprland session"
}

install_ohmyzsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed"
    return
  fi

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
}

# -----------------------------------------------------------------------------
# Main Script Execution
# -----------------------------------------------------------------------------

check_or_install_yay
enable_multilib

# -- Install Packages --

# Compositor
install_package "hyprland hyprpaper hyprlock hypridle waybar" # Compositor

# Hyprland MUST-HAVE see: https://wiki.hypr.land/Useful-Utilities/Must-have
install_package "qt5-wayland qt6-wayland"     # QT Support for Wayland
install_package "pipewire wireplumber"        # Screen sharing support
install_package "polkit-gnome"                # Polkit, to test it run: pkexec echo "Hello world"
install_package "xdg-desktop-portal-hyprland" # XDG Desktop Portal handles a lot of stuff for your desktop, like file pickers, screensharing, etc.
install_package "libnotify swaync"            # Notifications

# System
install_package "gnome-keyring seahorse" # Keyring manager, some apps need it to store keys/passwords
install_package sddm                     # Display manager
install_package "satty slurp grim"       # Screenshots. NOTE: Does it need wl-copy?

# Multimedia
install_package "vlc vlc-plugins-all" # Video player
install_package eog                   # Image viewer (eye of gnome)
install_package nautilus              # File explorer
install_package spotify               # Music streaming app
install_package obs-studio            # Screen recording and streaming

# Controls
install_package better-control-git      # Bluetooth and WIFI control
install_package "pavucontrol playerctl" # Audio control
install_package brightnessctl           # Brightness control

# Fonts
install_package "noto-fonts noto-fonts-cjk noto-fonts-emoji" # Fonts
install_package ttf-jetbrains-mono-nerd                      # Nerd Font for terminal and code editor

# Terminal Emulator
install_package kitty     # Terminal emulator
install_package btop      # System monitor
install_package fastfetch # System info fetcher
install_package eza       # Enhanced ls command
install_package zsh       # Zsh shell
install_ohmyzsh           # Oh My Zsh framework

# Utilities
install_package steam                                # Gaming platform (requires multilib)
install_package proton-vpn-gtk-app                   # Proton vpn client
install_package vicinae-bin                          # App launcher
install_package 1password                            # Password manager
install_package "zen-browser-bin helium-browser-bin" # Browsers
install_package obsidian                             # Note-taking app
install_package libreoffice-fresh                    # Office suite
install_package gnome-calculator                     # Calculator

# Devtools
install_package tenv-bin    # Terraform version manager
install_package fzf         # Fuzzy finder
install_package neovim      # Text editor
install_package ripgrep     # Search tool
install_package imagemagick # Image manipulation
install_package "nvm"       # Node version manager
install_package uv          # Python package manager
install_package aws-cli-v2  # AWS CLI
install_package sops        # Secrets management tool
install_package rust        # Rust programming language
install_docker

# -- Config --
check_or_clone_dotfiles
stow_dotfiles
setup_zshrc
setup_sddm_autologin

# Setup wallpaper
sudo bash $HOME/.dotfiles/scripts/change-wallpaper.sh

# Reboot countdown
echo "Setup complete! Rebooting in 10 seconds... (Ctrl+C to cancel)"
for i in {10..1}; do
  echo "$i..."
  sleep 1
done
sudo reboot
