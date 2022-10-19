#!/bin/bash

source nh1

if ! 1check shdoc
then
    echo "shdoc not found"
    return 1
fi

_1verb "Doc for nh1 main file..."
shdoc < nh1 > doc/nh1.md
