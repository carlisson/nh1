# morph.bashrc

String transformations

## Overview

Generates partial menu

## Index

* [_nh1morph.menu](#_nh1morphmenu)
* [_nh1morph.clean](#_nh1morphclean)
* [_nh1morph.complete.morph](#_nh1morphcompletemorph)
* [_nh1morph.complete](#_nh1morphcomplete)
* [_nh1morph.customvars](#_nh1morphcustomvars)
* [_nh1morph.info](#_nh1morphinfo)
* [_nh1morph.init](#_nh1morphinit)
* [_nh1morph.usage](#_nh1morphusage)
* [1morph](#1morph)
* [1words](#1words)

### _nh1morph.menu

Generates partial menu

### _nh1morph.clean

Destroys all global variables created by this file

### _nh1morph.complete.morph

Completion for 1morph

#### Output on stdout

* A list of apps

### _nh1morph.complete

Autocompletion instructions

### _nh1morph.customvars

Set global vars from custom vars (config file)

### _nh1morph.info

General information about variables and customizing

### _nh1morph.init

Creates paths and copy initial files

### _nh1morph.usage

Usage instructions

#### Arguments

* **$1** (string): Public function name

### 1morph

Transforms a string

#### Arguments

* **$1** (string): Desired transformation. List to see all availables.
* **$2** (string): String to transform

### 1words

Converts integer into words

#### Arguments

* **$1** (int): Number

#### Output on stdout

* Converted number (string)

