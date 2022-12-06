# app.bashrc

Package manager for AppImage applications

## Overview

Generates partial menu

## Index

* [_nh1app.menu](#_nh1appmenu)
* [_nh1app.clean](#_nh1appclean)
* [_nh1app.complete](#_nh1appcomplete)
* [_nh1app.avail](#_nh1appavail)
* [_nh1app.setup](#_nh1appsetup)
* [_nh1app.init](#_nh1appinit)
* [_nh1app.customvars](#_nh1appcustomvars)
* [_nh1app.info](#_nh1appinfo)
* [_nh1app.checksetup](#_nh1appchecksetup)
* [_nh1app.openapp](#_nh1appopenapp)
* [_nh1app.closeapp](#_nh1appcloseapp)
* [_nh1app.description](#_nh1appdescription)
* [_nh1app.ghversion](#_nh1appghversion)
* [_nh1app.checkversion](#_nh1appcheckversion)
* [_nh1app.mkdesktop](#_nh1appmkdesktop)
* [_nh1app.clearold](#_nh1appclearold)
* [_nh1app.gitget](#_nh1appgitget)
* [_nh1app.single](#_nh1appsingle)
* [_nh1app.add](#_nh1appadd)
* [_nh1app.clist](#_nh1appclist)
* [_nh1app.nlist](#_nh1appnlist)
* [_nh1app.update](#_nh1appupdate)
* [_nh1app.where](#_nh1appwhere)
* [_nh1app.remove](#_nh1appremove)
* [_nh1app.clear](#_nh1appclear)
* [_nh1app.list](#_nh1applist)
* [_nh1app.sysadd](#_nh1appsysadd)
* [_nh1app.sysupdate](#_nh1appsysupdate)
* [_nh1app.sysdel](#_nh1appsysdel)
* [_nh1app.sysclear](#_nh1appsysclear)
* [_nh1app.usage](#_nh1appusage)
* [1app](#1app)
* [1appre](#1appre)

### _nh1app.menu

Generates partial menu

### _nh1app.clean

Destroy all global variables created by this file

### _nh1app.complete

Autocompletion for 1app

### _nh1app.avail

List all available apps

#### Output on stdout

* List of available apps

### _nh1app.setup

Configure your local or global path/dir

#### Arguments

* **$1** (string): local or global

### _nh1app.init

Startup function

#### See also

* [_nh1app.setup](#_nh1appsetup)

### _nh1app.customvars

Apply custom vars

### _nh1app.info

Information about custom vars

#### See also

* [_nh1app.customvars](#_nh1appcustomvars)

### _nh1app.checksetup

Check if setup is ok

#### Arguments

* **$1** (string): local or global

#### Exit codes

* **0**: Setup is ok
* **1**: Setup is not ok

### _nh1app.openapp

Open app recipe file

#### Arguments

* **$1** (string): App name

#### Exit codes

* **0**: It's ok
* **1**: File not found

#### See also

* [_nh1app.closeapp](#_nh1appcloseapp)

### _nh1app.closeapp

Close app recipe (clear all loaded vars for recipe)

#### See also

* [_nh1app.openapp](#_nh1appopenapp)

### _nh1app.description

Returns description for an available app

#### Arguments

* **$1** (string): Application name
* **$2** (int): Length to print

#### Output on stdout

* Application description

### _nh1app.ghversion

Returns latest version for github code

#### Arguments

* **$1** (string): Github project owner
* **$2** (string): Github project name

### _nh1app.checkversion

Returns newest file version or actual

#### Arguments

* **$1** (string): What to check: new, local or global
* **$2** (string): Application name

#### Output on stdout

* Full file name

### _nh1app.mkdesktop

Creates a Desktop file

#### Arguments

* **$1** (string): App internal name
* **$2** (string): local or global

### _nh1app.clearold

Removes old files for app

#### Arguments

* **$1** (string): Path of files
* **$2** (string): Latest file name
* **$3** (string): App prefix
* **$4** (string): local or global

### _nh1app.gitget

Downloader for git

#### Arguments

* **$1** (string): App name
* **$2** (string): app-directory
* **$3** (string): symlink
* **$4** (string): local or global

### _nh1app.single

Single downloader

#### Arguments

* **$1** (string): App name
* **$2** (string): app-directory
* **$3** (string): symlink
* **$4** (string): local or global

### _nh1app.add

Internal 1app generic installer

#### Arguments

* **$1** (string): local or global
* **$2** (string): App to install

### _nh1app.clist

Based on avail, list apps with filters

#### Arguments

* **$1** (string): local or global
* **$2** (int): installed (1) or not-installed (0)

#### Output on stdout

* A list of apps

### _nh1app.nlist

New completion for 1app

#### Arguments

* **$1** (string): local or global
* **$2** (int): installed (1) or not-installed (0)

#### Output on stdout

* A list of apps

### _nh1app.update

Update all installed apps

#### Arguments

* **$1** (string): local or global

### _nh1app.where

Returns full path for a command, if exists

#### Arguments

* **$1** (string): App to test

#### Exit codes

* **0**: Command exists
* **1**: Command not found

#### Output on stdout

* Path for command

### _nh1app.remove

Removes an installed app

#### Arguments

* **$1** (string): local or global
* **$2** (string): App name

### _nh1app.clear

Clear unused old versions for every app

#### Arguments

* **$1** (string): local or global

### _nh1app.list

List all available app image for installation

### _nh1app.sysadd

Install program using system package manager

#### Arguments

* **$1** (string): Package name

#### Exit codes

* 0

### _nh1app.sysupdate

Upgrade all system packages

### _nh1app.sysdel

Uninstall a system application

#### Arguments

* **$1** (string): Application to uninstall

### _nh1app.sysclear

Remove old versions of system apps, in debian, snap, flatpak...

### _nh1app.usage

Usage instructions

#### Arguments

* **$1** (string): Public function name

### 1app

App manager

#### Arguments

* **$1** (string): Command
* **$2** (string): scope
* **$3** (string): complementar argument

### 1appre

Run a regular expression and return info to help you to create a 1app recipe

#### Arguments

* **$1** (string): Target URL
* **$2** (string): String to search

