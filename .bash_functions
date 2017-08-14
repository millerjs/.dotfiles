#!/bin/bash

function pids() {
    ps aux | grep $@ | grep -v 'grep ' | tr -s ' ' | cut -f2 -d' '
}

function blank() {
    # just keep the screen blank
    while :;
    do
        clear
        read
    done
}

function git_url() {
    git config --get remote.origin.url | sed -e 's|git@github.com:|https://github.com/|g'
}

function open_git_commit_url() {
    url=$(git_url)
    open "${url%.git}/commit/$1"
}

function proceed_or_abort() {
    read -p "$1 [y/N] " choice
    case "$choice" in
        y|Y ) true;;
        n|N|* ) echo "Aborted."; exit 1;;
    esac
}

function bat() {
    pmset -g batt | grep -Eo '\d+\%'
}

function tmux_zoom_in() {
    tmux new-window -d -n tmux-zoom 'clear && echo TMUX ZOOM && read' &&\
        tmux swap-pane -s tmux-zoom.0 &&\
        tmux select-window -t tmux-zoom &&\
        tmux display 'ZOOMED IN'
}

function tmux_zoom_out() {
    tmux last-window &&\
        tmux swap-pane -s tmux-zoom.0 &&\
        tmux kill-window -t tmux-zoom &&\
        tmux display 'ZOOMED OUT'
}

pubkey() {
    if [ -z "$1" ]; then
        echo "usage: $FUNCNAME username"
        return
    fi
    python -c """
import sys, json, requests
r = requests.get(\"https://api.github.com/users/$1/keys\")
for result in r.json():
    print(result['key'])
"""
}

recording_ps1() {
    export PS1="bash: [\W] \\$ \[$(tput sgr0)\]"
}

# ======================================================================
# Tmux + Emacs integration

emacsclient_to_daemon() {
    emacsclient --server-file="$1" -nw "${@:2}"
}

get_emacs_daemon_name() {
    if [[ -n "${TMUX+set}" ]] && tmux display-message -p "#S" > /dev/null; then
        tmux display-message -p '#S'
    fi
}

emacsclient_to_tmux_emacs_daemon() {
    name=$(get_emacs_daemon_name)

    if [[ "${name}" != "" ]]; then

        # first try
        if emacsclient_to_daemon $name $@; then :; else

            # failed first try, start server
            echo -e 'No server associated with tmux session, starting now...\n'
            emacs --daemon=$name

            # second try or launch normally
            if emacsclient_to_daemon $name $@; then :; else emacs -nw $@; fi

        fi
    else
        emacs -nw $@
    fi
}

kill_this_emacs_daemon (){
    name=$(get_emacs_daemon_name)
    pid=$(ps aux | grep "$name" | grep daemon | tr -s ' ' | cut -f2 -d' ')
    echo "killing $name ($pid)"
    kill "${pid}"
}

# ======================================================================
# Cursor functions

get_cursor_pos() {
    exec < /dev/tty
    oldstty=$(stty -g)
    stty raw -echo min 0
    echo -en "\033[6n" > /dev/tty
    IFS=';' read -r -d R -a pos
    stty $oldstty
    echo $pos
}

get_cursor_row() {
    pos=$(get_cursor_pos)
    echo $((${pos[0]:2} - 1))
}

get_cursor_col() {
    pos=$(get_cursor_pos)
    echo $((${pos[1]} - 1))
}

as() {
    sudo su $1 -c """$(printf '"%s" ' "${@:2}")"""
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


# Stolen from rkirti, kirtibr@gmail.com
extract()
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2 ) tar xjf $@;;
            *.tar.gz  ) tar xzf $@;;
            *.bz2     ) bunzip2 $@;;
            *.rar     ) rar x $@;;
            *.gz      ) gunzip $@;;
            *.tar     ) tar xf $@;;
            *.tbz2    ) tar xjf $@;;
            *.tgz     ) tar xzf $@;;
            *.zip     ) unzip $@;;
            *.Z       ) uncompress $@p;;
            *         ) echo "$1 cannot be extracted via extract()";;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find a running process
psaux()
{
    ps aux | grep $@ | grep -v grep
}

# Why not?
flip_table()
{
    echo -e "\n(╯°□°）╯︵ ┻━┻ "
}

pingg ()
{
    # Ping google's server
    ping 8.8.8.8
}

download () {
    for fn in "$@"
    do
        if [ -r "$fn" ] ; then
            printf '\033]1337;File=name='`echo -n "$fn" | base64`";"
            wc -c "$fn" | awk '{printf "size=%d",$1}'
            printf ":"
            base64 < "$fn"
            printf '\a'
        else
            echo File $fn does not exist or is not readable.
        fi
    done
}

# print_image filename inline base64contents
#   filename: Filename to convey to client
function print_image() {
    printf "\e]1337;File=inline=1;$2:$1\a\e\\"
}

imcat () {
    if [ ! -t 0 ]; then
        print_image "$(cat | base64)"
        exit 0
    fi

    if [ $# -eq 0 ]; then
        echo "Usage: imgcat filename ..."
        echo "   or: cat filename | imgcat"
        return
    fi

    for fn in "$@"; do
        if [ -r "$fn" ] ; then
            print_image "$(base64 "$fn")"
        else
            echo "imcat: $fn: No such file or directory"
            return
        fi
    done
}


up () {
    if [ "$#" == 0 ]; then
        cd ../
        return
    fi
    for i in `seq 1 $1`; do
        cd ../
    done
}
