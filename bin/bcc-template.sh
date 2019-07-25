#!/bin/bash

BCC_HELLO="hello kittie=)"
echo "$(tput setab 4) --- $BCC_HELLO --- $(tput sgr0)"

# ------------------------------------------------------------------------------
test_a() {
    echo "$(tput setab 3) --- test_a [$1] --- $(tput sgr0)"
    
    res=$?
    if [ $res != 0 ] ; then
        echo "$(tput setab 1) --- Error! ☠ --- $(tput sgr0)"
    else
        echo "$(tput setab 2) --- Finished! Enjoy! 😊 --- $(tput sgr0)"
    fi
    exit $res
}

test_b() {
    echo "$(tput setab 3) --- test_b [${@:1}] --- $(tput sgr0)"
}

# ------------------------------------------------------------------------------
show_usage() {
    echo "h      )   show_usage     "
    echo "a      )   test_a <a>     "
    echo "b      )   test_b [*]     "
}

if [ $# == 0 ]; then
    show_usage
    exit 0
fi

case $1 in
h       )   show_usage              ;;
a       )   test_a $2               ;;
b       )   test_b ${@:2}           ;;

*)  show_usage; exit 1
esac

exit 0

