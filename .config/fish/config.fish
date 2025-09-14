if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting
    fzf --fish | source
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
#eval /home/nicolas/anaconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

function starship_transient_prompt_func
  starship module character
end
starship init fish | source
enable_transience

zoxide init --cmd cd fish | source
alias ls=lsd
eval (direnv hook fish)

function nix-shell
    command nix-shell --run fish $argv
end

fish_add_path ~/bin

set -gx EDITOR nvim
set -gx GPG_TTY (tty)

alias e=$EDITOR

