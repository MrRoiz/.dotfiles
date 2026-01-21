#!/usr/bin/env bash

# =============================================================================
# System Setup Functions
# =============================================================================
# Functions for system-level configuration (yay, multilib, docker, sddm, git)
# =============================================================================

check_or_install_yay() {
  print_step "Checking/Installing yay AUR helper"
  if command -v yay &>/dev/null; then
    print_substep "yay is already installed"
    print_substep "Upgrading system..."
    yay
    return
  fi

  print_substep "Installing yay from AUR..."
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si
  cd $HOME

  print_substep "Upgrading system..."
  yay
}

enable_multilib() {
  print_step "Enabling multilib repository"
  if grep -q "^\[multilib\]" /etc/pacman.conf; then
    print_substep "multilib is already enabled"
    return
  fi

  print_substep "Uncommenting [multilib] section in pacman.conf..."
  sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
  sudo yay -Sy
}

install_docker() {
  print_step "Installing Docker"
  install_package "docker docker-compose docker-buildx"
  print_substep "Enabling docker service..."
  sudo systemctl enable --now docker
  print_substep "Setting up docker group..."
  getent group docker || sudo groupadd docker
  sudo usermod -aG docker "$USER"
}

setup_sddm() {
  print_step "Setting up SDDM"
  install_package sddm
  print_substep "Enabling SDDM service..."
  sudo systemctl enable sddm

  install_package sddm-silent-theme

  print_substep "Configuring SDDM..."
  local sddm_conf="/etc/sddm.conf"
  local expected_config="[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard

[Theme]
Current=silent"

  if [[ -f "$sddm_conf" ]] && [[ "$(sudo cat "$sddm_conf")" == "$expected_config" ]]; then
    print_substep "SDDM already configured"
  else
    sudo tee "$sddm_conf" >/dev/null <<EOF
$expected_config
EOF
    print_substep "SDDM configuration applied"
  fi
}

setup_theme() {
  print_step "Setting up theme..."
  install_package "gnome-themes-extra gnome-themes-extra-gtk2 adwaita-qt5-git adwaita-qt6-git"
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

add_1password_trusted_browsers() {
  print_step "Add custom trusted browser in 1password"

  sudo mkdir -p /etc/1password

  if ! [ -e /etc/1password/custom_allowed_browsers ]; then
    sudo touch /etc/1password/custom_allowed_browsers
  fi

  echo "zen-bin" | echo "zen-bin" | sudo tee /etc/1password/custom_allowed_browsers

  sudo chown root:root /etc/1password/custom_allowed_browsers
  sudo chmod 755 /etc/1password/custom_allowed_browsers
}
