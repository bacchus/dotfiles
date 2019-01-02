#!/bin/bash

DIRS=./*/

for d in $DIRS; do
    pushd $d > /dev/null
    git remote -v | grep fetch
    popd > /dev/null
done
