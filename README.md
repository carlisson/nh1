
Wiki (Portuguese): http://wiki.cordeis.com/norg/start

NH1 is a toolkit with various commands:

## Features

 * Autocomplete
 * Messages in languages: English, Portuguese.
 * **1angel**: a template system. Read more in https://codeberg.org/bardo/angel.
 * **1app**: "package manager" for AppImage, tarballs and git (without compile). Softwares are downloaded directly from its creator's website.
 * **1bot**: a bot to send messages. Supported: telegram, nextcloud talk.
 * **1backup**: tools to backup folders using any available compressor.
 * **1booklet**: makes a page sequence for printing in booklet mode. 1pdfbkl generates the booklet PDF ready to print.
 * **1canva**: using templates in SVG, 1canva ease cover/banner/etc creation.
 * **1cron**: simple pseudocron task scheduler
 * **1db**: simple key-value pseudo-database
 * **1draw**: simple drawlist manager.
 * **1network**: tools for network management.
 * **1roll**: simple dice roller (2d10, 3d6, 1d20-2)...
 * **1timer**: simple timer, including **1pomo** for pomodoro.
 * **1token**: using PNG frames, you can create simple RPG character tokens.
 * **1ui**: simples UI made to use whiptail, zenity and others (or none, if nothing was found!)
 * **1val**: validations: brazilian cpf, email and name.
 * **1pass**, **1diceware** and **1dw**: random password generators set to 70+ entropy bits.
 * **1translate**: help translation task, extracting texto to a .po and generating .mo
 
100+ commands 1-something. To get full list:

```
$ 1help
```

## Recipes

With 1app, you can install an application from AppImage, tar-ball or github, even in homespace! Supported apps:

 * Cherrytree
 * Draw.io
 * DWD12
 * Everdo
 * Firefox
 * Freetube
 * Funções ZZ
 * Haxe
 * Hazama
 * Inkscape
 * Kate
 * KeepassXC
 * Librewolf
 * Manuskript
 * Marktext
 * Mirage
 * Nextcloud (Desktop client)
 * Nuclear
 * OnlyOffice
 * OpenComic
 * Rancher Desktop
 * Retroshare
 * Sengi
 * shdoc
 * Shelf
 * Speek
 * The Desk
 * Ventoy
 * VS Codium
 * Whalebird
 * Zettlr

## Install

```
$ git clone https://codeberg.org/bardo/nh1
```

Or you can download and extract the latest release.

Run (load):

```
$ source nh1/nh1
```

Install (bash):

```
$ nh1/nh1 bashrc
```

or (running):

```
$ 1bashrc
```

(git only) Upgrade can be made with:

```
$ 1update
```

## Reference

* Documentation is available in [doc folder](doc/).
