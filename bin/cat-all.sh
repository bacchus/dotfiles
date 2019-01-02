#!/bin/bash

echo "$(tput setab 3) --- cat-all 🐱 --- $(tput sgr0)"

for i in $(ls); do
    echo "## file: $i"
    cat $i
    echo ""
done
