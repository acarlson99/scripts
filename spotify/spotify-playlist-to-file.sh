#!/bin/bash

# DEPRECATED
echo DEPRECATED! USE get-song-names

if [[ $# -ne 1 ]]; then
	echo "usage: $0 playlisturl"
	exit 1
fi

OUT=/tmp/spotify-tmp-out.html
curl $1 > $OUT
NAME=""
BAND=""
while read LINE; do
	if [[ $LINE == *'class="track-name"'* ]]; then
		echo $LINE | sed -E 's/<\/div><\/div><div class="tracklist-col name"><div class="top-align track-name-wrapper"><span class="track-name" dir="auto">(.*)<\/span><span class="artists-albums"><a href="\/[[:alnum:]]+\/[[:alnum:]]+" tabindex="-1"><span dir="auto">([^<>]+)<.*$/\1 \2/'
	fi
done < $OUT

rm $OUT
