#!/bin/sh

current_win() {
	xprop -root _NET_ACTIVE_WINDOW | sed 's/^.*# \(0x[^,]*\),.*$/\1/'
}

current_win_height() {
	xwininfo -stats -id $(current_win) | sed -n 's/^  Height: \([0-9]\+\)$/\1/p'
}

current_win_width() {
	xwininfo -stats -id $(current_win) | sed -n 's/^  Width: \([0-9]\+\)$/\1/p'
}

case $1 in
	up)
		wmctrl -r :ACTIVE: -e 0,-1,0,-1,-1
		;;
	left)
		wmctrl -r :ACTIVE: -e 0,0,-1,-1,-1
		;;
	down)
		height=`current_win_height`
		wmctrl -r :ACTIVE: -e 0,-1,$((1070 - $(($height + 24)))),-1,-1
		# wmctrl -r :ACTIVE: -e 0,-1,$((1021 - $(($height + 24)))),-1,-1
		;;
	right)
		width=`current_win_width`
		wmctrl -r :ACTIVE: -e 0,$((1920 - $(($width + 10)))),-1,-1,-1
		;;
	middle)
		width=`current_win_width`
		height=`current_win_height`
		wmctrl -r :ACTIVE: -e 0,$((960 - $(($width + 10)) / 2)),$((600 - $(($height + 24)) / 2)),-1,-1
		;;
	tall)
		height=`current_win_height`
		wmctrl -r :ACTIVE: -e 0,-1,-1,-1,$(($height + 10))
		;;
	short)
		height=`current_win_height`
		wmctrl -r :ACTIVE: -e 0,-1,-1,-1,$(($height - 10))
		;;
	wide)
		width=`current_win_width`
		wmctrl -r :ACTIVE: -e 0,-1,-1,$(($width + 10)),-1
		;;
	thin)
		width=`current_win_width`
		wmctrl -r :ACTIVE: -e 0,-1,-1,$(($width - 10)),-1
		;;
	*)
		echo "Invalid option $1"
		exit 1
		;;
esac
