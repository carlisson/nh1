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

