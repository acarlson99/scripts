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

	# TODO: format url properly
	QUERYURL=$(printf $QUERYFMT $(echo $LINE | sed 's/ /+/g'))
	echo "Curling $QUERYURL"
	curl "$QUERYURL" > $OUT
	URL=`grep -o '/watch?v=[0-9A-Za-z?_-]\+' $OUT | head -n1`

	if [[ ${#URL} -eq 0 ]]; then
		echo "URL is of 0 length.  Skipping"
		continue
	fi

	WATCHURL=`printf $WATCHFMT $URL`
	echo "Downloading $WATCHURL"
	youtube-dl -f bestaudio $WATCHURL || youtube-dl $WATCHURL
done
