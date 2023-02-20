#!/bin/bash

#
# Re-encode audio to AC3 in media file, if EAC3 encoding is found.
# Usage: ./ac3ncode.sh <path to media file>
# Author: Walter Ferreira (wferreira.uy@gmail.com)
#

IN_FILE=$1
OUT_FILE="$(echo $IN_FILE|sed 's/\(.*\)\(.\{3\}$\)/\1ac3.\2/')"

echo "Input file: $IN_FILE"
echo "Output file: $OUT_FILE"


# If the video file has an EAC3 audio encoding, then re-encode to AC3.
if mediainfo $IN_FILE|grep EAC3; then
    echo -e "Found EAC3 audio encoding.\nRe-encondig to AC3:"
    $(ffmpeg -hwaccel auto -y -i $IN_FILE -map 0 -c:s copy -c:v copy -c:a ac3 -b:a 640k $OUT_FILE) && rm -f $IN_FILE
else
    echo -e "No EAC3 encondig found.\nSkipping audio re-encoding.\n"
fi

#eof
