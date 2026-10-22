# Readline-style editing keys that the omarchy-zsh defaults leave unbound
# (oh-my-zsh's lib/key-bindings.zsh used to provide them). Terminals disagree on
# the escape bytes and zsh matches them literally, so every common encoding of
# each key is bound below.

# [Home] beginning-of-line — xterm, application-cursor mode, linux/rxvt.
bindkey '^[[H' beginning-of-line  # [Home], xterm
bindkey '^[OH' beginning-of-line  # [Home], application-cursor mode (terminfo khome)
bindkey '^[[1~' beginning-of-line # [Home], linux console / rxvt

# [End] end-of-line — the same three encodings.
bindkey '^[[F' end-of-line  # [End], xterm
bindkey '^[OF' end-of-line  # [End], application-cursor mode (terminfo kend)
bindkey '^[[4~' end-of-line # [End], linux console / rxvt

# [Ctrl+Left] / [Ctrl+Right] move by word. Herdr forwards the xterm modified
# arrows verbatim, and an unbound sequence leaks into the buffer as ";5D".
bindkey '^[[1;5D' backward-word # [Ctrl+Left], xterm (";5" = Ctrl modifier)
bindkey '^[[1;5C' forward-word  # [Ctrl+Right], xterm
