#!/bin/bash

# replace 1module to real name

# GLOBALS
_1LOCALVAR=0

# Private functions

# Generate partial menu
function _nh1module.menu {
  echo "___ Section Title ___"
  # _1menuitem X command "Description"
}

# Destroy all global variables created by this file
function _nh1module.clean {
  # unset variables
  unset _1LOCALVAR
  unset -f _nh1module.menu _nh1module.complete _nh1module.init
  unset -f _nh1module.info _nh1module.customvars _nh1module.clean
}

# Autocompletion instructions
function _nh1module.complete {
    _1verb "$(_1text "Enabling complete for new module.")"
}

function _nh1module.customvars {
  if [[ $NORG_CUSTOM_VAR ]]
    then
        _1LOCALVAR="$NORG_CUSTOM_VAR"
    fi
}

# General information about variables and customizing
function _nh1module.info {
    _1verb "$(_1text "Listing user variables")"
}

# Create paths and copy initial files
function _nh1module.init {
  _1menuitem W NORG_CUSTOM_VAR "$(_1text "Description")"
}

# Alias-like

# Public functions
