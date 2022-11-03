#!/bin/bash
# @file cron.bashrc
# @brief Functions for automation

# GLOBALS
_1CRONDIR=0

# Private functions

# @description Generates partial menu
_nh1cron.menu() {
  _1menuheader "Cron Section"
  # _1menutip Optional complementar instruction
  # _1menuitem X command "Description"
}

# @description Destroys all global variables created by this file
_nh1cron.clean() {
  # unset variables
  unset _1CRONDIR
  unset -f _nh1cron.menu _nh1cron.complete _nh1cron.init
  unset -f _nh1cron.info _nh1cron.customvars _nh1cron.clean
}

# @description Autocompletion instructions
_nh1cron.complete() {
    _1verb "$(_1text "Enabling complete for cron module.")"
}

# @description Set global vars from custom vars (config file)
_nh1cron.customvars() {
  _1customvar NORG_CRON_DIR _1CRONDIR
}

# @description General information about variables and customizing
_nh1cron.info() {
    _1menuitem W NORG_CRON_DIR "$(_1text "Path for cron rules")"
}

# @description Creates paths and copy initial files
_nh1cron.init() {
  mkdir -p "$_1CRONDIR"
}

# Alias-like

# Public functions
