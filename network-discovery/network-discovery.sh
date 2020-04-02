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

echo $'<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


  <xsl:template match="/">
    <html lang="en">
      <head>
        <!-- Required meta tags -->
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>

        <!-- Bootstrap CSS -->
        <link rel="stylesheet" href="bootstrap.min.css"/>

        <title>Network scanner</title>
      </head>
      <body>
        <nav class="navbar navbar-expand-lg navbar-light bg-light">
          <a class="navbar-brand" href="#">Network scanner</a>
          <div class="collapse navbar-collapse" id="navbarSupportedContent">
            <form class="form-inline my-2 my-lg-0">
              <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Refresh</button>
            </form>
          </div>
        </nav>

        <div class="jumbotron jumbotron-fluid">
          <div class="container">
            <h1 class="display-6">Active hosts : <xsl:value-of select="count(nmaprun/host)"/></h1>
            <p>Command <mark><xsl:value-of select="nmaprun/@args"/></mark> executed on <xsl:value-of select="nmaprun/@startstr"/></p>
            
            <ul class="list-group">
              <xsl:for-each select="nmaprun/host">
                <li class="list-group-item">
                  <xsl:for-each select="address">
                    <xsl:if test="@addrtype = \'ipv4\'">
                      <p><strong><xsl:value-of select="@addr"/></strong></p>
                    </xsl:if>

                    <xsl:if test="@addrtype = \'mac\'">
                      <p>
                        <em><xsl:value-of select="@addr"/></em> - 
                        <span class="badge badge-warning"><xsl:value-of select="@vendor"/> </span>
                      </p>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:for-each select="ports/port">
                    <xsl:if test="state/@state = \'open\'">
                      <span class="badge badge-secondary"><xsl:value-of select="service/@name"/> </span>/<span class="badge badge-primary"><xsl:value-of select="@portid"/> </span> -
                    </xsl:if>
                  </xsl:for-each>
                </li>
              </xsl:for-each>
            </ul>
          </div>
        </div>

        <div class="jumbotron jumbotron-fluid">
          <div class="container">
            <h1 class="display-6">Test files</h1>
            <ul class="list-group">

              <li class="list-group-item">
                <p><strong><a href="1M.bin">1M.bin</a></strong></p>
                <p><small>1M_HASH</small>
                  <span class="badge badge-warning">SHA-512</span>
                </p>
              </li>
              <li class="list-group-item">
                <p><strong><a href="10M.bin">10M.bin</a></strong></p>
                <p><small>10M_HASH</small>
                  <span class="badge badge-warning">SHA-512</span>
                </p>
              </li>
              <li class="list-group-item">
                <p><strong><a href="100M.bin">100M.bin</a></strong></p>
                <p><small>100M_HASH</small>
                  <span class="badge badge-warning">SHA-512</span>
                </p>
              </li>
            </ul>
          </div>
        </div>
        <!-- Latest compiled JavaScript -->
        <script src="bootstrap.min.js"></script>
      </body>
    </html>
  </xsl:template>


</xsl:stylesheet>' > /tmp/xslt.xsl

NETWORK=192.168.1.*
XSLT="/tmp/xslt.xsl"
HTTP_SERV_DIR=//share-ro/

TMP_IP_FILE=/tmp/ip.txt
TMP_XML_RESULT=/tmp/result.xml
TMP_HTML_RESULT=/tmp/index.html


rm "$TMP_HTML_RESULT" "$TMP_XML_RESULT" "$TMP_IP_FILE"

CHECKSUM_FILE=$HTTP_SERV_DIR/checksums.txt

nmap -sP -PR 192.168.1.* -oG - | awk '/Up$/{print $2}' > "$TMP_IP_FILE"

nmap -iL "$TMP_IP_FILE" nmap -p 80,22,53,443,21 -oX "$TMP_XML_RESULT" $NETWORK

xsltproc -o "$TMP_HTML_RESULT" "$XSLT" "$TMP_XML_RESULT"

SUM=$(cat "$CHECKSUM_FILE" | grep 1M.bin | cut -d " " -f1)
sed -i 's/1M_HASH/'"$SUM"'/g' "$TMP_HTML_RESULT"

SUM=$(cat "$CHECKSUM_FILE" | grep 10M.bin | cut -d " " -f1)
sed -i 's/10M_HASH/'"$SUM"'/g' "$TMP_HTML_RESULT"

SUM=$(cat "$CHECKSUM_FILE" | grep 100M.bin | cut -d " " -f1)
sed -i 's/100M_HASH/'"$SUM"'/g' "$TMP_HTML_RESULT"

cp "$TMP_HTML_RESULT" "$HTTP_SERV_DIR"



