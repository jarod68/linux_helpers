#!/bin/bash

# ##############################################################################################################################################################################
# Author:               Matthieu Holtz
# Year:                 2016
# Project:              
# Description:  	    Open linux console with the most common baudrate 115200, no flow control. Need screen.
#
# Licence:  	    	SPDX short identifier: MIT
#
#						Copyright © 2016, Matthieu Holtz <matthieu.holtz@gmail.com>
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



BAUD_RATE=115200

if [ -n "$1" ]
then
	echo "Try to screen on $1 at $BAUD_RATE baud with no flow control..."
	screen -fn -A "$1" $BAUD_RATE
else
	echo " == You have to specify dev file descriptor on which UART operates =="
	echo "    Posible values for USB/UART converters are =>"
	ls /dev/ttyUSB*
fi
