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
  unset -f _nh1module.menu _nh1module.complete
}

# Autocompletion instructions
function _nh1module.complete {
    _1verb "Enabling complete for 1module."
}

# General information about variables and customizing
function _nh1module.info {
    _1verb "Listing user variables"
}

# Create paths and copy initial files
function _nh1module.init {
    
}
# Alias-like

