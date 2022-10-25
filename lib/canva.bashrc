#!/bin/bash
# @file canva.bashrc
# @brief Tools to generate images from templates

# GLOBALS

_1CANVALOCAL="$_1UDATA/canvas"
_1TOKENSIZE=500

# @description Generate partial menu
_nh1canva.menu() {
  echo "___ $(_1text "Canva Section") ___"
  echo "--- $(_1text "Create images from SVG templates")"
  _1menuitem W 1canva "$(_1text "List all templates or help for given template")"
  _1menuitem W 1canvagen "$(_1text "Generate image from template")" convert
  _1menuitem W 1canvaadd "$(_1text "Install or update a template")"
  _1menuitem W 1canvadel "$(_1text "Remove installed template")"
  _1menuitem X 1token "$(_1text "List all templates or help for given template")"
  _1menuitem X 1tokengen "$(_1text "Generates image from template")" convert
  _1menuitem X 1tokenadd "$(_1text "Install or update a template")"
  _1menuitem W 1tokendel "$(_1text "Remove installed template")"
}

# @description Destroy all global variables created by this file
_nh1canva.clean() {
  unset _1CANVALOCAL
  unset -f 1canva 1canvagen 1canvaadd 1canvadel _nh1canva.complete
  unset -f _nh1canva.complete.canvaadd _nh1canva.customvars _nh1canva.info
  unset -f _nh1canva.thelp _nh1canva.clean _nh1canva.complete.list
  unset -f _nh1canva.menu _nh1canva.init 1token 1tokenadd 1tokengen
  unset -f 1tokendel
}

# @description Auto-completion
_nh1canva.complete() {
    _1verb "Configuring auto-completion for 1canva"    
    complete -F _nh1canva.complete.canvaadd 1canvaadd
    complete -F _nh1canva.complete.list 1canvagen
    complete -F _nh1canva.complete.tokenadd 1tokenadd
    complete -F _nh1canva.complete.listp 1tokengen
}

# @description Load variables defined by user
_nh1canva.customvars() {
    if [[ $NORG_CANVA_DIR ]]
    then
        _1CANVALOCAL="$NORG_CANVA_DIR"
    fi
    if [[ $NORG_TOKEN_SIZE ]]
    then
        _1TOKENSIZE=$((NORG_TOKEN_SIZE*1))
    fi
}

# @description Information about custom vars
_nh1canva.info() {
    _1menuitem W NORG_CANVA_DIR "$(_1text "Path for 1canva and 1token internal templates.")"
    _1menuitem W NORG_TOKEN_SIZE "$(_1text "Size for 1token images (it will be generated as squares sizexsize).")"
}

# Alias-like

# @description Autocomplete for 1canvaadd
_nh1canva.complete.canvaadd() { _1compl 'svg' 0 0 0 0 ; }
_nh1canva.complete.tokenadd() { _1compl 'png' 0 0 0 0 ; }

# @description Autocomplete list of canva templates
_nh1canva.complete.list() {
  COMREPLY=()
    if [ "$COMP_CWORD" -eq 1 ]
    then
        COMPREPLY=($(_1list $_1CANVALOCAL "svg"))
    fi
}

# @description Autocomplete list of canva/token templates
_nh1canva.complete.listp() {
  COMREPLY=()
    if [ "$COMP_CWORD" -eq 1 ]
    then
        COMPREPLY=($(_1list $_1CANVALOCAL "png"))
    fi
}

# @description Configure your template path
_nh1canva.init() {
    if [ ! -d "$_1CANVALOCAL" ]
    then
        mkdir -p "$_1CANVALOCAL"
        cp "$_1LIB/templates/token-template.png" "$_1CANVALOCAL/wheel.png"
        cp "$_1LIB/templates/canva-template.svg" "$_1CANVALOCAL/hello.svg"
    fi
}

# @description Show 1canva help for saved template
# @arg $1 string Template name
_nh1canva.thelp() {
    local _LANG _OUT
    _LANG="$(echo "$LANG" | sed 's/\(.*\)\.\(.*\)/\1/')"    
    _1verb "$(printf "$(_1text "Help for template: %s.")" "$1")"
    if ! grep "1canva-$_LANG-ini" "$_1CANVALOCAL/$1.svg" > /dev/null
    then
        _LANG="en"
    fi
    
    cat "$_1CANVALOCAL/$1.svg" | tr '\n' ' ' | sed "s/\(.*\)1canva-$_LANG-ini\(.*\)1canva-$_LANG-end\(.*\)/\2/"
    echo
}

# @description List all installed templates
1canva() {
    local _clist _slist
    _nh1canva.init
    
    #_clist=($(_nh1canva.list))
    _clist=($(_1list $_1CANVALOCAL "svg"))
    _slist="${_clist[@]}"
    
    printf "$(_1text "Templates: %s.")\n" "$_slist"
    
    if [ ${#_clist[@]} -eq 0 ]
    then
        _1text "No template found."
        echo
    fi
}

# @description List all installed templates
1token() {
    local _clist _slist
    _nh1canva.init
    
    #_clist=($(_nh1canva.list))
    _clist=($(_1list $_1CANVALOCAL "png"))
    _slist="${_clist[@]}"
    
    printf "$(_1text "Templates: %s.")\n" "$_slist"
    
    if [ ${#_clist[@]} -eq 0 ]
    then
        _1text "No template found."
        echo
    fi
}

# @description List help for template or apply it
# @arg $1 string template name
# @arg $2 string output file (.jpg, .png or other)
# @arg $3 string substitutions in key=value syntax
1canvagen() {
    local iter tempf tempi tempib
    subst=""
    case $# in
        0)
            _1text "Usages:"
            echo "  1canvagen <template>"
            echo "  1canvagen <template> <outputfile> [key=value]*"
            ;;
        1|2)        
            _nh1canva.thelp $1
            ;;
        *)
            template="$1"
            fileout="$2"
            shift 2
            tempf=$(mktemp -u)
            
            tempi=$(mktemp -u).svg
            
            cp "$_1CANVALOCAL/$template.svg" $tempi
            echo "#!/bin/bash" > $tempf
            echo "pushd" $(dirname $tempi) "> /dev/null" >> $tempf
            
            tempib=$(basename $tempi)
            for iter in "$@"
            do
                echo $iter | sed "s/\(.*\)=\(.*\)/sed -i 's\/-=\\\[\1\\\]=-\/\2\/g' $tempib/" >> $tempf
                # $(echo $(echo $iter | sed 's/\(.*\)=\(.*\)/sed -i "s\/-=[\1]=-\/\2\/g"/') $tempf)
            done

            echo "popd > /dev/null" >> $tempf

            bash $tempf
            rm $tempf
            
            convert $tempi $fileout
            rm $tempi
            ;;
    esac
}

# @description List help for template or apply it
# @arg $1 string template name
# @arg $2 string output file (.jpg, .png or other)
# @arg $3 string input file to apply token template
1tokengen() {
    local template filein fileout temp half hminor
    case $# in
        3)
            template="$1"
            filein="$2"
            fileout="$3"
            temp="$(mktemp -u)"
            half=$((_1TOKENSIZE/2))
            hminor=$((half-30))            

            convert "$_1CANVALOCAL/$template.png" -resize "$_1TOKENSIZE"x"$_1TOKENSIZE" "$temp.t.png"
            convert -size "$_1TOKENSIZE"x"$_1TOKENSIZE" xc: -draw "circle $half,$half $hminor,5" -negate "$temp.m.png"
            
            convert "$filein" -resize "$_1TOKENSIZE"x"$_1TOKENSIZE" "$temp.x.png"
            convert "$temp.x.png" "$temp.m.png" -alpha off -compose CopyOpacity -composite "$temp.i.png"
            convert "$temp.i.png" "$temp.t.png" -flip -background none -mosaic -flip "$fileout"
            rm $temp.?.png
            ;;
        *)
            _1text "Usages:"
            echo "  1tokengen <template> <input-image-file> <outputfile>"
            ;;
    esac
}

# @description Add a svg template
# @arg $1 string SVG to add
1canvaadd() {
    local ni no
    case $# in
        1)
            ni="$1"
            no="$(basename $1)"
            ;;
        2)
            ni="$1"
            no="$2"
            if [ "${no: -4}" != ".svg" ]
            then
                no="$no.svg"
            fi
            ;;
        *)
            printf "$(_1text "Usage: %s.")\n" "1canvaadd <svg-initial> (<name-of-template>)"
            return
            ;;
    esac
    cp "$ni" "$_1CANVALOCAL/$no"
}

# @description Add a png template
# @arg $1 string PNG to add
1tokenadd() {
    local ni no
    case $# in
        1)
            ni="$1"
            no="$(basename $1)"
            ;;
        2)
            ni="$1"
            no="$2"
            if [ "${no: -4}" != ".png" ]
            then
                no="$no.png"
            fi
            ;;
        *)
            printf "$(_1text "Usage: %s.")\n" "1tokenadd <png-initial> (<name-of-template>)"
            return
            ;;
    esac
    cp "$ni" "$_1CANVALOCAL/$no"
}

# @description Remove a svg template
# @arg $1 string Name of template to remove
1canvadel() {
    if [ -f "$_1CANVALOCAL/$1.svg" ]
    then
        rm "$_1CANVALOCAL/$1.svg"
    else
        printf "$(_1text "Template %s not found.")\n" $1
    fi
}

# @description Remove a png template
# @arg $1 string Name of template to remove
1tokendel() {
    if [ -f "$_1CANVALOCAL/$1.png" ]
    then
        rm "$_1CANVALOCAL/$1.png"
    else
        printf "$(_1text "Template %s not found.")\n" $1
    fi
}