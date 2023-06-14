# Description for install via AppImage

APP_NAME="Diagrams"
APP_DESCRIPTION="$(_1text "Security-first diagramming for teams")"
APP_CATEGORIES="Graphics;"
APP_SITE="https://github.com/jgraph/drawio-desktop"

# APP_MIME="image/svg+xml"

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
APP_PREFIX="drawio-"

# App suffix, file extension. Default for single is .AppImage
APP_SUFFIX=".AppImage"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    echo drawio-x86_64-$(curl -sL https://github.com/jgraph/drawio-desktop/releases | \
        grep AppImage | \
        sed 's/\(.*\)\/download\/v\([0-9\.]*\)\/draw\(.*\)/\2/g' | \
        head -n 1).AppImage
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

    AGver=$(APP_VERSION | sed 's/drawio-x86_64-\(.*\).AppImage/\1/')
    $AGpre curl -O -L https://github.com/jgraph/drawio-desktop/releases/download/v$AGver/drawio-x86_64-$AGver.AppImage
}

