# Description for install an app via AppImage
# If there is a file <app>.png, a .desktop file will be created.

# Application Name
APP_NAME="2hot"

# Application Description _1text is used for translation
APP_DESCRIPTION="$(_1text "Static linktree and hotsite generator")"

# URL to website of the project
APP_SITE="https://codeberg.org/bardo/2hot"

# Application Cattegories, to use in .desktop file.
APP_CATEGORIES="System;"

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
APP_BINARY="2hot.sh"

# Dependences. Specially useful to compilable apps
APP_DEPENDS="git"

# Prefix for the filenames, to search installed old versions of app
APP_PREFIX="2hot"

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
    echo "2hot-git"
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

    if [ -d "2hot-git" ]
    then
        cd 2hot-git
        $AGpre git pull
    else
        $AGpre git clone --recursive https://codeberg.org/bardo/2hot
        $AGpre mv 2hot 2hot-git
    fi
}

