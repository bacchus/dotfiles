#!/bin/bash

repo_status() {
    repo status -j8
}

repo_init() {
    if [ $# == 0 ]; then
        echo "need to specify <branch>"
        exit 0
    fi

    repo init -u <manifest> -b $1 --depth=1
}

repo_sync() {
    repo sync -j8 -c -d --no-tags --force-sync
}

# ------------------------------------------------------------------------------
show_usage() {
    echo "st     )   repo_status        "
    echo "sync   )   repo_sync          "
}

if [ $# == 0 ]; then
    show_usage
    exit 0
fi

case $1 in
st     )   repo_status           ;;
sync   )   repo_sync             ;;

*)  show_usage; exit 1
esac

exit 0

