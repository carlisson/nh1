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

* [_1text](#_1text)
* [1tint](#1tint)
* [1tintb](#1tintb)
* [_nh1.spool](#_nh1spool)
* [_1message](#_1message)
* [_1verb](#_1verb)
* [_1verbs](#_1verbs)
* [_1verbs.spool](#_1verbsspool)
* [_1before](#_1before)
* [_nh1.modrun](#_nh1modrun)
* [_1menuitem](#_1menuitem)
* [1banner](#1banner)
* [_1menuheader](#_1menuheader)
* [_1menutip](#_1menutip)
* [_1compl](#_1compl)
* [_1list](#_1list)
* [_1sudo](#_1sudo)
* [_nh1.complete](#_nh1complete)
* [_nh1.complete.db](#_nh1completedb)
* [_nh1.complete.dbvar](#_nh1completedbvar)
* [_nh1.complete.dbshow](#_nh1completedbshow)
* [_nh1.init](#_nh1init)
* [_1customvar](#_1customvar)
* [_nh1.customvars](#_nh1customvars)
* [1check](#1check)
* [1clean](#1clean)
* [1help](#1help)
* [1bashrc](#1bashrc)
* [1refresh](#1refresh)
* [1update](#1update)
* [1version](#1version)
* [1verbose](#1verbose)
* [1translate](#1translate)
* [_nh1info.customizable](#_nh1infocustomizable)
* [_nh1info.customvars](#_nh1infocustomvars)
* [1info](#1info)
* [_nh1.builddoc.self](#_nh1builddocself)
* [_nh1.bulddoc](#_nh1bulddoc)
* [1builddoc](#1builddoc)
* [_1db](#_1db)
* [_1db.get](#_1dbget)
* [_1db.set](#_1dbset)
* [_1db.show](#_1dbshow)
* [1db](#1db)
* [1dbget](#1dbget)
* [1dbset](#1dbset)
* [1dbshow](#1dbshow)
* [_1vardb.init](#_1vardbinit)
* [_1vardb.get](#_1vardbget)
* [_1vardb.set](#_1vardbset)
* [_1vardb.show](#_1vardbshow)

### _1text

Prints message in user language, using Gettext

#### Arguments

* **$1** (string): Message in English to translate

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

### 1tintb

Set text background color in shell

#### Arguments

* **$1** (int): The color number (optional)
* **$2** (string): Text to color

#### Exit codes

* **0**: If successful.
* **1**: If an empty string passed.

### _nh1.spool

Proccess message spool

#### Arguments

* **$1** (string): Filename to proccess
* **$2** (string): Prefix for every line

### _1message

Internal message

#### Arguments

* **$1** (string): Type of message: info, warning, error, bg
* **$2** (string): Message to show

### _1verb

Print only if NH1 is in verbose mode

#### Arguments

* **$1** (string): Message to print

### _1verbs

Spools message to shows when possible

#### Arguments

* **$1** (string): Message to print

### _1verbs.spool

Prints dammed verbose messages

### _1before

Procedores to do before all user command

### _nh1.modrun

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

### 1banner

Print a message inside a banner

#### Arguments

* **$1** (string): Width (optional)

### _1menuheader

Print menu header

#### Arguments

* **$1** (string): Title for menu

### _1menutip

Print a tip in user menu

#### Arguments

* **$1** (string): Tip or details

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

### _nh1.complete

Configure completion for main file and all modules.

#### See also

* [_1compl](#_1compl)

### _nh1.complete.db

Autocompletion for 1db

### _nh1.complete.dbvar

Autocompletion for 1dbget and 1dbget

### _nh1.complete.dbshow

Autocompletion for 1dbshow

### _nh1.init

Initial functions, configuring and creating dirs

### _1customvar

Load custom var from config

#### Arguments

* **$1** (string): Custom var name
* **$2** (string): Internal var name
* **$3** (string): Type. string or number. Default: string.

### _nh1.customvars

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

### _nh1info.customizable

Information about user variables

### _nh1info.customvars

Shows user-defined variables

### 1info

General information

#### Arguments

* **$1** (string): Type of information. Default: all

### _nh1.builddoc.self

Build documentation for NH1

### _nh1.bulddoc

Build documentation for some bash script(s) 

#### Arguments

* **$1** (string): Project name
* **$2** (string): Directory where to put doc
* **$3** (string): List of bash files

### 1builddoc

Build documentation

#### Arguments

* **$1** (string): Project name
* **$2** (string): Documentation directory
* **$3** (string): List of source files

### _1db

List or manage a internal key-value database

#### Arguments

* **$1** (string): Path for database
* **$2** (string): File extension
* **$3** (string): Command: new or del.
* **$4** (string): Database name

#### Exit codes

* **0**: Ok
* **1**: File exists
* **2**: File not exists
* **3**: Wrong usage

### _1db.get

Get value for some saved variable

#### Arguments

* **$1** (string): Path for database
* **$2** (string): File extension
* **$3** (string): Database name
* **$4** (string): Variable name
* **$5** (string): Silent mode (optional)

#### Exit codes

* **0**: Ok
* **1**: Var not found
* **2**: File not found
* **3**: Wrong usage

### _1db.set

Set value for a variable

#### Arguments

* **$1** (string): Path for database
* **$2** (string): File extension
* **$3** (string): Database name
* **$4** (string): Variable name
* **$5** (string): Value

#### Exit codes

* **0**: Ok
* **1**: File not found
* **2**: Wrong usage

### _1db.show

List all variables in a DB

#### Arguments

* **$1** (string): Path for database
* **$2** (string): File extension
* **$3** (string): Database name
* **$4** (int): Size of variable column (optional. Default: 10)
* **$4** (string): If value is "list", it works lik _1list

#### Exit codes

* **0**: Ok
* **1**: File not found
* **2**: Wrong usage

### 1db

List or manage a internal key-value database

#### Arguments

* **$1** (string): Command: new or del (optional).
* **$2** (string): Database name (optional)

#### Exit codes

* **0**: Ok
* **1**: File exists
* **2**: File not exists

### 1dbget

Get a value from internal key-valeu database

#### Arguments

* **$1** (string): Database name
* **$2** (string): Variable name

### 1dbset

Set a value from internal key-valeu database

#### Arguments

* **$1** (string): Database name
* **$2** (string): Variable name
* **$3** (string): Variable value

### 1dbshow

Shows all variables for a database

#### Arguments

* **$1** (string): Database filename
* **$2** (string): Mode: show or list. Default: show

### _1vardb.init

initialize var database (internal)

#### Arguments

* **$1** (string): Database name

### _1vardb.get

returns value for internal var

#### Arguments

* **$1** (string): Database name
* **$2** (string): Variable name

### _1vardb.set

Sets a value for internal var

#### Arguments

* **$1** (string): Database name
* **$2** (string): Variable name
* **$3** (string): Value

### _1vardb.show

Shows all saved vars for db

#### Arguments

* **$1** (string): Database name
* **$2** (string): Mode: list or show. Default: show

