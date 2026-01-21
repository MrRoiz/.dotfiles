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
