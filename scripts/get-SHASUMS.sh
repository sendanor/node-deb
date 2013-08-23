#!/bin/sh

fetch_url() {
	page="$1"
	links -dump http://blog.nodejs.org/"$page"|grep -REi '^ *[0-9a-z]+ +node-v[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz'|sed -re 's/^ +//'
}


fetch_ten() {
	fetch_url
	fetch_url 1
	fetch_url 2
	fetch_url 3
	fetch_url 4
	fetch_url 5
	fetch_url 6
	fetch_url 7
	fetch_url 8
	fetch_url 9
	fetch_url 10
}


fetch_ten|sort -n|uniq
