#!/bin/bash

tmux_new_shell() {
    # For copying
    if uname -arv | grep -i darwin >/dev/null; then
        reattach-to-user-namespace -l bash
    else bash
    fi
}

emacsclient_to_daemon() {
    emacsclient --server-file="$1" ${@:2}
}

get_emacs_daemon_name() {
    if [[ -n "${TMUX+set}" ]] && tmux display-message -p "#S" > /dev/null;
    then
        echo "$(whoami)-$(tmux display-message -p '#S')"
    fi
}

emacsclient_to_tmux_emacs_daemon() {
    name=$(get_emacs_daemon_name)
    if [[ "${name}" != "" ]]; then
        name="$(whoami)-$(tmux display-message -p '#S')"
        if emacsclient --server-file="${name}" -nw $@;
        then :; else
            echo -e 'No server associated with tmux session, starting now...\n'
            emacs --daemon="${name}"
            emacsclient --server-file="${name}" -nw $@;
        fi
    else
        emacs -nw
    fi
}

emacs_daemon() {
    emacs --daemon="$1"
}

kill_emacs_daemon (){
    pid=$(ps aux | grep "\-\-daemon=^J4,5^J$1" | tr -s ' ' | cut -f2 -d' ')
    kill "${pid}"
}

list_emacs_daemons (){
    ps aux | grep -i emacs | grep -o "\^J4,5\^J.*" | cut -c 8-
}

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

pass() {
    vault -p $@ | c
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


# Format any venv name directory for PS1
testvenv()
{
    echo "Creating fresh test virtual environment"
    rm -rf "${WORKON_HOME}/test"
    mkv test
    workon test
}


pyplt() {
    OUTPUT="output.png"
    py -c """
import matplotlib
matplotlib.use('Agg');
from matplotlib import pyplot as plt;
""" -C "plt.savefig(\"${OUTPUT}\")" "$@"
    echo "Saved to ${OUTPUT}"
    if which imcat > /dev/null; then
        convert ${OUTPUT} -negate - | imcat
    fi
}

plt() {
    if [ "$#" -eq "0" ]; then
        pyplt -l 'plt.plot(l)'
    else
        pyplt "plt.plot($1)"
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


# ======== Navigation ========

pushcd () {
    if [ "" = "$1" ]; then
        cd
    else
        pushd $1 > /dev/null
    fi
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


# ======== Google Calendar ========
cal () {
    if [ -f ~/.gcalcli_calendars ]; then
        gcalcli $(cat ~/.gcalcli_calendars)
    else
        gcalcli
    fi
}


# Opens a new tab in the current Terminal window and optionally executes a command.
# When invoked via a function named 'newwin', opens a new Terminal *window* instead.
newtab() {

    # If this function was invoked directly by a function named 'newwin', we open a new *window* instead
    # of a new tab in the existing window.
    local funcName=$FUNCNAME
    local targetType='tab'
    local targetDesc='new tab in the active iTerm window'
    local makeTab=1
    case "${FUNCNAME[1]}" in
        newwin)
            makeTab=0
            funcName=${FUNCNAME[1]}
            targetType='window'
            targetDesc='new iTerm window'
            ;;
    esac

    # Command-line help.
    if [[ "$1" == '--help' || "$1" == '-h' ]]; then
        cat <<EOF
Synopsis:
    $funcName [-g|-G] [command [param1 ...]]

Description:
    Opens a $targetDesc and optionally executes a command.

    The new $targetType will run a login shell (i.e., load the user's shell profile) and inherit
    the working folder from this shell (the active Terminal tab).
    IMPORTANT: In scripts, \`$funcName\` *statically* inherits the working folder from the
    *invoking Terminal tab* at the time of script *invocation*, even if you change the
    working folder *inside* the script before invoking \`$funcName\`.

    -g (back*g*round) causes Terminal not to activate, but within Terminal, the new tab/window
      will become the active element.
    -G causes Terminal not to activate *and* the active element within Terminal not to change;
      i.e., the previously active window and tab stay active.

    NOTE: With -g or -G specified, for technical reasons, Terminal will still activate *briefly* when
    you create a new tab (creating a new window is not affected).

    When a command is specified, its first token will become the new ${targetType}'s title.
    Quoted parameters are handled properly.

    To specify multiple commands, use 'eval' followed by a single, *double*-quoted string
    in which the commands are separated by ';' Do NOT use backslash-escaped double quotes inside
    this string; rather, use backslash-escaping as needed.
    Use 'exit' as the last command to automatically close the tab when the command
    terminates; precede it with 'read -s -n 1' to wait for a keystroke first.

    Alternatively, pass a script name or path; prefix with 'exec' to automatically
    close the $targetType when the script terminates.

Examples:
    $funcName ls -l "\$Home/Library/Application Support"
    $funcName eval "ls \\\$HOME/Library/Application\ Support; echo Press a key to exit.; read -s -n 1; exit"
    $funcName /path/to/someScript
    $funcName exec /path/to/someScript
EOF
        return 0
    fi

    # Option-parameters loop.
    inBackground=0
    while (( $# )); do
        case "$1" in
            -g)
                inBackground=1
                ;;
            -G)
                inBackground=2
                ;;
            --) # Explicit end-of-options marker.
                shift   # Move to next param and proceed with data-parameter analysis below.
                break
                ;;
            -*) # An unrecognized switch.
                echo "$FUNCNAME: PARAMETER ERROR: Unrecognized option: '$1'. To force interpretation as non-option, precede with '--'. Use -h or --h for help." 1>&2 && return 2
                ;;
            *)  # 1st argument reached; proceed with argument-parameter analysis below.
                break
                ;;
        esac
        shift
    done

    # All remaining parameters, if any, make up the command to execute in the new tab/window.

    local CMD_PREFIX='tell application "iTerm" to do script'

        # Command for opening a new Terminal window (with a single, new tab).
    local CMD_NEWWIN=$CMD_PREFIX    # Curiously, simply executing 'do script' with no further arguments opens a new *window*.
        # Commands for opening a new tab in the current Terminal window.
        # Sadly, there is no direct way to open a new tab in an existing window, so we must activate iTerm first, then send a keyboard shortcut.
    local CMD_ACTIVATE='tell application "iTerm" to activate'
    local CMD_NEWTAB='tell application "System Events" to keystroke "t" using {command down}'
        # For use with -g: commands for saving and restoring the previous application
    local CMD_SAVE_ACTIVE_APPNAME='tell application "System Events" to set prevAppName to displayed name of first process whose frontmost is true'
    local CMD_REACTIVATE_PREV_APP='activate application prevAppName'
        # For use with -G: commands for saving and restoring the previous state within iTerm
    local CMD_SAVE_ACTIVE_WIN='tell application "iTerm" to set prevWin to front window'
    local CMD_REACTIVATE_PREV_WIN='set frontmost of prevWin to true'
    local CMD_SAVE_ACTIVE_TAB='tell application "iTerm" to set prevTab to (selected tab of front window)'
    local CMD_REACTIVATE_PREV_TAB='tell application "iTerm" to set selected of prevTab to true'

    if (( $# )); then # Command specified; open a new tab or window, then execute command.
            # Use the command's first token as the tab title.
        local tabTitle=$1
        case "$tabTitle" in
            exec|eval) # Use following token instead, if the 1st one is 'eval' or 'exec'.
                tabTitle=$(echo "$2" | awk '{ print $1 }')
                ;;
            cd) # Use last path component of following token instead, if the 1st one is 'cd'
                tabTitle=$(basename "$2")
                ;;
        esac
        local CMD_SETTITLE="tell application \"iTerm\" to set custom title of front window to \"$tabTitle\""
            # The tricky part is to quote the command tokens properly when passing them to AppleScript:
            # Step 1: Quote all parameters (as needed) using printf '%q' - this will perform backslash-escaping.
        local quotedArgs=$(printf '%q ' "$@")
            # Step 2: Escape all backslashes again (by doubling them), because AppleScript expects that.
        local cmd="$CMD_PREFIX \"${quotedArgs//\\/\\\\}\""
            # Open new tab or window, execute command, and assign tab title.
            # '>/dev/null' suppresses AppleScript's output when it creates a new tab.
        if (( makeTab )); then
            if (( inBackground )); then
                # !! Sadly, because we must create a new tab by sending a keystroke to iTerm, we must briefly activate it, then reactivate the previously active application.
                if (( inBackground == 2 )); then # Restore the previously active tab after creating the new one.
                    osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_SAVE_ACTIVE_TAB" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_APP" -e "$CMD_REACTIVATE_PREV_TAB" >/dev/null
                else
                    osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_APP" >/dev/null
                fi
            else
                osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$cmd in front window" -e "$CMD_SETTITLE" >/dev/null
            fi
        else # make *window*
            # Note: $CMD_NEWWIN is not needed, as $cmd implicitly creates a new window.
            if (( inBackground )); then
                # !! Sadly, because we must create a new tab by sending a keystroke to iTerm, we must briefly activate it, then reactivate the previously active application.
                if (( inBackground == 2 )); then # Restore the previously active window after creating the new one.
                    osascript -e "$CMD_SAVE_ACTIVE_WIN" -e "$cmd" -e "$CMD_SETTITLE" -e "$CMD_REACTIVATE_PREV_WIN" >/dev/null
                else
                    osascript -e "$cmd" -e "$CMD_SETTITLE" >/dev/null
                fi
            else
                    # Note: Even though we do not strictly need to activate iTerm first, we do it, as assigning the custom title to the 'front window' would otherwise sometimes target the wrong window.
                osascript -e "$CMD_ACTIVATE" -e "$cmd" -e "$CMD_SETTITLE" >/dev/null
            fi
        fi
    else    # No command specified; simply open a new tab or window.
        if (( makeTab )); then
            if (( inBackground )); then
                # !! Sadly, because we must create a new tab by sending a keystroke to iTerm, we must briefly activate it, then reactivate the previously active application.
                if (( inBackground == 2 )); then # Restore the previously active tab after creating the new one.
                    osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_SAVE_ACTIVE_TAB" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$CMD_REACTIVATE_PREV_APP" -e "$CMD_REACTIVATE_PREV_TAB" >/dev/null
                else
                    osascript -e "$CMD_SAVE_ACTIVE_APPNAME" -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" -e "$CMD_REACTIVATE_PREV_APP" >/dev/null
                fi
            else
                osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWTAB" >/dev/null
            fi
        else # make *window*
            if (( inBackground )); then
                # !! Sadly, because we must create a new tab by sending a keystroke to iTerm, we must briefly activate it, then reactivate the previously active application.
                if (( inBackground == 2 )); then # Restore the previously active window after creating the new one.
                    osascript -e "$CMD_SAVE_ACTIVE_WIN" -e "$CMD_NEWWIN" -e "$CMD_REACTIVATE_PREV_WIN" >/dev/null
                else
                    osascript -e "$CMD_NEWWIN" >/dev/null
                fi
            else
                    # Note: Even though we do not strictly need to activate iTerm first, we do it so as to better visualize what is happening (the new window will appear stacked on top of an existing one).
                osascript -e "$CMD_ACTIVATE" -e "$CMD_NEWWIN" >/dev/null
            fi
        fi
    fi

}

# Opens a new iTerm window and optionally executes a command.
newwin() {
    newtab "$@" # Simply pass through to 'newtab', which will examine the call stack to see how it was invoked.
}
