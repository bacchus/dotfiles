#!/bin/bash

echo Okay! Will ring you on $(date --date="$1").

sleep $(( $(date --date="$1" +%s) - $(date +%s) ));

echo Wake up!

for i in 1 2 3; do
paplay ~/Music/mandrake.ogg & sleep 1
done