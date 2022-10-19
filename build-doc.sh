#!/bin/bash

source nh1

if 1check shdoc
then
    _1verb "Doc for nh1 main file..."
    shdoc < nh1 > doc/nh1.md
fi

