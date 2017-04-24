#!/bin/bash
#File: snatch.sh
#Description: Grab every file in a provided list and store in a specified location.
#Written by: dojobel
#Created: 24/04/2017
#Modified: 24/04/2017
#Version: 1.0

#Instructions:
# Populate a text file with one FULL hyperlink per line and specify the path to that file below.
# Accepted protocols at this stage are HTTP, HTTPS and FTP.
# For example, these are valid lines:
# ftp://www.a.website.com/file.txt
# http://www.a.website.com/file.txt


#//User configuration//
#Snatch_Source: path to a text file with each link to download on a separate line.
Snatch_Source=source.txt

#Snatch_Destination: path to a folder where Snatch should download your files to (no trailing slash)
Snatch_Destination=~/snatch

#Snatch_DerivePath: whether or not to use a standard path of <Snatch_Destination>/<Site URL>/<Path to File>. e.g. ~/Snatch/google.com/folder1/folder2/file.txt
#If set to false, this will place all files directly in the root.
#Accepted Values: true | false
Snatch_DerivePath=true

#Snatch_EnableLog: Whether or not to log output
#Accepted Values: true | false
Snatch_EnableLog=true

#Snatch_TimestampLog: Whether or not to name logs with timestamp (essentially rotates the log with each run)
#Accepted Values: true | false
Snatch_TimestampLog=true

#Snatch_LogDirectory: Folder where logs should be written to
Snatch_LogDirectory=/var/log/snatch

#Snatch_CalculateSHA256: Calculate the SHA-256 checksum of each file after all are completed. Probably might slow things down if this is on.
#Accepted Values: true | false
Snatch_CalculateSHA256=true

#Snatch_ForceRoot: Ensure the script is running as root, can be disabled for the paranoid. 
#NOTE: If you choose to disable this, the script will forcibly terminate for trivial things like being unable to create folders or ACLs being incorrect.
#Accepted Values: true | false
Snatch_ForceRoot=true

#//End user configuration//


#Warning: It's a pretty basic script, but changing anything after here may produce "unintended results".


#//System Configuration//
Snatch_Version=1.0
Snatch_WorkingDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
Snatch_LogTimestamp="$(date "+%Y.%m.%d-%H.%M.%S")"
Snatch_LogFile="$Snatch_LogTimestamp"_snatch.log
Snatch_Log="$Snatch_LogDirectory"/"$Snatch_LogFile"
Snatch_LogInitialised=false
#//End System Configuration//

#//Begin core functions//
function Snatch_LogWrite {
    if [ $Snatch_EnableLog == true ]; then
        if [ $Snatch_LogInitialised == true]; then
            echo "$1">>$Snatch_Log
        fi
    fi
}
function Snatch_LogTee {
    echo "$1"
    if [ "$Snatch_EnableLog" == true ]; then
        if [ "$Snatch_LogInitialised" == true ]; then
            echo "$1">>$Snatch_Log
        fi
    fi
}
#//End core functions//
echo "Running Pre-flight checks, please wait..."
if [ "$Snatch_ForceRoot" == true ]; then
    if [[ $(id -u) != 0 ]]; then
        echo "   -ERROR: This script must be run as root"
        exit 1
    fi
fi
if [ ! -f "$Snatch_Source" ]; then
    echo "   -ERROR: Unable to locate source file $Snatch_Source"
    exit 1
fi
if [ -z "$(which wget)" ]; then
    echo "    -ERROR: Unable to locate wget executable. Please ensure it is installed."
    exit 1
fi
if [ -z "$(which shasum)" ]; then
    echo "    -ERROR: Unable to locate shasum executable. Please ensure it is installed."
    exit 1
fi
if [ ! -d $Snatch_LogDirectory ]; then
    mkdir "$Snatch_LogDirectory">>/dev/null
    if [ ! -d $Snatch_LogDirectory ]; then
        echo "   -ERROR: Unable to create the log folder at $Snatch_LogDirectory"
        exit 1
    fi
fi
if [ ! -f "$Snatch_Log" ]; then
    touch $Snatch_Log
fi
if [ ! -f "$Snatch_Log" ]; then
    echo "   -ERROR: Failed to create log file. Ensure you have write permissions to $Snatch_LogDir"
    exit 1
fi
Snatch_LogInitialised=true
echo "Pre-flight checks completed successfully."
echo
#//End Pre-flight check//

#//Begin Initialisation//#
Snatch_LogTee "Snatch v$Snatch_Version"
Snatch_LogTee
while read URL; do
    unset Snatch_CurrentFile
    Snatch_LogTee "Downloading: $URL"
    Snatch_CurrentFileName=$(echo "$URL" | rev | cut -d '/' -f 1 | rev)
    Snatch_DerivedPath=$(echo "$URL" | cut -d ':' -f 2 | cut -c 3- | rev | grep -o "/.*" | cut -c 2- | rev)
    if [ "$Snatch_DerivePath" == true ]; then
        Snatch_LogTee "Saving as: $Snatch_Destination/$Snatch_DerivedPath/$Snatch_CurrentFileName"
        if [ ! -d "$Snatch_Destination/$Snatch_DerivedPath" ]; then
            mkdir -p "$Snatch_Destination/$Snatch_DerivedPath"
        fi
        wget --show-progress -a "$Snatch_Log" -N  -c -P "$Snatch_Destination/$Snatch_DerivedPath/" "$URL"
        if [ "$Snatch_CalculateSHA256" == true ]; then
            Snatch_LogTee "Generating SHA256 Checksum: $Snatch_Destination/$Snatch_DerivedPath/$Snatch_CurrentFileName.checksum"
            shasum -a 256 "$Snatch_Destination/$Snatch_DerivedPath/$Snatch_CurrentFileName">"$Snatch_Destination/$Snatch_DerivedPath/$Snatch_CurrentFileName.checksum"
        fi
    else
        Snatch_LogTee "Saving as: $Snatch_Destination/$Snatch_CurrentFileName"
        if [ ! -d "$Snatch_Destination" ]; then
            mkdir -p "$Snatch_Destination"
        fi
        wget --show-progress -a "$Snatch_Log" -N -c -P "$Snatch_Destination/" "$URL"
        if [ "$Snatch_CalculateSHA256" == true ]; then
            Snatch_LogTee "Generating SHA256 Checksum: $Snatch_Destination/$Snatch_CurrentFileName.checksum"
            shasum -a 256 "$Snatch_Destination/$Snatch_CurrentFileName">"$Snatch_Destination/$Snatch_CurrentFileName.checksum"
        fi
    fi
    Snatch_LogTee
done <$Snatch_Source
Snatch_LogTee
Snatch_LogTee "Script Completed."