#!/bin/sh
self="$(readlink -e "$0")"
dir="$(dirname "$self")"

set -e

version="$1"

if test x"$version" = x; then
	echo "USAGE: build.sh VERSION" >&2
	exit 1
fi

file="node-v""$version"".tar.gz"

url="http://nodejs.org/dist/v""$version""/$file"

# Check env

distribution="Unknown"
if test -f /etc/lsb-release; then
	. /etc/lsb-release
	distribution="$DISTRIB_DESCRIPTION"
else
	if test -f /etc/debian_version; then
		distribution="Debian $(cat /etc/debian_version)"
	else
		distribution="$(uname -a)"
	fi
fi

# Create directories
echo -n "### Creating directories... "
cd "$dir"
mkdir -p ./distfiles ./build
echo "Done."

# Get source code
echo -n "### Fetching source... "
cd "$dir/distfiles"
if test -f "$file"; then
	:
else
	if wget "$url" -O "$file"; then
		:
	else
		echo "Failed to get source: $url" >&2
		exit 1
	fi
fi
echo "Done."

# Unpacking
echo -n "### Unpacking... "
cd "$dir/build"

if test -d ./nodejs-"$version"; then
	echo "Directory exists already: build/nodejs-""$version" >&2
	exit 1
fi

tar -zxf ../distfiles/"$file"
mv "node-v""$version" nodejs-"$version"

if test -d ./nodejs-"$version"/debian; then
	echo "Directory exists already: build/nodejs-""$version""/debian" >&2
	exit 1
fi

cp -afr ../nodejs/debian nodejs-"$version"/debian

cd nodejs-"$version"
debchange -v "$version-1" "New build for $distribution"
echo "Done."

echo -n "### Building... "
dpkg-buildpackage -rfakeroot
echo "Done."

echo -n "### Finishing... "
cp -f debian/changelog ../../nodejs/debian/changelog
git commit -a -m "New build for $distribution"
echo "Done."

# EOF
