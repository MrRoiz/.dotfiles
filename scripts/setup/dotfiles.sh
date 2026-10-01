#!/usr/bin/env bash

# =============================================================================
# Dotfiles Setup Functions
# =============================================================================
# Functions for dotfiles management, stow, zsh, and oh-my-zsh setup
# =============================================================================

check_or_clone_dotfiles() {
  print_step "Checking/Cloning dotfiles repository"
  if [ -d "$DOTFILES_DIR" ]; then
    print_substep "dotfiles repo already exists"
  else
    print_substep "Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
}

stow_dotfiles() {
  print_step "Stowing dotfiles"
  print_substep "Installing stow..."
  install_package stow
  print_substep "Applying dotfiles with stow..."
  cd "$DOTFILES_DIR/config"
  stow --restow -t "$HOME" *
  cd "$HOME"
}

setup_zshrc() {
  print_step "Setting up .zshrc"
  local zshrc="$HOME/.zshrc"

  if ! [ -e $zshrc ]; then
    print_substep ".zshrc does not exist, creating a new one..."
    cp "$DOTFILES_DIR/config-templates/zsh/.zshrc" $HOME
  else
    print_substep ".zshrc already present"
  fi
}

install_ohmyzsh() {
  print_step "Installing Oh My Zsh"
  if [ -d "$HOME/.oh-my-zsh" ]; then
    print_substep "Oh My Zsh is already installed"
    return
  fi

  print_substep "Installing Oh My Zsh framework..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  print_substep "Installing zsh-syntax-highlighting plugin..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

  print_substep "Installing zsh-autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

  print_substep "Installing zsh-history-substring-search plugin..."
  git clone https://github.com/zsh-users/zsh-history-substring-search \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search"

  print_substep "Installing you-should-use plugin..."
  git clone https://github.com/MichaelAquilina/zsh-you-should-use.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/you-should-use"

  print_substep "Installing powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
}

setup_wallpaper() {
  print_step "Setting up wallpaper"
  sudo bash "$DOTFILES_DIR/scripts/change-wallpaper.sh"
}

setup_swaync_profile_css() {
  print_step "Setting up swaync profile highlight"
  local dest="$HOME/.config/swaync/profile-active.css"

  if [ -e "$dest" ]; then
    print_substep "profile-active.css already present"
    return
  fi

  local profile="balanced"
  command -v powerprofilesctl >/dev/null 2>&1 && \
    profile="$(powerprofilesctl get 2>/dev/null || echo balanced)"

  local idx=2
  case "$profile" in
    power-saver) idx=1 ;;
    performance) idx=3 ;;
  esac

  print_substep "Generating profile-active.css for '$profile'"
  sed "s/@PROFILE_INDEX@/$idx/" \
    "$DOTFILES_DIR/config-templates/swaync/profile-active.css.tmpl" > "$dest"
}

enable_battery_warning() {
  print_step "Enabling battery low warning"
  systemctl --user daemon-reload 2>/dev/null || true

  if systemctl --user enable --now battery-warning.timer 2>/dev/null; then
    print_substep "battery-warning.timer enabled"
  else
    print_substep "Could not enable now (no user session?). Run later:"
    print_substep "systemctl --user enable --now battery-warning.timer"
  fi
}
