#!/bin/bash

XmlFolder=$HOME"/CloudStation.C3PO/Bootstrap/BeXs/"
ScriptFolder=$HOME"/CloudStation.C3PO/Bootstrap/_Templates/xml2json_terminal/"
ERROR=" "

# Filenames to exclude
ignore=( "*-template.xml" "*-BMS*.xml" )

cd $XmlFolder

availableXML=($(find . -name "*.xml" ! -name "*-template.xml" ! -name "*-BMS*.xml" -maxdepth 1))
availableXMLlength=${#availableXML[@]}


# show available files as menu
function MENU {
    echo "Select XML(s) to parse:"
    for i in ${!availableXML[@]}; do
        printf '[%s] %2d) %s \n' "${choices[i]:- }" "$(( i+1 ))" "${availableXML[i]}"
    done
    echo "$ERROR"
}


# function to process selected files
function ACTIONS {
    echo " "
    for (( i = 0; i < ${availableXMLlength}; i++ )); do
        if [[ ${choices[i]} ]]; then
            currentXmlVariable=${availableXML[i]}
            eval currentXML='$'$currentXmlVariable
            $ScriptFolder"xml2json.py" -t xml2json -o $XmlFolder$currentXML"-json.jade" $XmlFolder$currentXML".xml" --strip_text
            echo $currentXML".xml parsed to" $currentXML"-json.jade"
        fi
    done
    echo " "
}


# clear screen for menu
clear


# menu loop - read chosen menu options

# read -e = "Obtain the line"
# read -p = "Display prompt, without a trailing newline, before attempting to read any input"
# read -n = "Return nchars characters rather than waiting for a complete line of input"

while MENU && read -e -p "Select the desired options by number (type number again to uncheck): " SELECTION && [[ -n "$SELECTION" ]]; do
    clear
    # if input is a number and (1 <= input <= availableXML.length)
    if [[ "$SELECTION" == *[[:digit:]]* && $SELECTION -ge 1 && $SELECTION -le ${availableXMLlength} ]]; then
        # reduce input by one to use it as array key
        (( SELECTION-- ))
        if [[ "${choices[SELECTION]}" == "+" ]]; then
            choices[SELECTION]=""
        else
            choices[SELECTION]="+"
        fi
        ERROR=" "
    else
        ERROR="Invalid option: $SELECTION"
    fi
done

# process selected files
ACTIONS