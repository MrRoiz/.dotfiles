ZSH_PATH="$HOME/.dotfiles/zsh"

# Node, Python, terraform and terragrunt are mise-managed (Omarchy preinstalls
# mise and its shims are on PATH from the shell bootstrap), so no nvm block or
# version-manager activation is needed here.

# Source every alias file (one per topic: git, docker, tools, …).
for _zsh_alias_file in "$ZSH_PATH"/aliases/*.sh(N); do
  source "$_zsh_alias_file"
done
unset _zsh_alias_file

source "$ZSH_PATH/functions.sh"
