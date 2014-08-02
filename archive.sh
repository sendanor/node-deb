#!/bin/sh
set -e

basedir="$(dirname "$(readlink -e "$0")")"
cd "$basedir"

test -d tmp || mkdir tmp
test -d build || mkdir build

if find build -maxdepth 0 -empty|grep -q build; then
	echo 'No need to archive anything.' >&2
else
	archive_dir=tmp/build-"$(date '+%Y%m%d-%H%M%S')"
	echo "Archiving build to $archive_dir ..." >&2
	mv build/ "$archive_dir"/
	mkdir build
fi

# EOF
