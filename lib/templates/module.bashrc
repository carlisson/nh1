#!/bin/bash
# @file module.bashrc
# @brief Blank module, it is a template!
# @description
#     Template for a new NH1 module
#      * Copy it to lib/ and rename it
#      * Private functions starts with _nh1modulename
#      * Public functions starts with 1
#      * For every function, add it to .clean and .menu (if public)
#      * Comment every function with this notation (for shdoc)
#      * Custom vars can change module vars. Edit .customvars and .info
#      * Change main nh1 file, adding modulename to var _1MODULES
#      * After all, make a pull request to contribute to NH1 project!

# GLOBALS
_1LOCALVAR=0

# Private functions

# @description Generates partial menu
function _nh1module.menu {
  echo "___ Section Title ___"
  # _1menuitem X command "Description"
}

# @description Destroys all global variables created by this file
function _nh1module.clean {
  # unset variables
  unset _1LOCALVAR
  unset -f _nh1module.menu _nh1module.complete _nh1module.init
  unset -f _nh1module.info _nh1module.customvars _nh1module.clean
}

# @description Autocompletion instructions
function _nh1module.complete {
    _1verb "$(_1text "Enabling complete for new module.")"
}

# @description Set global vars from custom vars (config file)
function _nh1module.customvars {
  if [[ $NORG_CUSTOM_VAR ]]
    then
        _1LOCALVAR="$NORG_CUSTOM_VAR"
    fi
}

# @description General information about variables and customizing
function _nh1module.info {
    _1verb "$(_1text "Listing user variables")"
}

# @description Creates paths and copy initial files
function _nh1module.init {
  _1menuitem W NORG_CUSTOM_VAR "$(_1text "Description")"
}

# Alias-like

# Public functions
