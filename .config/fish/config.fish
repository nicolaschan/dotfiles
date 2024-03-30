if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
#eval /home/nicolas/anaconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

zoxide init --cmd cd fish | source
#alias cd=z
alias ls=lsd
#alias cat=ccat
#alias ping="prettyping --nolegend"
fzf_key_bindings
