#Fix PATH
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:~/.scripts:/opt/local/bin/:/usr/texbin:/usr/local/go/bin:/usr/local/Cellar/

export CLICOLOR=1

export PATH
export SVN_EDITOR="emacs -nw"

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=2000000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

export PROMPT_DIRTRIM=3

EXITSTATUS="$?"
BOLD="\[\033[1m\]"
RED="\[\033[1;31m\]"
GREEN="\[\033[32m\]"
BLUE="\[\e[34;1m\]"
OFF="\[\033[m\]"

BLACK="\[\033[30m\]"
BLUE="\[\033[34m\]"
GREEN="\[\033[32m\]"
CYAN="\[\033[36m\]"
RED="\[\033[31m\]"
PURPLE="\[\033[35m\]"
BROWN="\[\033[33m\]"
YELLOW="\[\033[33m\]"
WHITE="\[\033[37m\]"

BORDER="${OFF}${GREEN}"
TOP="⎾"
MID="⎟"
BOT="⎿"


function try_get_git(){
    none=""
    if [ $(which git 1>/dev/null 2>/dev/null; echo $?) -ne '0' ]; then
        echo ${none}
        return
    fi
    if [ $(git branch 1>/dev/null 2>/dev/null; echo $?) -ne '0' ]; then
        echo ${none}
        return
    fi

    branch=$(git branch 2>/dev/null | grep '*' | sed s/'* '//g)
    status=$(git  2>/dev/null | grep '*' | sed s/'* '//g)

    if ! git diff-files --quiet --ignore-submodules --; then
        echo "${PURPLE}[br:${BOLD}${RED}${branch}${OFF}${PURPLE}] "
    else
        echo "${PURPLE}[br:${GREEN}${branch}${OFF}${PURPLE}] "
    fi
}

function file_count(){
    ls | wc -l | tr -d ' '
}

function return_code(){
    echo "\$?"
}

function current_dir(){
    echo "\\w/"
}

function tmux_name(){
    tmux display-message -p "#S"
}

function header() {
    echo "${PURPLE}[$1:${GREEN}$2${PURPLE}] "
}

function prompt_cmd(){
    PS1=""
    HDR="\n"
    HDR="${HDR}"
    HDR="${HDR}$(header rc $(return_code))"
    HDR="${HDR}$(try_get_git)"
    HDR="${HDR}$(header cd $(current_dir))"
    HDR="${HDR}\n"

    PS1="${PS1}${HDR}${line:${#HDR}}"
    PS1="${PS1}${OFF}${GREEN}\u${BOLD}${GREEN}@\h"
    PS1="${PS1}${BOLD}${BLUE} \\W"
    PS1="${PS1}› ${OFF}"
}

PROMPT_COMMAND=prompt_cmd

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export HISTIGNORE="&:ls:ls:cd"
export PYTHONIOENCODING=utf-8
export TERM=xterm-256color
shopt -s cdspell
set cd options
