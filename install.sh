#!/usr/bin/env bash

# =============================================================================
# Dotfiles Installation Script (Entry Point)
# =============================================================================
# This script is designed to be run via curl:
#   curl -s https://raw.githubusercontent.com/MrRoiz/.dotfiles/main/install.sh > /tmp/install.sh && bash /tmp/install.sh
#
# It clones the dotfiles repository and executes the full setup.
# =============================================================================

set -e

DOTFILES_REPO="https://github.com/MrRoiz/.dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║  DOTFILES INSTALLER"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Ensure git is installed
if ! command -v git &>/dev/null; then
  echo ">>> Installing git..."
  sudo pacman -S --needed git
fi

# Clone or update dotfiles repository
if [ -d "$DOTFILES_DIR" ]; then
  echo ">>> Dotfiles already exist at $DOTFILES_DIR"
  echo "    → Pulling latest changes..."
  git -C "$DOTFILES_DIR" pull
else
  echo ">>> Cloning dotfiles repository..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Execute the main setup script
echo ">>> Running setup script..."
bash "$DOTFILES_DIR/scripts/setup/setup.sh"
