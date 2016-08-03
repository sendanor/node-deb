#!/bin/sh
# Build node.js
#

self="$(readlink -e "$0")"
dir="$(dirname "$self")"

set -e

pkgname=nodejs
prefix=/usr
version="$1"
test -n "$2" && prefix="$2"
test -n "$3" && pkgname="$3"

if test x"$version" = x; then
	echo "USAGE: build.sh VERSION [PREFIX [PKGNAME]]" >&2
	exit 1
fi

file="node-v""$version"".tar.gz"

url="http://nodejs.org/dist/v""$version""/$file"

# Check env

machine="$(uname -m)"
distribution="Unknown ($machine)"
if test -f /etc/lsb-release; then
	. /etc/lsb-release
	distribution="$DISTRIB_DESCRIPTION ($machine)"
else
	if test -f /etc/debian_version; then

		# test for Rasbian
		if test x"$(dpkg --print-architecture)" = xarmhf; then
			distribution="Raspbian $(cat /etc/debian_version) ($machine)"

		# Generic Debian
		else
			distribution="Debian $(cat /etc/debian_version) ($machine)"
		fi
	else
		distribution="$(uname -a) ($machine)"
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
	if wget -4 "$url" -O "$file"; then
		:
	else
		echo "Failed to get source: $url" >&2
		exit 1
	fi
fi
echo "Done."

# Check sums
echo -n "### Checking SHASUMS... "
remote_shasum="$(cat ../distfiles/SHASUMS|grep -F "$file"|awk '{print $1}')"
if test "x$(echo -n "$remote_shasum"|wc -m)" = x40; then
	local_shasum="$(shasum -b ../distfiles/"$file"|awk '{print $1}')"
else
	local_shasum="$(sha256sum -b ../distfiles/"$file"|awk '{print $1}')"
fi
if test "x$remote_shasum" = "x$local_shasum"; then
	:
else
	echo "Failed!"
	exit 1
fi
echo "Done."

# Unpacking
echo -n "### Unpacking... "
cd "$dir/build"

if test -d ./"$pkgname"-"$version"; then
	echo "Directory exists already: build/""$pkgname""-""$version" >&2
	exit 1
fi

tar -zxf ../distfiles/"$file"
mv "node-v""$version" "$pkgname"-"$version"

if test -d ./"$pkgname"-"$version"/debian; then
	echo "Directory exists already: build/""$pkgname""-""$version""/debian" >&2
	exit 1
fi

cp -afr ../nodejs/debian "$pkgname"-"$version"/debian

# Fix prefix
(
	cd "$pkgname"-"$version"/debian

	for file in README.Debian changelog rules; do
		sed -i "s@nodejs@$pkgname@g" "$file"
	done

	sed -i "s@Package: nodejs@Package: $pkgname@g" control
	sed -i "s@Source: nodejs@Source: $pkgname@g" control

	sed -i "s@\-\-prefix=/usr@--prefix=$prefix@g" rules
)

cd "$pkgname"-"$version"

debchange -v "$version-1" "New build for $distribution"
echo "Done."

echo -n "### Building... "
dpkg-buildpackage -rfakeroot
echo "Done."

echo -n "### Finishing... "
cp -f debian/changelog ../../nodejs/debian/changelog
git commit -a -m "New build for $distribution"
cd $dir
rm -rf build/"$pkgname"-"$version/"
echo "Done."

# EOF
