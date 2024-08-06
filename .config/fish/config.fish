if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
#eval /home/nicolas/anaconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

starship init fish | source
zoxide init --cmd cd fish | source
alias ls=lsd
fzf_key_bindings
eval (direnv hook fish)

function nix-shell
    command nix-shell --run fish $argv
end

fish_add_path ~/bin

