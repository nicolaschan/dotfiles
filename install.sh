#!/bin/bash

safe-copy () {
    TARGET=$1
    DESTINATION=$2

    if [ -e $DESTINATION ]; then
        mv $DESTINATION $DESTINATION.orig
    fi
    cp $TARGET $DESTINATION
}

BASEDIR=$(dirname "$0")
safe-copy $BASEDIR/.bashrc ~/.bashrc
safe-copy $BASEDIR/.bash_aliases ~/.bash_aliases

source ~/.bashrc
