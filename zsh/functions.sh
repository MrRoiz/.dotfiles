upgrade() {
  read -q "?Are you sure you want to sync your system? [y/N] " || {
    echo
    return 1
  }
  echo
  bash "$HOME/.dotfiles/install.sh"
}
