ZSH_PATH="$DOTFILES_PATH/zsh"

# Node, Python, terraform and terragrunt are mise-managed (Omarchy preinstalls
# mise and its shims are on PATH from the shell bootstrap), so no nvm block or
# version-manager activation is needed here.

source "$ZSH_PATH/aliases.sh"
source "$ZSH_PATH/functions.sh"
