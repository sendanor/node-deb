#!/bin/sh
# Rsync local distfiles to remote target
# 
self="$(readlink -e "$0")"
dir="$(dirname "$self")"

set -e

host="$1"

if test x"$host" = x; then
	echo "USAGE: rsync-distfiles.sh [USER@]HOSTNAME" >&2
	exit 1
fi

# Rsync

echo -n "### Rsyncing... "
rsync -a "./distfiles/" "$host:git/node-deb/distfiles/"
echo "Done."

# EOF
