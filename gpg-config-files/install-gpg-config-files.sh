#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

# gpg2 ssh authenticate
gpgconf --launch gpg-agent >/dev/null 2>&1
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
export GPG_TTY="$(tty)"
echo UPDATESTARTUPTTY | gpg-connect-agent >/dev/null 2>&1
# required for gpgv1
export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket):0:1"

set -e

cd conf

if [[ ! -f gpg.conf ]]; then
    echo
    echo -e "\033[01;31m"' no file: gpg.conf'"\033[00m"
    echo
    exit 1
fi
if [[ ! -f gpg-agent.conf ]]; then
    echo
    echo -e "\033[01;31m"' no file: gpg-agent.conf'"\033[00m"
    echo
    exit 1
fi

gpgconf --kill gpg-agent >/dev/null 2>&1 || : 
sleep 1
# default ~/.gnupg 700 (drwx------)
[ -d ~/.gnupg ] || /usr/bin/install -m 0700 -d ~/.gnupg
/bin/rm -f ~/.gnupg/gpg.conf
/bin/rm -f ~/.gnupg/gpg-agent.conf
/usr/bin/install -c -m 0600 gpg.conf ~/.gnupg/
/usr/bin/install -c -m 0600 gpg-agent.conf ~/.gnupg/

# default /etc/skel 755 (drwxr-xr-x)
# default no such dir /etc/skel/.gnupg
/usr/bin/install -m 0755 -d /etc/skel/.gnupg
/usr/bin/install -c -m 0600 gpg.conf /etc/skel/.gnupg/
/usr/bin/install -c -m 0600 gpg-agent.conf /etc/skel/.gnupg/

# gpg2 ssh authenticate
gpgconf --launch gpg-agent >/dev/null 2>&1
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
export GPG_TTY="$(tty)"
echo UPDATESTARTUPTTY | gpg-connect-agent >/dev/null 2>&1
# required for gpgv1
export GPG_AGENT_INFO="$(gpgconf --list-dirs agent-socket):0:1"

ssh-add -L >/dev/null 2>&1 || : 

echo
printf '\e[1;32m%s\e[m\n' '  GPG Configuration Done'
echo
exit

