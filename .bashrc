#Fix PATH
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/local/bin/


if [ -f ${HOME}/.local_bashrc ]; then
    source "${HOME}/.local_bashrc"
fi


export CLICOLOR=1
export PATH

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
HISTSIZE=1000000
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

GIT_SYMBOL='⥴ '
ERROR_SYMBOL='✗'
VENV_SYMBOL='∈'
TIMER_SYMBOL=''
CWD_SYMBOL='∈ '
K8S_SYMBOL='⊕ '

# Format status message for bash PS1
header()
{
    if [ "$2" = "" ]; then
        echo "${PURPLE}[${GREEN}$1${PURPLE}]"
    else
        echo "${PURPLE}[$1${GREEN}$2${PURPLE}]"
    fi
}

git_repo() {
    git remote -v 2>/dev/null| head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//'
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
    repo=$(git_repo)
    branch=$(git branch 2>/dev/null | grep '*' | sed s/'* '//g)
    status=$(git  2>/dev/null | grep '*' | sed s/'* '//g)

    BRED="${BOLD}${RED}"
    if ! git diff-files --quiet --ignore-submodules -- 2>/dev/null; then
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


# Format status message for bash PS1
try_k8s_context()
{
    if [ "$KUBE_CONTEXT" != "" ]; then
        echo "${PURPLE}[${K8S_SYMBOL}${GREEN}$KUBE_CONTEXT${PURPLE}]"
    fi
}


# Format the return code for PS1
return_code="""
if [ \$? = 0 ]; then echo '';
else echo $(header ${RED}${ERROR_SYMBOL}\$?); fi"""

# Format the current directory for PS1
current_dir()
{
    CWD="$(pwd -L)"
    hdr=$(echo -e "${HDR}[${CWD}]")
    if [ ${#hdr} -gt $(expr ${COLUMNS} + 150) ];
    then
        echo ""
    fi
    echo "$(header ${CWD_SYMBOL}${CWD})"
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
        echo "${PURPLE}[${VENV_SYMBOL}${GREEN}${VIRTUAL_ENV##*/}${PURPLE}]"
    fi
}

try_get_user()
{
    echo '\u'
}

ps1_timer_start() {
  timer=${timer:-$SECONDS}
}

ps1_timer_stop() {
  ps1_timer_show=$(($SECONDS - $timer))
  unset timer
}

try_get_ps1_timer()
{
    if [ "$ps1_timer_show" != "0" ]; then
        echo "${PURPLE}[${TIMER_SYMBOL}${GREEN}${ps1_timer_show}${PURPLE}]"
    fi
}

trap 'ps1_timer_start' DEBUG

prompt_cmd() {
    ps1_timer_stop
    PS1=""
    HDR="\n\n"
    HDR="${HDR}"
    HDR="${HDR}\$(${return_code})"
    HDR="${HDR}$(try_get_ps1_timer)"
    # HDR="${HDR}$(try_virtual_env)"
    HDR="${HDR}$(try_k8s_context)"
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


recording_prompt() {
    PS1="bash: [\W] $ "
}

PROMPT_COMMAND=prompt_cmd
# PROMPT_COMMAND=recording_prompt

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
if [ -f /usr/bin/virtualenvwrapper.sh ]; then
    export WORKON_HOME=~/.venvs
    source /usr/local/bin/virtualenvwrapper.sh
    source /usr/bin/virtualenvwrapper.sh
    alias workoff='deactivate'
    workon $USER 2>/dev/null
fi

################################################################################
# Environment settings
################################################################################

# EMACS_CLIENT_EDITOR='emacsclient --server-file="$USER-main" -nw $@ || emacs -nw'
export HISTIGNORE="&:ls:ls:cd:g"
export PYTHONIOENCODING=utf-8

export EDITOR='emacsclient --server-file=main -nw || emacs -q -nw'
export SVN_EDITOR="${EMACS_CLIENT_EDITOR}"
export PAGER="less -S"


if [ -f ${HOME}/.local ]; then
    source "${HOME}/.local"
fi


# Golang
export GOPATH=${HOME}/gocode


# Git settings
export GIT_EDITOR="emacs -nw"


if [ -f ${HOME}/.dotfiles/scripts/git-completion.bash ]; then
    source "${HOME}/.dotfiles/scripts/git-completion.bash"
fi

if [ -f ${HOME}/.bash_colors ]; then
    source ${HOME}/.bash_colors
fi

# Source local bash run commands

if [ -f ${HOME}/.local_bashrc ]; then
    source ${HOME}/.local_bashrc
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:/Users/jmiller/.rvm/gems/ruby-2.2.2/bin:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm


export GPG_TTY=$(tty)
export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"

### Added by IBM Cloud CLI
# source /usr/local/Bluemix/bx/bash_autocomplete

### Added by benchprep-kubernetes setup
export PATH=$PATH:/Users/jmiller/bp/kubernetes/scripts
ulimit -n 10000 12000
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export ANSIBLE_NOCOWS=1
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export PATH="/usr/local/opt/icu4c/bin:$PATH"
