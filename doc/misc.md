# misc.bashrc

Miscelania

## Overview

Generate partial menu

## Index

* [_nh1misc.menu](#_nh1miscmenu)
* [_nh1misc.clean](#_nh1miscclean)
* [_nh1misc.complete](#_nh1misccomplete)
* [_nh1misc.customvars](#_nh1misccustomvars)
* [_nh1misc.info](#_nh1miscinfo)
* [_nh1misc.init](#_nh1miscinit)
* [_nh1misc.complete.from_pdf](#_nh1misccompletefrom_pdf)
* [1power](#1power)
* [1du](#1du)
* [1pass](#1pass)
* [1diceware](#1diceware)
* [1color](#1color)
* [1pdfopt](#1pdfopt)
* [1ajoin](#1ajoin)
* [1timer](#1timer)
* [1pomo](#1pomo)
* [1rr30](#1rr30)
* [1escape](#1escape)
* [1tip](#1tip)
* [1spchar](#1spchar)
* [1booklet](#1booklet)
* [1pdfbkl](#1pdfbkl)

### _nh1misc.menu

Generate partial menu

### _nh1misc.clean

Destroy all global variables created by this file

### _nh1misc.complete

Autocompletion

### _nh1misc.customvars

Load variables defined by user

### _nh1misc.info

Information about custom vars

### _nh1misc.init

Initialization

### _nh1misc.complete.from_pdf

Completion for functions with pdf input

### 1power

Print percentage for battery charge

### 1du

Disk usage

### 1pass

Random password generator. 12chars=72bits entropy

### 1diceware

Random diceware password generator. 6words=77bits entropy

### 1color

Random color generator

### 1pdfopt

Compress PDF file

#### Arguments

* **$1** (string): PDF input file
* **$2** (string): PDF output file (optional)

### 1ajoin

Join an array, using first param as delimiter

#### Arguments

* **$1** (string): delimiter, character
* **$2** (string): other values to join

### 1timer

Countdown timer

#### Arguments

* **$1** (int): color for timer (0 to 7)
* **$2** (string): title for timer
* **$3** (int): seconds (optional)
* **$4** (int): minutes (optional)
* **$5** (int): hours to countdown (optional)

### 1pomo

Create a Pomodore in shell

#### Arguments

* **$1** (int): minutes to pomodoro (default 25)

#### See also

* [1timer](#1timer)

### 1rr30

Timer to help to reset a router, using the 30-30-30 method

#### See also

* [1timer](#1timer)

### 1escape

Rename a file or directory, removing special chars

#### Arguments

* **$1** (string): file

### 1tip

Shows a random tip to the user

#### Arguments

* **$1** (string): Group of tip ("list" to list all groups)

#### Exit codes

* **0**: It works
* **1**: Tip file not found

### 1spchar

Returns a random special character

#### Output on stdout

* A special char

### 1booklet

Generates a seq of pages to make booklet (4 pages i 2-sides paper)

#### Arguments

* **$1** (int): Number of pages
* **$2** (int): Number of the "blank" page. Default: last
* **$3** (string): Mode single or double. Default: single. Any-arg: double.

#### Output on stdout

* Pages sequence

#### See also

* [1pdfbkl](#1pdfbkl)

### 1pdfbkl

Make a booklet from a PDF file

#### Arguments

* **$1** (string): PDF input file
* **$2** (string): single (empty) or double (not empty)

#### See also

* [1booklet](#1booklet)

