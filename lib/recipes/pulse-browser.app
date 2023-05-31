# Description for install an app via AppImage
# If there is a file <app>.png, a .desktop file will be created.

# Application Name
APP_NAME="Pulse Browser"

# Application Description _1text is used for translation
APP_DESCRIPTION="$(_1text "Pulse web browser")"

# Application Cattegories, to use in .desktop file.
APP_CATEGORIES="Network;WebBrowser"

# Mime tipes for application (it will be in .desktop file)
APP_MIME="text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;"

# It can be:
#
# single: AppImage or simple binary file
# tarball: .tar.gz, with binaries (or sources)
# git: a git repository to clone
APP_TYPE="tarball"

# In case of tarball or git, BINARY is the executable file.
# For single, ignore it.
APP_BINARY="pulse-browser/pulse-browser"

# Dependences. Specially useful to compilable apps
APP_DEPENDS="tar bzip2"

# Prefix for the filenames, to search installed old versions of app
APP_PREFIX="pulse-browser-"

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
    echo "pulse-browser-$(curl -sL https://github.com/pulse-browser/browser/releases/latest | grep releases/tag | head -n 1 | sed "s/\(.*\)releases\/tag\/\([^\"]*\)\(.*\)/\2/")-tarball"
}

# Code to effectly do the download AKI
function APP_GET {
    local AGpre AGver AGfile
    
    # This adjust allow 1app to install this app locally or globally.
    if [ $# -eq 1 ]
    then
        AGpre="_1sudo "
    else
        AGpre=""
    fi

    if [ -d "pulse-browser" ]
    then
        rm -rf "pulse-browser"
    fi

    AGfile="pulse-browser.linux.tar.bz2"
    AGver="$(curl -sL https://github.com/pulse-browser/browser/releases/latest | grep releases/tag | head -n 1 | sed "s/\(.*\)releases\/tag\/\([^\"]*\)\(.*\)/\2/")"
    $AGpre curl -O -L "https://github.com/pulse-browser/browser/releases/download/$AGver/$AGfile"
    $AGpre mkdir "pulse-browser-$AGver-tarball"
    $AGpre tar -jxf "$AGfile" -C "pulse-browser-$AGver-tarball"
    $AGpre rm "$AGfile"
}

