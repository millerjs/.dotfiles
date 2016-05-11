#!/bin/bash

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lah='ls -lah'
alias sl='ls'

alias d='dash'

# tmux
alias tn='tmux new -s'
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias lt='tmux list-sessions'

# emacs
alias e='emacsclient_to_tmux_emacs_daemon'
alias ew='emacs_new_tmux_emacs_daemon; emacsclient_to_tmux_emacs_daemon'
alias dew='emacs_new_tmux_emacs_daemon'
alias rew='kill_this_emacs_daemon; emacsclient_to_tmux_emacs_daemon'
alias ews='emacsclient_to_daemon'
alias ed='emacs_daemon'
alias ked='kill_emacs_daemon'
alias kted='kill_this_emacs_daemon'
alias led='list_emacs_daemons'
alias ewb='emacsclient -nw ~/.bashrc && source ~/.bashrc'

# git
alias gd='git diff'
alias gs='git status'
alias gb='git branch'
alias gl='git log'

# navigation
alias p='pushcd'
alias pd='popd > /dev/null'
alias r='pushd +1'
alias dirs='dirs -v'
alias u='up'

# other
alias x='xonsh'
alias im='imcat'
alias bat="pmset -g batt | grep -Eo '\d+\%'"
alias to='goto_path_alias'

# python
alias uv='workon $USER 2>/dev/null'
alias pyl='py -l'
alias mkv='mkvirtualenv'
alias wo='workon'

# google
alias today="cal agenda $(date +%R) 11:59pm"
alias q='gcalcli quick'
alias g='google_this'

# Ubuntu
if uname -arv | grep Ubuntu >/dev/null; then
    alias c='xclip'
fi

# OSX
if uname -arv | grep -i darwin >/dev/null; then
    alias c='pbcopy'
fi

alias x='xonsh --shell-type=prompt_toolkit'
