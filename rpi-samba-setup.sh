#!/bin/bash

# ##############################################################################################################################################################################
# Author:               Matthieu Holtz
# Year:                 2019
# Project:      		NONE
# Description:  		
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

RO_PATH="//share-ro"
RW_PATH="//share-rw"

NAMES=(Batman Bruce Wayne Alfred Pennyworth Batgirl Barbara Gordon Robin Dick Grayson Ellen Yin Ethan Bennett Angel Rojas James Gordon Martian Manhunter Superman Hawkman Flash Joker Bane Penguin Man-Bat MrFreeze Catwoman Hideo Katsu Firefly Phosphorus Cluemaster Ventriloquist Scarface Clayface Riddler Killer Croc Hugo Ragdoll Spellbinder Temblor Poison Ivy Gearhead Toymaker Maxie Zeus Prank DAVE Tony Zucco Bruiser KillerMoth ClayfaceII EverywhereMan BlackMask NumberOne HarleyQuinn FrancisGrey Rumor TheJoining LexLuthor Metallo MercyGraves CountVertigo Blaise MirrorMaster Smoke Sinestro MartySlacker TerribleTrio ShadowThief Toyman ThugsEdit Riddlemen Killer Maxie)

apt-get update && sudo apt-get install -y samba figlet

mkdir -p "$RO_PATH"
mkdir -p "$RW_PATH"

chmod 765 "$RO_PATH"
chmod 777 "$RW_PATH"

HOSTNAME=${NAMES[$RANDOM % ${#NAMES[@]} ]}

HOSTNAME="$HOSTNAME-$RANDOM"

if [ -f /etc/samba/smb.conf ] ;then
	cp /etc/samba/smb.conf /etc/samba/smb.conf.old
fi

cp ./rpi-samba-setup.smb.conf /etc/samba/smb.conf

sed -i 's/SMBHOSTNAME/'"$HOSTNAME"'/g' /etc/samba/smb.conf

echo "$HOSTNAME" > /etc/hostname

echo "figlet $HOSTNAME" >> ~/.bashrc 

echo "hostname randomly set to => $HOSTNAME"

/etc/init.d/samba restart
