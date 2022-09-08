#!/bin/bash

# GLOBALS

_1APPLOCAL="$HOME/.nh1/apps"
_1APPLBIN="$HOME/bin"
_1APPGLOBAL="/opt/nh1/apps"
_1APPGBIN="/usr/local/bin"

# Generate partial menu
function _nh1app.menu {
  echo "___ Install AppImage ___"
  _1menuitem X 1applsetup "Configure your local path/dir"
  _1menuitem P 1appgsetup "Configure global path/dir"
  _1menuitem P 1appladd "Install an appimage locally"
  _1menuitem P 1appgadd "Install an appimage globaly"
  _1menuitem P 1applupd "Update a local appimage (or all)"
  _1menuitem P 1appgupd "Update a global appimage (or all)"
  _1menuitem P 1appldel "Remove a local appimage"
  _1menuitem P 1appgdel "Remove a global appimage"
  _1menuitem P 1applclear "Remove old versions for a local appimage (or all)"
  _1menuitem P 1appgclear "Remove old versions for a global appimage (or all)"
  _1menuitem P 1appl "List all local appimage"
  _1menuitem P 1appg "List all global appimage"
}

# Destroy all global variables created by this file
function _nh1app.clean {
  unset _1APPLOCAL _1APPLBIN _1APPGLOBAL _1APPGBIN
  unset -f _nh1app.menu _nh1app.clean 1applsetup
}

# Configure your local path/dir
function 1applsetup {
    mkdir -p "$_1APPLOCAL"
    mkdir -p "$_1APPLBIN"
    grep "$_1APPLBIN" "$HOME/.bashrc" 2>1 > /dev/null
    if [ $? -eq 0 ]
    then
        echo "1app may be installed. Check your .bashrc to confirm."
        echo "PATH shold include $_1APPLBIN"
    else
        echo "PATH=\"\$PATH:$_1APPLBIN\"" >> "$HOME/.bashrc"
        echo "1app configured"
    fi
}
