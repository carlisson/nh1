# nh1

Simple shell end user swiss army knife (toolkit) 

## Overview

A set of tools for shell.
* 1app - AppImage package manager
* audio, backup, network and rpg tools
* 1canva - create images from SVG templates
* other things
Documentation for shdoc - https://github.com/reconquest/shdoc

## Index

* [1tint](#1tint)
* [_1verb](#_1verb)
* [_1modrun](#_1modrun)
* [_1menuitem](#_1menuitem)
* [_1compl](#_1compl)
* [_1list](#_1list)
* [_1sudo](#_1sudo)
* [_nh1complete](#_nh1complete)
* [_nh1init](#_nh1init)
* [_nh1customvars](#_nh1customvars)
* [1check](#1check)
* [1clean](#1clean)
* [1help](#1help)
* [1bashrc](#1bashrc)
* [1refresh](#1refresh)
* [1update](#1update)
* [1version](#1version)
* [1verbose](#1verbose)
* [1translate](#1translate)
* [1info](#1info)
* [1builddoc](#1builddoc)

### 1tint

Set text color in shell

#### Example

```bash
echo "test: $(1tint 6 "Hello World")"
```

#### Arguments

* **$1** (int): The color number (optional)
* **$2** (string): Text to color

#### Exit codes

* **0**: If successful.
* **1**: If an empty string passed.

### _1verb

Print only if NH1 is in verbose mode

#### Arguments

* **$1** (string): Message to print

### _1modrun

Run it for all modules

#### Arguments

* **$1** (command): Replace -=- by module name

### _1menuitem

Print a line to build help menu

#### Arguments

* **$1** (char): Status of command (W, X, P or D: working, experimental, planning, deprecated)
* **$2** (string): Command name
* **$3** (string): Command description
* **$4** (string): list of commands to check (optional)

#### Exit codes

* **0**: If successful.
* **1**: Some command fail in checking

### _1compl

Generic complete function, finding formats

#### Arguments

* **$1** (string): 1st file format. 0 for none
* **$2** (string): 2nd file format. 0 for none
* **$3** (string): 3th file format. 0 for none
* **$4** (string): 4th file format. 0 for none
* **$5** (string): 5th file format. 0 for none

### _1list

Returns all internal items of one kind

#### Arguments

* **$1** (string): Path
* **$2** (string): File extension
* **$3** (string): exclude extension? (Optional. Default: yes)

#### Output on stdout

* The list of items

### _1sudo

Run the command as root

#### Arguments

* **$1** (string): Command

### _nh1complete

Configure completion for main file and all modules.

#### See also

* [_1compl](#_1compl)

### _nh1init

Initial functions, configuring and creating dirs

### _nh1customvars

Apply custom variables to internals

#### See also

* [1info](#1info)

### 1check

Check if a program exists. Finish NH1 if it do not exists.

#### Arguments

* $* string Program to check or "-s"

#### Exit codes

* **0**: Successful
* **1**: Fail in one or more checkings

### 1clean

Clean all variables defined by nh1

### 1help

Menu for NH1.

#### See also

* [_1menuitem](#_1menuitem)

### 1bashrc

Modify ~/.bashrc to init NH1 on bash start

### 1refresh

Reload NH1 and all related modules

### 1update

Update NH1 based in git repository

### 1version

List software version and list latest entries from changelog

### 1verbose

Enable or disable verbose mode

#### Arguments

* **$1** (int): Bit (0/1) to set verbose mode. Default: invert current. (Optional)

#### See also

* [_1verb](#_1verb)

### 1translate

Creates and applies translation for NH1

#### Arguments

* **$1** (string): Language code
* **$2** (string): Generate binaries. Optional. Default: none

#### See also

* [_1text](#_1text)

### 1info

Information about user variables

### 1builddoc

Build documentation

