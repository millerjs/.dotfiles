#Fix PATH
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/local/bin/

export CLICOLOR=1
export PATH
export SVN_EDITOR="emacs -nw"

if dpkg -l ubuntu-desktop 2>/dev/null >/dev/null; then
    _UBUNTU_DESKTOP=true
fi

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

# Terminal OK symbols
STAR1='※'

# Format status message for bash PS1
header()
{
    if [ "$2" = "" ]; then
        echo "${PURPLE}[${GREEN}$1${PURPLE}]"
    else
        echo "${PURPLE}[$1${GREEN}$2${PURPLE}]"
    fi
}

# Get git status for PS1 header
try_get_git()
{

    none=""
    if [ $(which git 1>/dev/null 2>/dev/null; echo $?) -ne '0' ]; then
        echo ${none}
        return
    fi
    if [ $(git branch 1>/dev/null 2>/dev/null; echo $?) -ne '0' ]; then
        echo ${none}
        return
    fi
    repo=$(git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//')
    branch=$(git branch 2>/dev/null | grep '*' | sed s/'* '//g)
    status=$(git  2>/dev/null | grep '*' | sed s/'* '//g)

    GIT_SYMBOL='g:'
    BRED="${BOLD}${RED}"
    if ! git diff-files --quiet --ignore-submodules --; then
        if ! git diff origin/${branch}..HEAD --quiet --ignore-submodules >/dev/null 2>/dev/null; then
            # uncommited, unpushed changes
            echo "${PURPLE}[${GIT_SYMBOL}${BRED}${repo}/${branch}${OFF}${PURPLE}]"
        else
            # uncommited changes
            echo "${PURPLE}[${GIT_SYMBOL}${GREEN}${repo}${BRED}/${branch}${OFF}${PURPLE}]"
        fi
    else
        if ! git diff origin/${branch}..HEAD --quiet --ignore-submodules >/dev/null 2>/dev/null; then
            # nothing to commit, unpushed commits
            echo "${PURPLE}[${GIT_SYMBOL}${BRED}${repo}/${OFF}${GREEN}${branch}${OFF}${PURPLE}]"
        else
            # clean
            echo "${PURPLE}[${GIT_SYMBOL}${GREEN}${repo}${OFF}${GREEN}/${branch}${OFF}${PURPLE}]"
        fi
    fi
}

# Format the return code for PS1
return_code="""
if [ \$? = 0 ]; then echo '';
else echo $(header ${RED}err: \$?); fi"""

# Format the current directory for PS1
current_dir()
{
    CWD="$(pwd -L)"
    hdr=$(echo -e "${HDR}[${CWD}]")
    if [ ${#hdr} -gt $(expr ${COLUMNS} + 150) ];
    then
        echo ""
    fi
    echo "$(header ${CWD})"
}

# Format the hostname directory for PS1
get_hostname()
{
    if ! which scutil >/dev/null 2>/dev/null; then
        echo $(hostname -s)
    else
        echo $(scutil --get ComputerName)
    fi
}

# Format any venv name directory for PS1
try_virtual_env()
{
    if [ "$VIRTUAL_ENV" != "" ]
    then
        echo "${PURPLE}[v:${GREEN}${VIRTUAL_ENV##*/}${PURPLE}]"
    else
        echo ""
    fi
}

try_get_user()
{
    echo '\u'
}

prompt_cmd() {
    PS1=""
    HDR="\n\n"
    HDR="${HDR}"
    HDR="${HDR}\$(${return_code})"
    HDR="${HDR}$(try_virtual_env)"
    HDR="${HDR}$(try_get_git)"
    HDR="${HDR}$(current_dir)"
    HDR="${HDR}\n"

    PS1="${PS1}${HDR}"
    PS1="${PS1}${OFF}${GREEN}$(try_get_user)"
    PS1="${PS1}${OFF}${BOLD}${GREEN}@$(get_hostname)"
    PS1="${PS1}${BOLD}${BLUE}(\\W)"
    PS1="${PS1}${GREEN}$ ${OFF}"

    # Add timestamp?
    # tput sc
    # tput cup $(($(get_cursor_row)+2)) $(($(tput cols)-29))
    # echo -e "$(date)"
    # tput rc
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
    . ${HOME}/.bash_aliases
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_functions ]; then
    source ${HOME}/.bash_functions
fi

################################################################################
# Source local bash run commands
################################################################################
if [ -f ${HOME}/.local_bashrc ]; then
    source ${HOME}/.local_bashrc
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

shopt -s cdspell
set cd options

################################################################################
# Virtual environment
################################################################################
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    export WORKON_HOME=~/.venvs
    source /usr/local/bin/virtualenvwrapper.sh
    alias workoff='deactivate'
    # workon user's default venv
    uv
fi

################################################################################
# Environment settings
################################################################################

export HISTIGNORE="&:ls:ls:cd"
export PYTHONIOENCODING=utf-8
export TERM=xterm-256color
export EDITOR=emacs
if [ -f ${HOME}/.local_bashrc ]; then
    source "${HOME}/.local_bashrc"
fi


# Golang
export GOPATH=${HOME}/gocode


# Git settings
export GIT_EDITOR="emacs -nw -q"
export EDITOR="emacs -nw -q"

if [ -f ${HOME}/.dotfiles/scripts/git-completion.bash ]; then
    source "${HOME}/.dotfiles/scripts/git-completion.bash"
fi
