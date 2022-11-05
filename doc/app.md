# app.bashrc

Package manager for AppImage applications

## Overview

Generates partial menu

## Index

* [_nh1app.menu](#_nh1appmenu)
* [_nh1app.clean](#_nh1appclean)
* [1applupd](#1applupd)
* [1appgupd](#1appgupd)
* [1appldel](#1appldel)
* [1appgdel](#1appgdel)
* [1applclear](#1applclear)
* [1appgclear](#1appgclear)
* [_nh1app.complete](#_nh1appcomplete)
* [_nh1app.avail](#_nh1appavail)
* [_nh1app.setup](#_nh1appsetup)
* [_nh1app.init](#_nh1appinit)
* [_nh1app.customvars](#_nh1appcustomvars)
* [_nh1app.info](#_nh1appinfo)
* [_nh1app.checksetup](#_nh1appchecksetup)
* [1app](#1app)
* [_nh1app.openapp](#_nh1appopenapp)
* [_nh1app.closeapp](#_nh1appcloseapp)
* [_nh1app.description](#_nh1appdescription)
* [_nh1app.checkversion](#_nh1appcheckversion)
* [_nh1app.mkdesktop](#_nh1appmkdesktop)
* [_nh1app.clearold](#_nh1appclearold)
* [_nh1app.single](#_nh1appsingle)
* [_nh1app.add](#_nh1appadd)
* [1appladd](#1appladd)
* [1appgadd](#1appgadd)
* [_nh1app.list](#_nh1applist)
* [_nh1app.update](#_nh1appupdate)
* [_nh1app.where](#_nh1appwhere)
* [1appxupd](#1appxupd)
* [1appxadd](#1appxadd)
* [1appxclear](#1appxclear)
* [_nh1app.remove](#_nh1appremove)
* [_nh1app.clear](#_nh1appclear)

### _nh1app.menu

Generates partial menu

### _nh1app.clean

Destroy all global variables created by this file

### 1applupd

Update all local apps

### 1appgupd

Update all global apps

### 1appldel

Uninstall local app

#### Arguments

* **$1** (string): Application name

### 1appgdel

Uninstall global app

#### Arguments

* **$1** (string): Application name

### 1applclear

Remove old versions of local apps

### 1appgclear

Remove old versions of global apps

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

### 1app

List all available app image for installation

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

#### Output on stdout

* Application description

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

### 1appladd

Install locally an app

#### Arguments

* **$1** (string): App to install

#### See also

* [_nh1app.add](#_nh1appadd)

### 1appgadd

Install globally an app

#### Arguments

* **$1** (string): App to install

#### See also

* [_nh1app.add](#_nh1appadd)

### _nh1app.list

Based on avail, list apps with filters

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

### 1appxupd

Upgrade all system packages

### 1appxadd

Install program using system package manager

#### Arguments

* **$1** (string): Package name

#### Exit codes

* 0

### 1appxclear

Remove old versions of system apps, in debian, snap, flatpak...

### _nh1app.remove

Removes an installed app

#### Arguments

* **$1** (string): local or global 
* **$2** (string): App name

### _nh1app.clear

Clear unused old versions for every app

#### Arguments

* **$1** (string): local or global

