#!/bin/bash
set -euxo pipefail

echo 'Defaults env_keep += "DEBIAN_FRONTEND"' >/etc/sudoers.d/env_keep_apt
chmod 440 /etc/sudoers.d/env_keep_apt
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y


#
# provision apt-cacher-ng.
# see https://www.unix-ag.uni-kl.de/~bloch/acng/
# NB these anwsers were obtained (after installing apt-cacher-ng) with:
#
#   #sudo debconf-show apt-cacher-ng
#   sudo apt-get install debconf-utils
#   # this way you can see the comments:
#   sudo debconf-get-selections
#   # this way you can just see the values needed for debconf-set-selections:
#   sudo debconf-get-selections | grep -E '^apt-cacher-ng-.+\s+' | sort
debconf-set-selections<<"EOF"
apt-cacher-ng apt-cacher-ng/tunnelenable boolean false
EOF
apt-get install -y --no-install-recommends apt-cacher-ng

# disable all mirrors (except ubuntu).
sed -i -E 's,^(Remap-.+),#\1,' /etc/apt-cacher-ng/acng.conf 
sed -i -E 's,^#(Remap-uburep.+),\1,' /etc/apt-cacher-ng/acng.conf

# set the APT mirror that apt-cacher-ng uses.
echo 'http://nl.archive.ubuntu.com/ubuntu/' >/etc/apt-cacher-ng/backends_ubuntu

systemctl restart apt-cacher-ng


#
# provision vim.

apt-get install -y --no-install-recommends vim

cat>~/.vimrc<<"EOF"
syntax on
set background=dark
set esckeys
set ruler
set laststatus=2
set nobackup
EOF


#
# configure the shell.

cat>~/.bash_history<<"EOF"
vim /etc/apt-cacher-ng/acng.conf 
EOF

cat>~/.bashrc<<"EOF"
# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

export EDITOR=vim
export PAGER=less

alias l='ls -lF --color'
alias ll='l -a'
alias h='history 25'
alias j='jobs -l'
EOF

cat>~/.inputrc<<"EOF"
"\e[A": history-search-backward
"\e[B": history-search-forward
"\eOD": backward-word
"\eOC": forward-word
set show-all-if-ambiguous on
set completion-ignore-case on
EOF
