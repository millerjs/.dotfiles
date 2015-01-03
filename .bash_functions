#!/bin/bash

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



# print_image filename inline base64contents
#   filename: Filename to convey to client
function print_image() {
    printf "\ePtmux;\e\e]1337;File=inline=1;$2:$1\a\e\\"
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
