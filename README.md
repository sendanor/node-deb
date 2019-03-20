node-deb
========

These are our build rules and scripts to build Node.js packages for Debian/Ubuntu/Raspbian.

Pre-built binaries
------------------

Our packages are published here: https://dev.sendanor.com/pub/nodejs/

Building from the source
------------------------

Install dependencies:

	$ apt-get install devscripts git autotools-dev dh-buildinfo libev-dev libc-ares-dev libssl-dev pkg-config curl

Clone the repository:

	$ git clone https://github.com/sendanor/node-deb.git node-deb

Build new package:

	$ cd ./node-deb
	$ ./build.sh 0.10.15
	$ ls -lha ./build
	total 18M
	drwxrwxr-x  3 jhh jhh 4.0K Aug  8 06:44 .
	drwxr-xr-x  6 jhh jhh 4.0K Aug  8 06:34 ..
	drwxr-xr-x 11 jhh jhh 4.0K Aug  8 06:43 nodejs-0.10.15
	-rw-rw-r--  1 jhh jhh 1.2K Aug  8 06:44 nodejs_0.10.15-1_amd64.changes
	-rw-r--r--  1 jhh jhh 4.7M Aug  8 06:44 nodejs_0.10.15-1_amd64.deb
	-rw-rw-r--  1 jhh jhh  680 Aug  8 06:34 nodejs_0.10.15-1.dsc
	-rw-rw-r--  1 jhh jhh  14M Aug  8 06:34 nodejs_0.10.15-1.tar.gz

Build 0.11.13 version with different prefix and package name:

	$ ./build.sh 0.11.13 /opt/nodejs/0.11.13 nodejs-0.11.13

***Note!*** If you are building for an older Ubuntu LTS, or another Debian-based OS, make sure to change the branch first, or create a new one first. Eg. `ubuntu1604` for Ubuntu 16.04 LTS.

Updating the SHASUM for a newer NodeJS release
----------------------------------------------

Then you’ll fetch the SHA SUM on the newest release from blog post at https://nodejs.org/en/blog/. 

For example as of now newest LTS blog post is https://nodejs.org/en/blog/release/v10.15.3/, and there you’ll notice a row like: 

    db460a63d057ac015b75bb6a879fcbe2fefaaf22afa4b6f6445b9db61ce2270d  node-v10.15.3.tar.gz 

You need to append this row to `./distfiles/SHASUMS`.
