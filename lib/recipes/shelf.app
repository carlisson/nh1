# Description for install via AppImage

APP_NAME="Shelf"
APP_DESCRIPTION="$(_1text "Document viewer for different formats")"
APP_CATEGORIES="Qt;KDE;Graphics;Office;Viewer;"
APP_MIME="application/x-pdf;application/pdf;application/x-gzpdf;application/x-bzpdf;application/x-wwf;"

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
APP_PREFIX="shelf-v"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    local AVpre
    AVpre=$(curl -s 'https://download.kde.org/stable/maui/shelf/' | tr '\n' ' ' | \
    sed 's/\(.*\)href=\"\([0-9\.]*\)\/\"\(.*\)/\2/')
    echo "shelf-v$AVpre-stable-amd64.AppImage"
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
    
    $AGpre curl -O -L "https://download.kde.org/stable/maui/shelf/$( \
        curl -s 'https://download.kde.org/stable/maui/shelf/' | \
        tr '\n' ' ' | sed 's/\(.*\)href=\"\([0-9\.]*\)\/\"\(.*\)/\2/' \
    )/shelf-v$( \
        curl -s 'https://download.kde.org/stable/maui/shelf/' | \
        tr '\n' ' ' | sed 's/\(.*\)href=\"\([0-9\.]*\)\/\"\(.*\)/\2/' \
    )-stable-amd64.AppImage"
}

