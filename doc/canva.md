# canva.bashrc

Tools to generate images from templates

## Overview

Generate partial menu

## Index

* [_nh1canva.menu](#_nh1canvamenu)
* [_nh1canva.clean](#_nh1canvaclean)
* [_nh1canva.complete](#_nh1canvacomplete)
* [_nh1canva.customvars](#_nh1canvacustomvars)
* [_nh1canva.info](#_nh1canvainfo)
* [_nh1canva.complete.canvaadd](#_nh1canvacompletecanvaadd)
* [_nh1canva.complete.list](#_nh1canvacompletelist)
* [_nh1canva.complete.listp](#_nh1canvacompletelistp)
* [_nh1canva.init](#_nh1canvainit)
* [_nh1canva.thelp](#_nh1canvathelp)
* [1canva](#1canva)
* [1token](#1token)
* [1canvagen](#1canvagen)
* [1tokengen](#1tokengen)
* [1canvaadd](#1canvaadd)
* [1tokenadd](#1tokenadd)
* [1canvadel](#1canvadel)
* [1tokendel](#1tokendel)

### _nh1canva.menu

Generate partial menu

### _nh1canva.clean

Destroy all global variables created by this file

### _nh1canva.complete

Auto-completion

### _nh1canva.customvars

Load variables defined by user

### _nh1canva.info

Information about custom vars

### _nh1canva.complete.canvaadd

Autocomplete for 1canvaadd

### _nh1canva.complete.list

Autocomplete list of canva templates

### _nh1canva.complete.listp

Autocomplete list of canva/token templates

### _nh1canva.init

Configure your template path

### _nh1canva.thelp

Show 1canva help for saved template

#### Arguments

* **$1** (string): Template name

### 1canva

List all installed templates

### 1token

List all installed templates

### 1canvagen

List help for template or apply it

#### Arguments

* **$1** (string): template name
* **$2** (string): output file (.jpg, .png or other)
* **$3** (string): substitutions in key=value syntax

### 1tokengen

List help for template or apply it

#### Arguments

* **$1** (string): template name
* **$2** (string): output file (.jpg, .png or other)
* **$3** (string): input file to apply token template

### 1canvaadd

Add a svg template

#### Arguments

* **$1** (string): SVG to add

### 1tokenadd

Add a png template

#### Arguments

* **$1** (string): PNG to add

### 1canvadel

Remove a svg template

#### Arguments

* **$1** (string): Name of template to remove

### 1tokendel

Remove a png template

#### Arguments

* **$1** (string): Name of template to remove

