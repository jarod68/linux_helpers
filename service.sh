#!/bin/sh

# ##############################################################################################################################################################################
# Author:               Matthieu Holtz
# Year:                 2018
# Project:              
# Description:  	    Sample for a system V service / to install : run update-rc.d <filename> defaults and make it executable
#
# Licence:  	    	SPDX short identifier: MIT
#
#						Copyright © 2018, Matthieu Holtz <matthieu.holtz@gmail.com>
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

####### START OF CUSTOMIZATION AREA #######

### BEGIN INIT INFO
# Provides:          
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: 
# Description:       
### END INIT INFO

# The service name
SERVICE_NAME="MY_SERVICE_NAME"

# Here start a script or what should do this service
execute_start() {

	# Example with nohup:
	# nohup /usr/bin/python3 script.py > /dev/null 2>&1 &
}


####### END OF CUSTOMIZATION AREA #######



# File storing the PID of the service
SERVICE_PID_FILE="/tmp/$SERVICE_NAME".pid

# Print a nice colored status
# $1 the message
# $2 (optional parameter) if = 0 OK, NOK otherwise
print_status() {

	GREEN='\033[0;32m'
	RED='\033[0;31m'
	BLUE='\033[0;34m'
	NC='\033[0m' # No Color
	msg=""

	# Check the message
	if [ -n "$1" ]
		then
		msg=$1
	else
		return 1
	fi

	# Check the status
	if [ -n "$2" ]
		then
		if [ $2 -eq 0 ]
			then
			echo "$msg\t\t [${GREEN}OK${NC}]"
		else
			echo "$msg\t\t [${RED}NOK${NC}]"
		fi
	else 
		echo "${BLUE}$msg${NC}"
	fi
}

# Returns the current running state
is_running() {

	if [ -f "$SERVICE_PID_FILE" ]
		then
		PID=`cat $SERVICE_PID_FILE`
		return `kill -0 $PID`
	fi

	return 1
}

# Stops the process
process_stop() {

	PID_TO_KILL=`cat "$SERVICE_PID_FILE"`
	kill -9 "$PID_TO_KILL"
	rm "$SERVICE_PID_FILE"
}

# Starts the process and stores the PID
process_start() {

	execute_start
	echo $! > "$SERVICE_PID_FILE"
}

# Entry point
main() {
	case $1 in

		##################################
		#          Start handling        #
		##################################
		start)
is_running
if [ $? -ne 0 ]
	then
	print_status "Starting $SERVICE_NAME..." 0
	process_start
	exit 0
fi
print_status "$SERVICE_NAME already running..." 1
exit 1
;;

		##################################
		#          Stop handling         #
		##################################
		stop)
is_running
if [ $? -eq 0 ]
	then
	print_status "Stoping $SERVICE_NAME..." 0
	process_stop
	exit 0
fi
print_status "$SERVICE_NAME not running..." 1
exit 1
;;

		##################################
		#      Is running handling       #
		##################################
		status)
is_running

if [ $? -eq 0 ]
	then
	print_status "$SERVICE_NAME running..." 0
	exit 0
else
	print_status "$SERVICE_NAME not running..." 1
	exit 1
fi

;;

		##################################
		#        Restart handling        #
		##################################
		restart)
is_running
if [ $? -eq 0 ]
	then
	print_status "Stoping $SERVICE_NAME..." 0
	process_stop

fi

print_status "Starting $SERVICE_NAME..." 0
process_start
exit $?
;;

		##################################
		#         Other handling         #
		##################################
		*)
echo "Usage: $SERVICE_NAME {start|stop|status|restart}"
exit 1
;;
esac

}

# Call the main function!
main $@
