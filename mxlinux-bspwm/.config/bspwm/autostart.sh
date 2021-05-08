#!/bin/bash

#startxfce4 &

if pgrep -x "xfwm4" > /dev/null
then
	killall xfwm4
fi


sxhkd &
compton &
. "${HOME}/.config/bspwm/colors.sh"

#Other application can be added here to autostart
(sleep 2; alacritty -e /home/sampad/.walrc ) &
