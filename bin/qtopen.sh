#!/bin/bash

if [ $# == 0 ]; then
    echo "qtopen.sh <filename>"
    exit 0
fi

$TOOLS/qt/Tools/QtCreator/bin/qtcreator -client $1 && wmctrl -xF -R qtcreator.QtCreator
