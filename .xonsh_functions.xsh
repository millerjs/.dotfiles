#    -*- mode: python -*-


def ssh_agent_start(args, stdin=None):
    setup = $(ssh-agent)
    $SSH_AUTH_SOCK = setup.split(';')[0].strip().split('=', 1)[1]
    $SSH_AGENT_PID = setup.split(';')[2].strip().split('=', 1)[1]
