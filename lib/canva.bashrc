#!/bin/bash

# GLOBALS

_1CANVALOCAL="$_1UDATA/canvas"

# Generate partial menu
function _nh1canva.menu {
  echo "___ Canva Section ___"
  echo "--- Create images from SVG templates"
  _1menuitem P 1canva "List all templates or help for given template"
  _1menuitem P 1canvagen "Generate image from template"
  _1menuitem P 1canvaadd "Install or update a template"
  _1menuitem P 1canvadel "Remove installed template"
}

# Destroy all global variables created by this file
function _nh1canva.clean {
  unset _1CANVALOCAL _1CANVALIB
  unset -f 1canva 1canvagen 1canvaadd 1canvadel
}

# Alias-like

# Configure your template path
function _nh1canva.setup {
    if [ ! -d "$_1CANVALOCAL" ]
    then
        mkdir -p "$_1CANVALOCAL"
        cp "$_1LIB/canva-template.svg" "$_1CANVALOCAL/hello.svg"
    fi
}

# List all installed templates
function 1canva {
    local fn tc
    _nh1canva.setup
    tc=0
    echo -n "Templates: "
    for fn in $(ls -1 "$_1CANVALOCAL")
    do        
        basename  "$fn" ".svg"
        tc=$((tc+1))
    done
    if [ $tc -eq 0 ]
    then
        echo "No template found."
    fi
}