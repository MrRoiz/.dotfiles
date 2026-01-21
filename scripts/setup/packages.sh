#!/usr/bin/env bash

# =============================================================================
# Package Installation Functions
# =============================================================================
# Functions for installing all required packages organized by category
# =============================================================================

install_compositor_packages() {
  print_header "INSTALLING PACKAGES - COMPOSITOR"
  install_package "hyprland hyprpaper hyprlock hypridle waybar"
}

install_hyprland_essentials() {
  print_header "INSTALLING PACKAGES - HYPRLAND ESSENTIALS"
  # See: https://wiki.hypr.land/Useful-Utilities/Must-have
  install_package "qt5-wayland qt6-wayland"     # QT Support for Wayland
  install_package "pipewire wireplumber"        # Screen sharing support
  install_package "polkit-gnome"                # Polkit
  install_package "xdg-desktop-portal-hyprland" # XDG Desktop Portal
  install_package "libnotify swaync"            # Notifications
  install_package "wl-clipboard"                # Clipboard
}

install_system_packages() {
  print_header "INSTALLING PACKAGES - SYSTEM"
  install_package "gnome-keyring seahorse" # Keyring manager
  setup_sddm
  install_package "satty slurp grim" # Screenshots
  install_package swayosd
  setup_theme
  install_package man-db
}

install_multimedia_packages() {
  print_header "INSTALLING PACKAGES - MULTIMEDIA"
  install_package "vlc vlc-plugins-all" # Video player
  install_package eog                   # Image viewer
  install_package nautilus              # File explorer
  install_package spotify               # Music streaming
  install_package obs-studio            # Screen recording
}

install_control_packages() {
  print_header "INSTALLING PACKAGES - CONTROLS"
  install_package better-control-git      # Bluetooth and WIFI control
  install_package "pavucontrol playerctl" # Audio control
  install_package brightnessctl           # Brightness control
}

install_font_packages() {
  print_header "INSTALLING PACKAGES - FONTS"
  install_package "noto-fonts noto-fonts-cjk noto-fonts-emoji"
  install_package ttf-jetbrains-mono-nerd
}

install_terminal_packages() {
  print_header "INSTALLING PACKAGES - TERMINAL"
  install_package kitty     # Terminal emulator
  install_package btop      # System monitor
  install_package fastfetch # System info fetcher
  install_package eza       # Enhanced ls command
  install_package zsh       # Zsh shell
}

install_utility_packages() {
  print_header "INSTALLING PACKAGES - UTILITIES"
  install_package steam                                # Gaming platform
  install_package proton-vpn-gtk-app                   # Proton VPN
  install_package vicinae-bin                          # App launcher
  install_package 1password                            # Password manager
  install_package "zen-browser-bin helium-browser-bin" # Browsers
  install_package obsidian                             # Note-taking
  install_package libreoffice-fresh                    # Office suite
  install_package gnome-calculator                     # Calculator
  install_package localsend-bin
}

install_devtools_packages() {
  print_header "INSTALLING PACKAGES - DEVTOOLS"
  install_package opencode-bin
  install_package unzip
  install_package dbeaver
  install_package just
  install_package tenv-bin        # Terraform version manager
  install_package fzf             # Fuzzy finder
  install_package neovim          # Text editor
  install_package ripgrep         # Search tool
  install_package imagemagick     # Image manipulation
  install_package "nvm yarn pnpm" # Node version manager
  install_package uv              # Python package manager
  install_package aws-cli-v2      # AWS CLI
  install_package sops            # Secrets management
  install_package rust            # Rust programming language
  install_docker
}

install_rnvim() {
  print_header "Installing Rnvim"
  if [ -d "$HOME/.config/nvim" ]; then
    print_substep "rnvim already installed, pulling latest changes..."
    git -C "$HOME/.config/nvim" pull
  else
    git clone https://github.com/MrRoiz/rnvim.git "$HOME/.config/nvim"
    print_substep "rnvim installed!"
  fi
}

install_all_packages() {
  install_compositor_packages
  install_hyprland_essentials
  install_system_packages
  install_multimedia_packages
  install_control_packages
  install_font_packages
  install_terminal_packages
  install_utility_packages
  install_devtools_packages
  install_rnvim
}
