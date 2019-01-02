#!/bin/bash

mWindow=nautilus\.Nautilus

mLocation=`pwd`
if [[ $# != 0 && $1 != "." ]]; then
    mParam=$1
    if [ ${mParam:0:1} == "/" ]; then
        mLocation=$1
    else
        mLocation=`pwd`/$1
    fi
fi

if [ "$(wmctrl -xl | grep "$mWindow")" == "" ]; then
    nautilus "$mLocation" 2>/dev/null &

else
    #Save old clipboard value
    oldclip="$(xclip -o -sel clip)"

    echo -n "$mLocation" | xclip -i -sel clip

    wmctrl -xF -R $mWindow && xdotool key --window $mWindow --delay 50 ctrl+t ctrl+l ctrl+v Return

    #Restore old clipboard value
    echo -n "$oldclip" | xclip -i -sel clip
fi
