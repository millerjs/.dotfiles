#!/usr/bin/env/ python


def temax_name(args, stdin=None):
    """Get name of emacs daemon for tmux session"""

    name = !(tmux display-message -p "#S")
    if not name.err:
        return '{}-{}'.format($(whoami).strip(), name.out.strip())


def temax_connect(args, stdin=None):
    print(args)
    name = temax_name(args, stdin)
    res = ![emacsclient --server-file @(name) -nw @(args)]


# emacs_new_tmux_emacs_daemon() {
#     name=$(get_emacs_daemon_name)
#     if [[ "${name}" != "" ]]; then
#         name="$(whoami)-$(tmux display-message -p '#S')"
#         if emacsclient --server-file="${name}" -nw $@;
#         then :; else
#             echo -e 'No server associated with tmux session, starting now...\n'
#             emacs --daemon="${name}"
#         fi
#     else
#         echo -e 'Not in tmux.\n'
#     fi
# }
