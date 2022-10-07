# Description for install Nextcloud client via AppImage

APP_NAME="OnlyOffice Desktop Edition"
APP_DESCRIPTION="$(_1text "OnlyOffice Desktop")"
APP_CATEGORIES="Office"
APP_MIME="application/vnd.oasis.opendocument.text;application/vnd.oasis.opendocument.text-template;application/msword;application/vnd.ms-word;application/x-doc;application/rtf;text/rtf;application/vnd.openxmlformats-officedocument.wordprocessingml.document;application/vnd.ms-word.document.macroEnabled.12;application/vnd.openxmlformats-officedocument.wordprocessingml.template;application/vnd.ms-word.template.macroEnabled.12;application/vnd.oasis.opendocument.spreadsheet;application/vnd.oasis.opendocument.spreadsheet-template;application/msexcel;application/vnd.ms-excel;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;application/vnd.ms-excel.sheet.macroEnabled.12;application/vnd.openxmlformats-officedocument.spreadsheetml.template;application/vnd.ms-excel.template.macroEnabled.12;application/vnd.ms-excel.sheet.binary.macroEnabled.12;text/csv;text/spreadsheet;application/csv;application/excel;application/x-excel;application/x-msexcel;application/x-ms-excel;application/vnd.oasis.opendocument.presentation;application/vnd.oasis.opendocument.presentation-template;application/mspowerpoint;application/vnd.ms-powerpoint;application/vnd.openxmlformats-officedocument.presentationml.presentation;application/vnd.ms-powerpoint.presentation.macroEnabled.12;application/vnd.openxmlformats-officedocument.presentationml.template;application/vnd.ms-powerpoint.template.macroEnabled.12;application/vnd.openxmlformats-officedocument.presentationml.slide;application/vnd.openxmlformats-officedocument.presentationml.slideshow;application/vnd.ms-powerpoint.slideshow.macroEnabled.12;"

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
APP_PREFIX="OnlyOffice-"

# To compile or do some procedures post-installation
function APP_POSTINST {
    return 1
}

# Code to get the newest version filename
function APP_VERSION {
    curl -s 'https://www.onlyoffice.com/pt/download-desktop.aspx?from=desktop' | tr '\n' ' ' | sed 's/\(.*\)\(download\/\(.*\)\/\(.*\)\.AppImage\)\(.*\)/OnlyOffice-\3.AppImage/'
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

    $AGpre curl -O -L $(curl -s 'https://www.onlyoffice.com/pt/download-desktop.aspx?from=desktop' | tr '\n' ' ' | sed 's/\(.*\)\(http\(.*\)\.AppImage\)\(.*\)/\2/')
    $AGpre mv DesktopEditors-x86_64.AppImage $(curl -s 'https://www.onlyoffice.com/pt/download-desktop.aspx?from=desktop' | tr '\n' ' ' | sed 's/\(.*\)\(download\/\(.*\)\/\(.*\)\.AppImage\)\(.*\)/OnlyOffice-\3.AppImage/')
}

