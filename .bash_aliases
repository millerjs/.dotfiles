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

alias ew='emacs -nw'
alias ewb='emacs -nw ~/.bashrc && source ~/.bashrc'
alias sl='ls'

alias nd="pushd +1"
alias push="pushd"
alias pop="popd"

alias tn='tmux new -s'
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias lt='tmux list-sessions'