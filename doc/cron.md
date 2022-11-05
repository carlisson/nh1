# cron.bashrc

Functions for automation

## Overview

Generates partial menu

## Index

* [_nh1cron.menu](#_nh1cronmenu)
* [_nh1cron.clean](#_nh1cronclean)
* [_nh1cron.complete](#_nh1croncomplete)
* [_nh1cron.customvars](#_nh1croncustomvars)
* [_nh1cron.info](#_nh1croninfo)
* [_nh1cron.init](#_nh1croninit)
* [_nh1cron.listtimes](#_nh1cronlisttimes)
* [_nh1cron.now](#_nh1cronnow)
* [_nh1cron.tick](#_nh1crontick)
* [_nh1cron.interrupt](#_nh1croninterrupt)
* [_nh1cron.crongroup](#_nh1croncrongroup)
* [_nh1cron.startup](#_nh1cronstartup)
* [1cronset](#1cronset)
* [1crondel](#1crondel)
* [1run](#1run)
* [1cron](#1cron)
* [1crond](#1crond)

### _nh1cron.menu

Generates partial menu

### _nh1cron.clean

Destroys all global variables created by this file

### _nh1cron.complete

Autocompletion instructions

### _nh1cron.customvars

Set global vars from custom vars (config file)

### _nh1cron.info

General information about variables and customizing

### _nh1cron.init

Creates paths and copy initial files

### _nh1cron.listtimes

Returns all times possible for cron

### _nh1cron.now

Returns condition based on time of cron

#### Arguments

* **$1** (string): Time of cron

### _nh1cron.tick

Set latest run in status

#### Arguments

* **$1** (string): Time of cron
* **$2** (string): Command ID

### _nh1cron.interrupt

Routine to run if interrupted

### _nh1cron.crongroup

Run all commands for given "time"

#### Arguments

* **$1** (string): Mode: normal/force/teste.
* **$2** (string): Cron time (group)

### _nh1cron.startup

Commands for time "start"

### 1cronset

Add or update a command to cron

#### Arguments

* **$1** (string): Time of cron: hour, day...
* **$2** (string): Command ID
* **$3** (string): Command

#### Exit codes

* **0**: It works
* **1**: Unknown cron time

### 1crondel

Remove a command from cron

#### Arguments

* **$1** (string): Time of cron: hour, day...
* **$2** (string): Command ID

### 1run

Run a command

#### Arguments

* **$1** (string): Wich time is the command (optional)
* **$2** (string): Command ID

#### Exit codes

* **0**: It works
* **1**: Command not found
* **2**: Unknown cron time

### 1cron

Check and run commands from cron

#### Arguments

* **$1** (string): Mode: normal/force/teste. Default: normal

### 1crond

Run cron as a daemon

