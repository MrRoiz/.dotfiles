# Readline-style editing keys that the omarchy-zsh defaults leave unbound
# (oh-my-zsh's lib/key-bindings.zsh used to provide them). Terminals disagree on
# the escape bytes and zsh matches them literally, so every common encoding of
# each key is bound below.

# [Home] beginning-of-line — xterm, application-cursor mode, linux/rxvt.
bindkey '^[[H' beginning-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[[1~' beginning-of-line

# [End] end-of-line — the same three encodings.
bindkey '^[[F' end-of-line
bindkey '^[OF' end-of-line
bindkey '^[[4~' end-of-line

# [Ctrl+Left] / [Ctrl+Right] move by word. Herdr forwards the xterm modified
# arrows verbatim, and an unbound sequence leaks into the buffer as ";5D".
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
