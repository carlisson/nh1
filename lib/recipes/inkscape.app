# Description for install via AppImage

APP_NAME="Inkscape"
APP_DESCRIPTION="Vector graphics editor"
APP_CATEGORIES="Graphics;"
APP_MIME="image/svg+xml"
APP_SITE="https://inkscape.org/"

# It can be:
#
# single: AppImage or simple binary file
# tarball: .tar.gz, with binaries (or sources)
# git: a git repository to clone
APP_TYPE="single"

# In case of tarball or git, BINARY is the executable file.
# For single, ignore it.
APP_BINARY=""

# Dependences. Specially useful to compilable apps
APP_DEPENDS=""

# Prefix for the filenames
APP_PREFIX="Inkscape-"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    curl -sL https://inkscape.org$( \
            curl -sL https://inkscape.org/release/ | \
            tr '\n' ' ' | \
            sed 's/\(.*\)\(\/release\(.*\)gnulinux\)\(.*\)/\2/' | \
            sed 's/gnulinux/platforms/') | \
        tr '\n' ' ' | \
        sed 's/\(.*\)\(Inkscape\(.*\)AppImage\)\(.*\)/\2/'
}

# Code to effectly do the download
function APP_GET {
    local AGpre
    
    if [ $# -eq 1 ]
    then
        AGpre="_1sudo "
    else
        AGpre=""
    fi

    $AGpre curl -O -L https://inkscape.org$(
    curl -sL https://inkscape.org$( \
            curl -sL https://inkscape.org/release/ | \
            tr '\n' ' ' | \
            sed 's/\(.*\)\(\/release\(.*\)gnulinux\)\(.*\)/\2/' | \
            sed 's/gnulinux/platforms/') | \
        tr '\n' ' ' | \
        sed 's/\(.*\)\(\/gallery\(.*\)AppImage\)\(.*\)/\2/'
    )

}

