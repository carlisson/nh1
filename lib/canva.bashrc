#!/bin/bash
# @file canva.bashrc
# @brief Tools to generate images from templates

# GLOBALS

_1CANVALOCAL="$_1UDATA/canvas"

# @description Generate partial menu
_nh1canva.menu() {
  echo "___ $(_1text "Canva Section") ___"
  echo "--- $(_1text "Create images from SVG templates")"
  _1menuitem W 1canva "$(_1text "List all templates or help for given template")"
  _1menuitem W 1canvagen "$(_1text "Generate image from template")" convert
  _1menuitem W 1canvaadd "$(_1text "Install or update a template")"
  _1menuitem W 1canvadel "$(_1text "Remove installed template")"
}

# @description Destroy all global variables created by this file
_nh1canva.clean() {
  unset _1CANVALOCAL
  unset -f 1canva 1canvagen 1canvaadd 1canvadel _nh1canva.complete
  unset -f _nh1canva.complete.canvaadd _nh1canva.customvars _nh1canva.info
  unset -f _nh1canva.thelp _nh1canva.clean _nh1canva.complete.list
  unset -f _nh1canva.menu _nh1canva.init
}

# @description Auto-completion
_nh1canva.complete() {
    _1verb "Configuring auto-completion for 1canva"    
    complete -F _nh1canva.complete.canvaadd 1canvaadd
    complete -F _nh1canva.complete.list 1canvagen
}

# @description Load variables defined by user
_nh1canva.customvars() {
    if [[ $NORG_CANVA_DIR ]]
    then
        _1CANVALOCAL="$NORG_CANVA_DIR"
    fi
}

# @description Information about custom vars
_nh1canva.info() {
    _1menuitem W NORG_CANVA_DIR "$(_1text "Path for 1canva internal templates.")"
}

# Alias-like

# @description Autocomplete for 1canvaadd
_nh1canva.complete.canvaadd() { _1compl 'svg' 0 0 0 0 ; }

# @description Autocomplete list of canva templates
_nh1canva.complete.list() {
  COMREPLY=()
    if [ "$COMP_CWORD" -eq 1 ]
    then
        COMPREPLY=($(_1list $_1CANVALOCAL "svg"))
    fi
}

# @description Configure your template path
_nh1canva.init() {
    if [ ! -d "$_1CANVALOCAL" ]
    then
        mkdir -p "$_1CANVALOCAL"
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