#!/usr/bin/env bash

# =============================================================================
# Omarchy Dotfiles Installer (Entry Point)
# =============================================================================
# Run via curl on an Omarchy install:
#
#   curl -s https://raw.githubusercontent.com/MrRoiz/.dotfiles/feat/omarchy-setup/install.sh > /tmp/install.sh && bash /tmp/install.sh
#
# Clones the dotfiles repository and runs the Omarchy setup script.
# =============================================================================

set -e

DOTFILES_REPO="https://github.com/MrRoiz/.dotfiles.git"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-feat/omarchy-setup}"
DOTFILES_DIR="$HOME/.dotfiles"

echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║  OMARCHY DOTFILES INSTALLER"
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
  echo "    → Fetching and checking out $DOTFILES_BRANCH..."
  git -C "$DOTFILES_DIR" fetch origin "$DOTFILES_BRANCH"
  git -C "$DOTFILES_DIR" checkout "$DOTFILES_BRANCH"
  git -C "$DOTFILES_DIR" pull --ff-only origin "$DOTFILES_BRANCH"
else
  echo ">>> Cloning dotfiles repository (branch: $DOTFILES_BRANCH)..."
  git clone -b "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Run the Omarchy setup
echo ">>> Running Omarchy setup..."
bash "$DOTFILES_DIR/scripts/omarchy.sh"
