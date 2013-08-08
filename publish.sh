#!/bin/sh
self="$(readlink -e "$0")"
dir="$(dirname "$self")"

set -e

version="$1"
host="$2"

if test x"$version" = x; then
	echo "USAGE: publish.sh VERSION [USER@]HOSTNAME" >&2
	exit 1
fi

if test x"$host" = x; then
	echo "USAGE: publish.sh VERSION [USER@]HOSTNAME" >&2
	exit 1
fi

file="node-v""$version"".tar.gz"
url="http://nodejs.org/dist/v""$version""/$file"

# Check env

machine="$(uname -m)"
distribution="Unknown ($machine)"

# Check for ubuntu
if test -f /etc/lsb-release; then
	. /etc/lsb-release
	distribution="$DISTRIB_DESCRIPTION ($machine)"
	os="$DISTRIB_ID"
	os_version="$DISTRIB_RELEASE"
else
	# Check for debian
	if test -f /etc/debian_version; then
		distribution="Debian $(cat /etc/debian_version) ($machine)"
		os="debian"
		os_version="$(cat /etc/debian_version)"
	# Check for something else
	else
		distribution="$(uname -a) ($machine)"
		os="unknown"
		os_version="unknown"
	fi
fi

# Publish

echo -n "### Publishing... "
install_path=$(echo "dev.sendanor.com/pub/nodejs/$version/$os/$os_version/$machine"|tr 'A-Z' 'a-z')
ssh "$host" mkdir -p "$install_path"
rsync -a "./build/" "$host:$install_path/"
echo "Done."

# EOF
