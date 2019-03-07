#!/bin/bash

timeout=1sec
if [ $# != 0 ]; then
    timeout=$1
fi

echo Okay! Will ring you on $(date --date="$timeout").

sleep $(( $(date --date="$timeout" +%s) - $(date +%s) ))

notify-send --urgency=low "wake up neo!" -i ~/Pictures/cote.png

echo Wake up!

for i in 1 2 3; do
paplay ~/Music/mandrake.ogg & sleep 1
done
