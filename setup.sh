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
# Constants
# -----------------------------------------------------------------------------

DOTFILES_REPO=https://github.com/MrRoiz/.dotfiles.git
DOTFILES_DIR="$HOME/.dotfiles"

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

print_header() {
  echo ""
  echo "╔══════════════════════════════════════════════════════════════════════════════╗"
  echo "║  $1"
  echo "╚══════════════════════════════════════════════════════════════════════════════╝"
  echo ""
}

print_step() {
  echo "──────────────────────────────────────────────────────────────────────────────────"
  echo ">>> $1"
  echo "──────────────────────────────────────────────────────────────────────────────────"
}

print_substep() {
  echo "    → $1"
}

install_package() {
  print_substep "Installing: $1"
  yay -S $1 --needed
}

check_or_install_yay() {
  print_step "Checking/Installing yay AUR helper"
  if command -v yay &>/dev/null; then
    print_substep "yay is already installed"
    print_substep "Upgrading system..."
    yay # Upgrade system
    return
  fi

  print_substep "Installing yay from AUR..."
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si

  # Remove installed yay build files
  cd ..
  rm -rf yay

  print_substep "Upgrading system..."
  yay # Upgrade system

  cd $HOME
}

enable_multilib() {
  print_step "Enabling multilib repository"
  # Enable multilib repository for 32-bit packages (required for Steam)
  if grep -q "^\[multilib\]" /etc/pacman.conf; then
    print_substep "multilib is already enabled"
    return
  fi

  print_substep "Uncommenting [multilib] section in pacman.conf..."
  # Uncomment [multilib] section
  sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
  sudo yay -Sy
}

check_or_clone_dotfiles() {
  print_step "Checking/Cloning dotfiles repository"
  if [ -d $DOTFILES_DIR ]; then
    print_substep "dotfiles repo already exists"
  else
    print_substep "Cloning dotfiles repository..."
    git clone https://github.com/MrRoiz/.dotfiles.git $DOTFILES_DIR
  fi
}

stow_dotfiles() {
  print_step "Stowing dotfiles"
  print_substep "Installing stow..."
  install_package stow
  print_substep "Applying dotfiles with stow..."
  cd "$DOTFILES_DIR/config"
  stow --restow -t $HOME *
  cd $HOME
}

setup_zshrc() {
  print_step "Setting up .zshrc"
  local zshrc="$HOME/.zshrc"
  local dotfiles_export='export DOTFILES_PATH="$HOME/.dotfiles"'
  local source_line='source "$DOTFILES_PATH/zsh/setup.sh"'

  if ! grep -qF "$dotfiles_export" "$zshrc" 2>/dev/null; then
    # Prepend both lines to .zshrc (create if doesn't exist)
    echo -e "$dotfiles_export\n$source_line\n$(cat "$zshrc" 2>/dev/null)" >"$zshrc"
    print_substep "Added dotfiles setup to .zshrc"
  else
    print_substep ".zshrc already configured"
  fi
}

install_docker() {
  print_step "Installing Docker"
  install_package "docker docker-compose docker-buildx"
  print_substep "Enabling docker service..."
  sudo systemctl enable --now docker
  print_substep "Setting up docker group..."
  getent group docker || sudo groupadd docker
  sudo usermod -aG docker $USER
}

setup_sddm_autologin() {
  print_step "Setting up SDDM autologin"
  local config_file="/etc/sddm.conf.d/autologin.conf"
  local expected_content="[Autologin]
User=$USER
Session=hyprland"

  if [[ -f "$config_file" ]] && [[ "$(cat "$config_file")" == "$expected_content" ]]; then
    print_substep "SDDM autologin already configured"
    return
  fi

  print_substep "Configuring autologin for $USER with hyprland session..."
  sudo mkdir -p /etc/sddm.conf.d
  echo "$expected_content" | sudo tee "$config_file" >/dev/null
  print_substep "SDDM autologin configured"
}

install_ohmyzsh() {
  print_step "Installing Oh My Zsh"
  if [ -d "$HOME/.oh-my-zsh" ]; then
    print_substep "Oh My Zsh is already installed"
    return
  fi

  print_substep "Installing zsh-syntax-highlighting plugin..."
  # Install plugins
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  print_substep "Installing zsh-autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  print_substep "Installing zsh-history-substring-search plugin..."
  git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
  print_substep "Installing you-should-use plugin..."
  git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use

  print_substep "Installing powerlevel10k theme..."
  # Install theme
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

  print_substep "Installing Oh My Zsh framework..."
  # Install oh my zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

setup_theme() {
  print_step "Setting up theme..."
  install_package "gnome-themes-extra gnome-themes-extra-gtk2 adwaita-qt5-git adwaita-qt6-git" # Dark mode theme
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
}

setup_git() {
  print_step "Setting up Git configuration"
  local current_name=$(git config --global user.name 2>/dev/null)
  local current_email=$(git config --global user.email 2>/dev/null)

  if [[ -n "$current_name" && -n "$current_email" ]]; then
    print_substep "Git already configured: $current_name <$current_email>"
    read -p "    → Do you want to reconfigure? [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && return
  fi

  print_substep "Enter your Git user name:"
  read -p "    → " git_name
  print_substep "Enter your Git email:"
  read -p "    → " git_email

  git config --global user.name "$git_name"
  git config --global user.email "$git_email"
  print_substep "Git configured: $git_name <$git_email>"
}

# -----------------------------------------------------------------------------
# Main Script Execution
# -----------------------------------------------------------------------------

print_header "ARCH LINUX SETUP SCRIPT"

print_header "SYSTEM PREPARATION"
check_or_install_yay
enable_multilib

# -- Install Packages --

print_header "INSTALLING PACKAGES - COMPOSITOR"
# Compositor
install_package "hyprland hyprpaper hyprlock hypridle waybar" # Compositor

print_header "INSTALLING PACKAGES - HYPRLAND ESSENTIALS"
# Hyprland MUST-HAVE see: https://wiki.hypr.land/Useful-Utilities/Must-have
install_package "qt5-wayland qt6-wayland"     # QT Support for Wayland
install_package "pipewire wireplumber"        # Screen sharing support
install_package "polkit-gnome"                # Polkit, to test it run: pkexec echo "Hello world"
install_package "xdg-desktop-portal-hyprland" # XDG Desktop Portal handles a lot of stuff for your desktop, like file pickers, screensharing, etc.
install_package "libnotify swaync"            # Notifications
install_package "wl-clipboard"                # Clipboard

print_header "INSTALLING PACKAGES - SYSTEM"
# System
install_package "gnome-keyring seahorse" # Keyring manager, some apps need it to store keys/passwords
install_package sddm                     # Display manager
install_package "satty slurp grim"       # Screenshots. NOTE: Does it need wl-copy?
install_package swayosd
setup_theme

print_header "INSTALLING PACKAGES - MULTIMEDIA"
# Multimedia
install_package "vlc vlc-plugins-all" # Video player
install_package eog                   # Image viewer (eye of gnome)
install_package nautilus              # File explorer
install_package spotify               # Music streaming app
install_package obs-studio            # Screen recording and streaming

print_header "INSTALLING PACKAGES - CONTROLS"
# Controls
install_package better-control-git      # Bluetooth and WIFI control
install_package "pavucontrol playerctl" # Audio control
install_package brightnessctl           # Brightness control

print_header "INSTALLING PACKAGES - FONTS"
# Fonts
install_package "noto-fonts noto-fonts-cjk noto-fonts-emoji" # Fonts
install_package ttf-jetbrains-mono-nerd                      # Nerd Font for terminal and code editor

print_header "INSTALLING PACKAGES - TERMINAL"
# Terminal Emulator
install_package kitty     # Terminal emulator
install_package btop      # System monitor
install_package fastfetch # System info fetcher
install_package eza       # Enhanced ls command
install_package zsh       # Zsh shell

print_header "INSTALLING PACKAGES - UTILITIES"
# Utilities
install_package steam                                # Gaming platform (requires multilib)
install_package proton-vpn-gtk-app                   # Proton vpn client
install_package vicinae-bin                          # App launcher
install_package 1password                            # Password manager
install_package "zen-browser-bin helium-browser-bin" # Browsers
install_package obsidian                             # Note-taking app
install_package libreoffice-fresh                    # Office suite
install_package gnome-calculator                     # Calculator

print_header "INSTALLING PACKAGES - DEVTOOLS"
# Devtools
install_package opencode-bin
install_package unzip
install_package dbeaver-ce-bin
install_package just
install_package tenv-bin        # Terraform version manager
install_package fzf             # Fuzzy finder
install_package neovim          # Text editor
install_package ripgrep         # Search tool
install_package imagemagick     # Image manipulation
install_package "nvm yarn pnpm" # Node version manager
install_package uv              # Python package manager
install_package aws-cli-v2      # AWS CLI
install_package sops            # Secrets management tool
install_package rust            # Rust programming language
install_docker

print_header "CONFIGURATION"
# -- Config --
setup_git
check_or_clone_dotfiles
stow_dotfiles
setup_zshrc
setup_sddm_autologin

print_step "Setting up wallpaper"
# Setup wallpaper
sudo bash $DOTFILES_DIR/scripts/change-wallpaper.sh $DOTFILES_DIR/wallpapers

install_ohmyzsh # Oh My Zsh framework

print_header "SETUP COMPLETE!"
