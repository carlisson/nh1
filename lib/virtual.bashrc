#!/bin/bash
# @file virtual.bashrc
# @brief Virtual machine and containers
# @description

# GLOBALS
_1VIRTUALCONT=0

# Private functions

# @description Generates partial menu
_nh1virtual.menu() {
  _1menuheader "Virtual"
  # _1menutip Optional complementar instruction
  # _1menuitem X command "Description"
  _1menuitem W NORG_VIRTUAL_CONTAINER "$(_1text "Description")"
}

# @description Destroys all global variables created by this file
_nh1virtual.clean() {
  # unset variables
  unset _1LOCALCONT
  unset -f _nh1virtual.menu _nh1virtual.complete _nh1virtual.init
  unset -f _nh1virtual.info _nh1virtual.customvars _nh1virtual.clean
  unset -f _nh1virtual.usage _nh1virtual.contbuild _nh1virtual.contcheck
}

# @description Autocompletion instructions
_nh1virtual.complete() {
    _1verb "$(_1text "Enabling complete for new module.")"
}

# @description Set global vars from custom vars (config file)
_nh1virtual.customvars() {
  _1customvar NORG_VIRTUAL_CONTAINER _1VIRTUALCONT
}

# @description General information about variables and customizing
_nh1virtual.info() {
    _1verb "$(_1text "Listing user variables")"
}

# @description Creates paths and copy initial files
_nh1virtual.init() {
  if [ "$_1VIRTUALCONT" = "0" ]
  then
    if 1check podman
    then
      _1VIRTUALCONT="podman"
    elif 1check docker
    then
      _1VIRTUALCONT="docker"
    fi
  fi
}

# @description Usage instructions
# @arg $1 string Public function name
_nh1virtual.usage() {
  case $1 in
    *)
      echo
      ;;
  esac
}

# @description Build a container from Dockerfile
# @arg $1 string Dockerfile, use name.df or name.Dockerfile
# @arg $2 string Container name. If empty, use "name"
_nh1virtual.contbuild() {
  if 1check getenforce
  then
    if [ "$(getenforce)" == "Enforcing" ]
    then
      echo "$(printf "$(_1text "SE Linux enabled. Please run %s.")" "sudo setenforce 0")"
      exit
    fi
  fi

  _DF="$1"
  if [ $# -eq 2 ]
  then
    _CN="$2"
  else
    _CN="$(echo "$1" | sed 's/\([^\.]*\)\.\(df\|Dockerfile\)$/\1/g')"
  fi

  $_1VIRTUALCONT build -t "$_CN" -f "$1" .
}

# @description Check if a conatiner exists in local scope
# @arg string Container name
_nh1virtual.contcheck() {
  if $_1VIRTUALCONT images | grep "^localhost/$1" &> /dev/null
  then
    _1verb "$(_1text "Container exists.")"
    return 0
  else
    _1verb "$(_1text "Container not found.")"
    return 1
  fi
}

# @description Lists all local containers
_nh1virtual.contlist() {
  _1menuheader "$(_1text "Local containers")"
  for _EC in $($_1VIRTUALCONT images | grep "^localhost/" | sed 's/^localhost\/\([^\s]*\) .*$/\1/g')
  do
    echo -n "$_EC "
    if [ -f "$_EC.df" ] || [ -f "$_EC.Dockerfile" ]
    then
      1tint $_1COLOR " ($(_1text "dockerfile"))"
    fi
    echo
  done
}

# Alias-like

# Public functions

1container() {
    if [ $# -ge 1 ]
    then
        case "$1" in
            build)
                _nh1virtual.contbuild "$@"
                ;;
            check)
                _nh1virtual.contcheck "$2"
                ;;
            list)
                _nh1virtual.contlist
                ;;
            start)
                _nh1virtual.contstart "$2"
                ;;
            stop)
                _nh1virtual.contstop "$2"
                ;;
            *)
                _nh1virtual.contusage
                ;;
        esac
    else
        _nh1virtual.contusage
    fi
}
