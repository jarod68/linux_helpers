#! /bin/bash

# ##############################################################################################################################################################################
# Author:               Matthieu Holtz
# Year:                 2020
# Project:      		network discovery tool
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
WWW_PATH="$RO_PATH"

AVAHI_SSH_SERVICE="AVAHI_HTTP_SERVICE="
AVAHI_HTTP_SERVICE="/etc/avahi/services/http.service"

NAMES=(Batman Bruce Wayne Alfred Pennyworth Batgirl Barbara Gordon Robin Dick Grayson Ellen Yin Ethan Bennett Angel Rojas James Gordon Martian Manhunter Superman Hawkman Flash Joker Bane Penguin Man-Bat MrFreeze Catwoman Hideo Katsu Firefly Phosphorus Cluemaster Ventriloquist Scarface Clayface Riddler Killer Croc Hugo Ragdoll Spellbinder Temblor Poison Ivy Gearhead Toymaker Maxie Zeus Prank DAVE Tony Zucco Bruiser KillerMoth ClayfaceII EverywhereMan BlackMask NumberOne HarleyQuinn FrancisGrey Rumor TheJoining LexLuthor Metallo MercyGraves CountVertigo Blaise MirrorMaster Smoke Sinestro MartySlacker TerribleTrio ShadowThief Toyman ThugsEdit Riddlemen Killer Maxie)

EchoStatus()
{
	if [ $1 -eq 0 ]; then
  		#echo -e "$2...\t\t\t\e[42mOK\e[0m"
  		printf '%s\e[1;34m%8s\e[m\n' "$2..." "[OK]"
	else
  		#echo -e "$2...\t\t\t\e[41mNOK\e[0m"
  		printf '%s\e[1;34m%8s\e[m\n' "$2..." "[NOK]"
	fi
}

my_dir=`pwd`

apt-get update && sudo apt-get install -y samba figlet nmap xsltproc sed nginx avahi-daemon libavahi-client-dev

mkdir -p "$RO_PATH"
mkdir -p "$RW_PATH"
mkdir -p "$WWW_PATH"

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

service samba restart

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
cp ./nginx.conf /etc/nginx/nginx.conf

cp bootstrap.min.css "$RO_PATH"
cp bootstrap.min.css.map "$RO_PATH"
cp bootstrap.min.js "$RO_PATH"
cp bootstrap.min.js.map "$RO_PATH"

update-rc.d apache2 disable
EchoStatus $? "Disable apache2 autostart (if not install could be NOK)"

service nginx restart

dd if=/dev/zero of=/share-ro/1M.bin bs=1M count=1
EchoStatus $? "Generated 1M file"

dd if=/dev/zero of=/share-ro/10M.bin bs=10M count=1
EchoStatus $? "Generated 10M file"

dd if=/dev/zero of=/share-ro/100M.bin bs=100M count=1
EchoStatus $? "Generated 100M file"

echo "Computing checksums..."

sha512sum /share-ro/1M.bin > /share-ro/checksums.txt
EchoStatus $? "Generated 1M file SHA512 SUM"

sha512sum /share-ro/10M.bin >> /share-ro/checksums.txt
EchoStatus $? "Generated 10M file SHA512 SUM"

sha512sum /share-ro/100M.bin >> /share-ro/checksums.txt
EchoStatus $? "Generated 100M file SHA512 SUM"

cat /share-ro/checksums.txt
EchoStatus $? "Checksum computed"

update-rc.d avahi-daemon defaults


echo '<?xml version="1.0" standalone="no"?><!--*-nxml-*-->' > "$AVAHI_SSH_SERVICE"
echo '<!DOCTYPE service-group SYSTEM "avahi-service.dtd">'  >> "$AVAHI_SSH_SERVICE"
echo '<service-group>' >> "$AVAHI_SSH_SERVICE"
echo '<name replace-wildcards="yes">%h SSH</name>' >> "$AVAHI_SSH_SERVICE"
echo '<service>' >> "$AVAHI_SSH_SERVICE"
echo '<type>_ssh._tcp</type>' >> "$AVAHI_SSH_SERVICE"
echo '<port>22</port>' >> "$AVAHI_SSH_SERVICE"
echo '</service>' >> "$AVAHI_SSH_SERVICE"
echo '</service-group>' >> "$AVAHI_SSH_SERVICE"

EchoStatus $? "Generate $AVAHI_SSH_SERVICE"
cat "$AVAHI_SSH_SERVICE"

echo '<?xml version="1.0" standalone="no"?><!--*-nxml-*-->' > "$AVAHI_HTTP_SERVICE"
echo '<!DOCTYPE service-group SYSTEM "avahi-service.dtd">'  >> "$AVAHI_HTTP_SERVICE"
echo '<service-group>' >> "$AVAHI_HTTP_SERVICE"
echo '<name replace-wildcards="yes">%h HTTP</name>' >> "$AVAHI_HTTP_SERVICE"
echo '<service>' >> "$AVAHI_HTTP_SERVICE"
echo '<type>_http._tcp</type>' >> "$AVAHI_HTTP_SERVICE"
echo '<port>80</port>' >> "$AVAHI_HTTP_SERVICE"
echo '</service>' >> "$AVAHI_HTTP_SERVICE"
echo '</service-group>' >> "$AVAHI_HTTP_SERVICE"

EchoStatus $? "Generate $AVAHI_HTTP_SERVICE"
cat "$AVAHI_HTTP_SERVICE"

service avahi-daemon restart

sed '/network-discovery.sh/d' /etc/crontab
echo "*/1 * * * * root bash $my_dir/network-discovery.sh" >> /etc/crontab
EchoStatus $? "Setting crontab"

service cron restart
EchoStatus $? "Restart crontab service"

