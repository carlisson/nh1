# Description for install via AppImage

APP_NAME="Zettlr"
APP_DESCRIPTION="$(_1text "Markdown editor for the 21st century")"
APP_CATEGORIES="Office;"
APP_MIME="text/x-markdown"

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
APP_PREFIX="Everdo-"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    curl -s 'https://github.com/Zettlr/Zettlr/releases' | tr '\n' ' ' | \
        sed 's/\(.*\)\(Zettlr\(.*\)x86_64\.AppImage\)\(.*\)/\2/'
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

    $AGpre curl -O -L https://github.com"$( \
       curl -s 'https://github.com/Zettlr/Zettlr/releases' | tr '\n' ' ' | \
       sed 's/\(.*\)\(\/Zettlr\/Zettlr\(.*\)x86_64\.AppImage\)\"\(.*\)/\2/'
    )"
}

