# Description for install an app via AppImage
# If there is a file <app>.png, a .desktop file will be created.

# Application Name
APP_NAME="Ventoy"

# Application Description _1text is used for translation
APP_DESCRIPTION="$(_1text "A new Bootable USB Solution")"

# Application Cattegories, to use in .desktop file.
APP_CATEGORIES="System"

# Mime tipes for application (it will be in .desktop file)
# APP_MIME="application/vnd.oasis.opendocument.text;application/vnd.oasis.opendocument.text-template;application/msword;application/vnd.ms-word;application/x-doc;application/rtf;text/rtf;application/vnd.openxmlformats-officedocument.wordprocessingml.document;application/vnd.ms-word.document.macroEnabled.12;application/vnd.openxmlformats-officedocument.wordprocessingml.template;application/vnd.ms-word.template.macroEnabled.12;application/vnd.oasis.opendocument.spreadsheet;application/vnd.oasis.opendocument.spreadsheet-template;application/msexcel;application/vnd.ms-excel;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;application/vnd.ms-excel.sheet.macroEnabled.12;application/vnd.openxmlformats-officedocument.spreadsheetml.template;application/vnd.ms-excel.template.macroEnabled.12;application/vnd.ms-excel.sheet.binary.macroEnabled.12;text/csv;text/spreadsheet;application/csv;application/excel;application/x-excel;application/x-msexcel;application/x-ms-excel;application/vnd.oasis.opendocument.presentation;application/vnd.oasis.opendocument.presentation-template;application/mspowerpoint;application/vnd.ms-powerpoint;application/vnd.openxmlformats-officedocument.presentationml.presentation;application/vnd.ms-powerpoint.presentation.macroEnabled.12;application/vnd.openxmlformats-officedocument.presentationml.template;application/vnd.ms-powerpoint.template.macroEnabled.12;application/vnd.openxmlformats-officedocument.presentationml.slide;application/vnd.openxmlformats-officedocument.presentationml.slideshow;application/vnd.ms-powerpoint.slideshow.macroEnabled.12;"

# It can be:
#
# single: AppImage or simple binary file
# tarball: .tar.gz, with binaries (or sources)
# git: a git repository to clone
APP_TYPE="tarball"

# In case of tarball or git, BINARY is the executable file.
# For single, ignore it.
APP_BINARY="ventoy.nh1"

# Dependences. Specially useful to compilable apps
APP_DEPENDS=""

# Prefix for the filenames, to search installed old versions of app
APP_PREFIX="ventoy-"

# App suffix, file extension. Default for single is .AppImage
APP_SUFFIX="-tarball"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    # <download-page>: put the download page url
    # tr: this command removes all break line characters, for better working of sed (next)
    # sed: replace REGEX with your regular expression. In this way, there ara 3 groups:
    #   1: anything before newest version filename
    #   2: the goal
    #   3: anything after this
    #      Examples of REGEX:
    #                        REGEX=CherryTree\(.*\).AppImage
    #                        ALL 2nd GROUP=\(href=\"\([0-9\.]*\)\/\"\)
    #      This formula is fine for a lot of apps, but you can need to create a more
    #      soffisticated strategy in some situations.
    
    echo "ventoy-$(_nh1app.ghversion ventoy Ventoy)-tarball"
}

# Code to effectly do the download
function APP_GET {
    local AGpre AGver AGname AGdir AGini AGpath
    
    # This adjust allow 1app to install this app locally or globally.
    if [ $# -eq 1 ]
    then
        AGpre="_1sudo "
    else
        AGpre=""
    fi

    AGini=$(mktemp)
    AGpath=$(pwd)

    AGver="$(_nh1app.ghversion ventoy Ventoy)"
    AGdir="ventoy-$AGver"
    AGname="$AGdir-linux.tar.gz"
    $AGpre curl -O -L "https://github.com/ventoy/Ventoy/releases/download/v$AGver/$AGname"
    $AGpre tar -zxf "$AGname"
    $AGpre mv "$AGdir" "ventoy-$AGver-tarball"
    $AGpre rm "$AGname"

    echo "#!/bin/bash" >> "$AGini"
    echo "cd $AGpath/ventoy-$AGver-tarball" >> "$AGini"
    echo "./VentoyGUI.x86_64" >> "$AGini"
    $AGpre cp "$AGini" "ventoy-$AGver-tarball/ventoy.nh1"
    $AGpre chmod a+x "ventoy-$AGver-tarball/ventoy.nh1"
    rm "$AGini"

}

