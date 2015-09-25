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

alias nd="pushd +1"
alias push="pushd"
alias pop="popd"

# tmux
alias tn='tmux new -s'
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias lt='tmux list-sessions'

# emacs
alias ew='emacs -nw'
alias ewb='emacs -nw ~/.bashrc && source ~/.bashrc'

# git
alias gd='git diff'
alias gs='git status'
alias gb='git branch'
alias gl='git log'
alias gh='git log | head -n1 | cut -d" " -f2 | tee /dev/stderr | tr -d "\n" | c'

# navigation
alias p='pushcd'
alias pd='popd > /dev/null'
alias r='pushd +1'
alias dirs='dirs -v'
alias u='up'

# other
alias x='extract'
alias im='imcat'

# python
alias uv='workon $USER 2>/dev/null'
alias pyl='py -l'
alias mkv='mkvirtualenv'
alias wo='workon'

# gcal
alias today="cal agenda $(date +%R) 11:59pm"
alias q='gcalcli quick'

# Ubuntu
if uname -arv | grep Ubuntu >/dev/null; then
    alias c='xclip'
fi

# OSX
if uname -arv | grep -i darwin >/dev/null; then
    alias c='pbcopy'
fi
