#!/bin/bash

function pids() {
    ps aux | grep $@ | grep -v 'grep ' | tr -s ' ' | cut -f2 -d' '
}

function ssl_expiry() {
    for host in $@; do
        printf "${host}\n\t\t\t\t"
        echo | openssl s_client -servername "$host" -connect "${host}:443" 2>/dev/null | openssl x509 -noout -dates | rg notAfter
    done
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

function proceed_yes_no() {
    read -p "$1 [y/N] " choice
    case "$choice" in
        y|Y )   true;;
        n|N|* ) false;;
    esac
}

function proceed_or_abort() {
    proceed_yes_no $@ || echo "Aborted." && exit 1
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


k8s_git_log () {
    deployment=$1
    repo=$(git remote -v 2>/dev/null| head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//')
    sha=$(kubectl get deployment $repo -o=jsonpath='{$.spec.template.spec.containers[:1].image}' | cut -d':' -f2)
    git log $sha
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

function refactor() {
    original=$1
    replacement=$2

    rg "$1" "${@:3}"|| return
    echo -en "\n\n${BIGreen}Replace these occurances with ${BIBlue}${replacement}?${CReset}"
    proceed_yes_no && rg -l "$1" "${@:3}" | xargs perl -pi -e "s/${original}/${replacement}/g"
}

function gist() {
    if [ $# -ne 0 ]; then
        pbcopy < $1
    fi
    open 'https://gist.github.com/'
}


function lsp-java() {
  PROJECT="${1}"
  cd ~/src/eclipse.jdt.ls/
java -Declipse.application=org.eclipse.jdt.ls.core.id1 \
     -Dosgi.bundles.defaultStartLevel=4 \
     -Declipse.product=org.eclipse.jdt.ls.core.product \
     -Dlog.protocol=true \
     -Dlog.level=ALL \
     -noverify \
     -Xmx1G \
     -jar $HOME/plugins/org.eclipse.equinox.launcher_1.5.0.v20180119-0753.jar \
     -configuration $HOME/config_mac \
     --add-modules=ALL-SYSTEM \
     --add-opens java.base/java.util=ALL-UNNAMED \
     --add-opens java.base/java.lang=ALL-UNNAMED
}
