# Description for install an app via AppImage
# If there is a file <app>.png, a .desktop file will be created.

# Application Name
APP_NAME="dwd12"

# Application Description _1text is used for translation
APP_DESCRIPTION="$(_1text "Diceware D12 password generator")"

# Application Cattegories, to use in .desktop file.
APP_CATEGORIES="System;"

# URL to website of the project
APP_SITE="https://codeberg.org/bardo/dwd12"

# Mime tipes for application (it will be in .desktop file)
#APP_MIME="text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;"

# It can be:
#
# single: AppImage or simple binary file
# tarball: .tar.gz, with binaries (or sources)
# git: a git repository to clone
APP_TYPE="git"

# In case of tarball or git, BINARY is the executable file.
# For single, ignore it.
APP_BINARY="dwd12.sh"

# Dependences. Specially useful to compilable apps
APP_DEPENDS="git"

# Prefix for the filenames, to search installed old versions of app
APP_PREFIX="dwd12"

# App suffix, file extension. Default for single is .AppImage
APP_SUFFIX=""

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
    echo "dwd12-git"
}

# Code to effectly do the download AKI
function APP_GET {
    local AGpre AGname AGlang AGver
    
    # This adjust allow 1app to install this app locally or globally.
    if [ $# -eq 1 ]
    then
        AGpre="_1sudo "
    else
        AGpre=""
    fi

    if [ -d "dwd12-git" ]
    then
        cd dwd12-git
        $AGpre git pull
    else
        $AGpre git clone --recursive https://codeberg.org/bardo/dwd12
        $AGpre mv dwd12 dwd12-git
    fi

    cd dwd12-git
    if [ $# -eq 1 ]
    then
        _1sudo make install
    else
        make user-sets
    fi
}

