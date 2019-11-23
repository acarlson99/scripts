#! /usr/bin/sh

case $# in
	1)
		xrandr --output eDP-1 --brightness $1
		;;
	*)
		echo 'Give argument for brightness between 0 and 1'
		;;
esac
