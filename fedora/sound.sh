#!/bin/bash

# /proc/asound/card0/codec#0

headphones=false

function volume_up() {
	if $headphones
	then
		amixer set Master 5%+
	else
		amixer -c 0 set PCM 5%+
	fi
}

function volume_down() {
	if $headphones
	then
		amixer set Master 5%-
	else
		amixer -c 0 set PCM 5%-
	fi
}

function update_headphones() {
	# look for Pin-ctls segment of "Speaker Playback Switch"
	my_array=($(cat /proc/asound/card0/codec#0 | tr ' ' '-'))

	if [[ ${my_array[141]} =~ "OUT" ]]
	then
		headphones=false
	else
		headphones=true
	fi
}

case $1 in
	up)
		update_headphones
		volume_up
	;;
	down)
		update_headphones
		volume_down
	;;
	mute)
		amixer set Master toggle
		;;
esac
