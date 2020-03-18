#!/bin/bash

if [[ $# -eq 1 ]]; then
	mkdir -p $1
	cd $1 || (echo "UNABLE TO CD" && exit 1)
else
	mkdir -p my-playlist
	cd my-playlist || (echo "UNABLE TO CD" && exit 1)
fi


OUT=/tmp/tmp-out.html
QUERYFMT="https://www.youtube.com/results?search_query=%s"
WATCHFMT="https://www.youtube.com%s"
echo "Reading song names from stdin"
while read LINE; do
	echo $LINE

	if [[ ${#LINE} -eq 0 ]]; then
		echo "Input line is of 0 length.  Skipping"
		continue
	fi

	QUERYURL=$(printf $QUERYFMT $(echo $LINE | sed 's/ /+/g'))
	echo "Curling $QUERYURL"
	curl "$QUERYURL" > $OUT
	URL=`grep 'href="/watch?v=[a-zA-Z0-9_]\+"' $OUT		\
		| head -n1										\
		| awk -F'href="' '{print $2}'					\
		| awk -F'"' '{print $1}'`

	if [[ ${#URL} -eq 0 ]]; then
		echo "URL is of 0 length.  Skipping"
		continue
	fi

	WATCHURL=`printf $WATCHFMT $URL`
	echo "Downloading $WATCHURL"
	youtube-dl -f bestaudio $WATCHURL || youtube-dl $WATCHURL
done
