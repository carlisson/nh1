#!/bin/bash

# replace 1module to real name

# GLOBALS

# Generate partial menu
function _nh1module.menu {
  echo "___ Section Title ___"
  # _1menuitem X command "Description"
}

# Destroy all global variables created by this file
function _nh1module.clean {
  # unset variables
  unset -f _nh1module.menu _nh1module.complete _nh1module.init
  unset -f _nh1module.info
}

# Autocompletion instructions
function _nh1module.complete {
    _1verb "$(_1text "Enabling complete for new module.")"
}

# General information about variables and customizing
function _nh1module.info {
    _1verb "$(_1text "Listing user variables")"
}

# Create paths and copy initial files
function _nh1module.init {
    _1vrb "$(_1text "Running initial setup for new module")"
}
# Alias-like

