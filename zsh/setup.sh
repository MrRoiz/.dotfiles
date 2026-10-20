ZSH_PATH="$HOME/.dotfiles/zsh"

# Node, Python, terraform and terragrunt are mise-managed (Omarchy preinstalls
# mise and its shims are on PATH from the shell bootstrap), so no nvm block or
# version-manager activation is needed here.

# Fish-like dim suggestion of a history entry as you type — what oh-my-zsh's
# zsh-autosuggestions plugin provided. fg=8 is ANSI bright-black, so the hint
# follows the active Omarchy theme instead of a hardcoded colour.
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  ZSH_AUTOSUGGEST_STRATEGY=(history)
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Source every alias file (one per topic: git, docker, tools, …).
for _zsh_alias_file in "$ZSH_PATH"/aliases/*.sh(N); do
  source "$_zsh_alias_file"
done
unset _zsh_alias_file

source "$ZSH_PATH/functions.sh"
