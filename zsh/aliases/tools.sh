alias tf="terraform"
alias tg="terragrunt"

# oh-my-zsh's directories lib (md/rd were always available before Omarchy).
alias md="mkdir -p"
alias rd="rmdir"

# Claude accounts per command, regardless of the agents panel's "Use"/Autoswitch.
# `env` scopes the variables to that one process; the shell never keeps them.
# Main: unset (never empty) CLAUDE_CONFIG_DIR so Claude keeps ~/.claude.json; the
# empty Omarchy pin skips the panel's active account.
alias claude='env -u CLAUDE_CONFIG_DIR OMARCHY_AGENT_CLAUDE_HOME= claude'
# Work: the home `omarchy agent account add` created for the second account.
alias claude-work='env CLAUDE_CONFIG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/agents/accounts/claude/oscar-ruiz" claude'
