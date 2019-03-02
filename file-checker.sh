#!/bin/bash

# ##############################################################################################################################################################################
# Author:               Matthieu Holtz
# Year:                 2019
# Project:      		NONE
# Description:  		Find duplicated files on the filesystem with option to exlude some system directories
#
# Licence:  	    	SPDX short identifier: MIT
#
#						Copyright © 2019, Matthieu Holtz <matthieu.holtz@gmail.com>
#
#						Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files 
#                       (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, 
#                       sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#						The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#						THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
#                       OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
#                       DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
#                       OTHER DEALINGS IN THE SOFTWARE.
# ##############################################################################################################################################################################


EXCLUDE_LIST=(./usr ./etc ./sys ./etc ./proc ./var ./lib ./bin)

SEARCH_PATH="/"
EXCLUDE=""
OUTPUT_PATH=""
VERBOSE=1
DELETE=0
RESULT=""

RED='\033[0;31m'
NC='\033[0m' # No Color

# Debug line
debug ()
{
	if [ $VERBOSE == 0 ] ;then
		echo "$1"
	fi
}

# Print help message
help ()
{
	echo "Script finding duplicated file based on their MD5 sum"
	echo ""
	echo "Options :"
	echo "       -h | --help      : display this help message"
	echo "       -v | --verbose   : display debug messages"
	echo "       -d | --directory : Specify the directory to search in, if not specified / is used"
	echo "       -i | --ignoresys : Ignore system directories like /usr /etc /sys /etc /proc /var /lib /bin"
	echo "       -o | --output : Specify output filepath"
        echo "       -c | --clean : delete the duplicated filed that where found"
	echo ""
}

# Delete all the files that matches the $1 (hash) and $2 (path) from the global result
deleteDuplicates ()
{
        while read -r item; do
                HASH1=`echo "$item" | cut -d ' ' -f1`
                PATH1=`echo "$item" | cut -d ' ' -f3`
		if [ "$1" == "$HASH1"  ] ;then
			if [ "$2" != "$PATH1"  ] ;then
			  echo -e "${RED}Deleting $HASH1 $PATH1${NC}"
			  rm "$PATH1"
			fi
		fi
        done <<< "$RESULT"
}

# Process the clean, deletes all the duplicates and keeps the 1st only
clean ()
{
	PREVIOUS=""
	while read -r line; do
		HASHz=`echo "$line" | cut -d ' ' -f1`
                PATHz=`echo "$line" | cut -d ' ' -f3`

		if [ "$PREVIOUS" != "$HASHz" ] ;then
			deleteDuplicates "$HASHz" "$PATHz"
			PREVIOUS=$HASHz
		fi
	done <<< "$RESULT"
}

# Process the duplicates finding algorithm
search ()
{
	cd "$SEARCH_PATH"

	if [ -n "$EXCLUDE" ] ;then
		EXCLUDE_PRINT=`echo "$EXCLUDE" | sed 's/-path//g' | sed 's/-prune -o //g'`
		debug "EXCLUDING $EXCLUDE_PRINT"
	fi

	debug "SEARCHING in $SEARCH_PATH"

	RESULT=`time find . $EXCLUDE ! -empty -type f -exec md5sum {} + 2>/dev/null | sort | uniq -w32 -dD`

	if [ -n "$OUTPUT_PATH" ] ;then
		debug "PRINTING in $OUTPUT_PATH"
		echo "$RESULT" > "$OUTPUT_PATH"
	fi

	echo "--"
	echo "$RESULT"
	echo "--"

        if [ $DELETE == 1 ] ;then
                clean
        fi

}

# Entry point, process the arguments
main ()
{
	while [ $# -ne 0 ]; do
		case "$1" in
			-v|--verbose)
				VERBOSE=0
				shift
				;;
			-i|--ignoresys)
				for i in "${EXCLUDE_LIST[@]}" ;do
					EXCLUDE="$EXCLUDE""-path $i -prune -o "
				done
				shift
				;;
			-d|--directory)
				SEARCH_PATH="$2"
				shift 2
				;;
			-o|--output)
				OUTPUT_PATH="$2"
				shift 2
				;;
			-h|--help)
				help 
				exit 0
				;;
		        -c|--clean)
                                DELETE=1
                                shift
                                ;;

			*)
				echo "Unkown argument $1"
				echo ""
				help
				exit 6
			;;
		esac
	done

	search
}

# => Main entry point
main "$@"
