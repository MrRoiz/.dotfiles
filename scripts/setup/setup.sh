#!/usr/bin/env bash

# =============================================================================
# Arch Linux Setup Script
# =============================================================================
# This script automates the setup of a new Arch Linux installation.
# It installs the yay AUR helper, essential packages, and applies dotfiles.
#
# Usage:
#   Direct:  ./setup.sh
#   Via curl: curl -s https://raw.githubusercontent.com/MrRoiz/.dotfiles/main/install.sh > /tmp/install.sh && bash /tmp/install.sh
# =============================================================================

set -e

# Constants
DOTFILES_REPO="https://github.com/MrRoiz/.dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
SCRIPT_DIR="$DOTFILES_DIR/scripts"

# Source all setup modules
source "$SCRIPT_DIR/setup/utils.sh"
source "$SCRIPT_DIR/setup/system.sh"
source "$SCRIPT_DIR/setup/packages.sh"
source "$SCRIPT_DIR/setup/dotfiles.sh"

# =============================================================================
# Main Script Execution
# =============================================================================

print_header "ARCH LINUX SETUP SCRIPT"

# -- System Preparation --
print_header "SYSTEM PREPARATION"
check_or_install_yay
enable_multilib

# -- Install Packages --
install_all_packages
add_1password_trusted_browsers

# -- Configuration --
print_header "CONFIGURATION"
setup_git
check_or_clone_dotfiles
stow_dotfiles
setup_zshrc
setup_wallpaper
install_ohmyzsh

print_header "SETUP COMPLETE!"
