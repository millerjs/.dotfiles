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

# bash aliases
alias pa='ps aux | grep -v grep | grep -i'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lah='ls -lah'
alias sl='ls'

# tmux
alias tn='tmux new -s'
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias lt='tmux list-sessions'

# emacs
alias e='emacsclient_to_tmux_emacs_daemon'
alias ew='emacsclient_to_tmux_emacs_daemon'
alias ed='emacsclient -nw --server-file'
alias ewm='ed main'
alias rew='kill_this_emacs_daemon; emacsclient_to_tmux_emacs_daemon'
alias kted='kill_this_emacs_daemon'

# git
alias gam='f() { git commit -am "$*"; }; f'
alias gd='git diff'
alias gs='git status'
alias gb='git branch'
alias gl='git l'

# navigation
alias p='pushcd'
alias pd='popd > /dev/null'
alias r='pushd +1'
alias dirs='dirs -v'
alias u='up'

# python
alias mkv='mkvirtualenv'
alias wo='workon'

# ruby/rails
alias be='bundle exec'
alias ber='bundle exec rails'

# Clipboard
if uname -arv | grep Linux >/dev/null; then
    # Other Linux
    alias c='xclip -selection clipboard -i'

elif uname -arv | grep Ubuntu >/dev/null; then
    # Ubuntu
    alias c='xclip'

elif uname -arv | grep -i darwin >/dev/null; then
    # OSX
    alias c='pbcopy'
fi


alias x='xonsh --shell-type=prompt_toolkit'
