# ui.bashrc

Generic user Interface for dialogs

## Overview

Generate partial menu

## Index

* [_nh1ui.menu](#_nh1uimenu)
* [_nh1ui.item](#_nh1uiitem)
* [_nh1ui.clean](#_nh1uiclean)
* [_nh1ui.complete.ui](#_nh1uicompleteui)
* [_nh1ui.complete](#_nh1uicomplete)
* [_nh1ui.customvars](#_nh1uicustomvars)
* [_nh1ui.info](#_nh1uiinfo)
* [_nh1ui.init](#_nh1uiinit)
* [_nh1ui.usage](#_nh1uiusage)
* [_nh1ui.simpleconfirm](#_nh1uisimpleconfirm)
* [_nh1ui.simpleask](#_nh1uisimpleask)
* [_nh1ui.simpleselect](#_nh1uisimpleselect)
* [_nh1ui.choose](#_nh1uichoose)
* [_nh1ui.say](#_nh1uisay)
* [_nh1ui.confirm](#_nh1uiconfirm)
* [_nh1ui.ask](#_nh1uiask)
* [_nh1ui.select](#_nh1uiselect)
* [1ui](#1ui)

### _nh1ui.menu

Generate partial menu

### _nh1ui.item

Generates special menu

### _nh1ui.clean

Destroys all global variables created by this file

### _nh1ui.complete.ui

UI Completion

#### Output on stdout

* A list of apps

### _nh1ui.complete

Autocompletion instructions

### _nh1ui.customvars

Set global vars from custom vars (config file)

### _nh1ui.info

General information about variables and customizing

### _nh1ui.init

Creates paths and copy initial files

### _nh1ui.usage

Usage instructions

#### Arguments

* **$1** (string): Public function name

### _nh1ui.simpleconfirm

Question user using read

#### Arguments

* **$1** (Message,): question

#### Exit codes

* **0**: User confirm
* **1**: User says no

### _nh1ui.simpleask

Question user using read

#### Arguments

* **$1** (Message,): question

#### Exit codes

* **0**: User confirm
* **1**: User says no

### _nh1ui.simpleselect

Shows a menu with options to user choose one

#### Arguments

* **$1** (string): Message to show
* **$2** (string): Every argument

#### Exit codes

* **0**: User choose
* **1**: User cancel

#### Output on stdout

* string choonsen option

### _nh1ui.choose

Choose best dialog system

### _nh1ui.say

Show information to user

#### Arguments

* **$1** (Message): to show

### _nh1ui.confirm

Ask user for confirmation

#### Arguments

* **$1** (Question): to user

#### Exit codes

* **0**: User confirm
* **1**: User says no
* **2**: Other situation

### _nh1ui.ask

Ask user for a text

#### Arguments

* **$1** (Question): to user

#### Output on stdout

* String writen by user

### _nh1ui.select

Shows a menu with options to user choose one

#### Arguments

* **$1** (string): Message to show
* **$2** (string): Every argument

#### Output on stdout

* string choonsen option

### 1ui

Main command for User Interface

#### Arguments

* **$1** (string): Help or type of function
* **$2** (string): Message to show

