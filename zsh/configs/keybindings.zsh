# give us access to ^Q
stty -ixon

# word navigation (matches Windows Terminal behavior)
bindkey "^[[1;5C" forward-word   # Ctrl+Right
bindkey "^[[1;5D" backward-word  # Ctrl+Left

# # vi mode

# # vi mode
# bindkey -v
# bindkey "^F" vi-cmd-mode

# # handy keybindings
# bindkey "^A" beginning-of-line
# bindkey "^E" end-of-line
# bindkey "^K" kill-line
# bindkey "^P" history-search-backward
# bindkey "^Y" accept-and-hold
# bindkey "^N" insert-last-word
# bindkey "^Q" push-line-or-edit
# bindkey -s "^T" "^[Isudo ^[A" # "t" for "toughguy"
