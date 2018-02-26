#!/bin/bash

cp "$1" "$1".old

cat "$1" | sed -e 's#//\(.*\)#/*\1 */#' > "$1".tmp

mv "$1".tmp "$1"
