#!/bin/bash

# Description: This sctipt will be triggeed by the transmission server,
# when a torrent download is done.
# It will check if the video file has audio encoded in EAC3, if so it will
# re-encode it to AC3 for better compatibility with Chromecast devices.
# It will also remove the torrent file when finished.
#
# Transmission documentation: https://github.com/transmission/transmission/blob/main/docs/README.md
#
# Author: Walter Ferreira (wferreira.uy@gmail.com)
#

# Enable debug mode
#set -xv

# Add Transmission user cred to this file.
# /var/lib/transmission-daemon/.setenv
#   export TR_USER=<user>
#   export TR_SECRET=<password>
source ~/.setenv

# transmission user
TRUSER=$TR_USER
# transmission secret
TRSECRET=$TR_SECRET
TREMOTE="transmission-remote -n $TRUSER:$TRSECRET"
TORRENT_ID=$TR_TORRENT_ID 
TORRENT_DIR=$TR_TORRENT_DIR

torrent_files=$(eval $TREMOTE -t $TR_TORRENT_ID -f)

# Find target media file to review encoding
file_target=$(echo "$torrent_files" | grep -E '^.*[[:digit:]]:'| grep 'mkv\|mp4')
file_name=$(echo $file_target | awk '{print $7}'| sed 's/\[/\\\[/'| sed 's/\]/\\\]/')
echo "file_target: $file_target"
echo "file_name: $file_name"

# Set input file name path
IN_FILE=$(find $TORRENT_DIR -name $(basename $file_name))
echo "TORRENT_DIR: $TORRENT_DIR"
echo "Input file: $IN_FILE"

# Set output file name path
OUT_FILE=$(echo $IN_FILE|sed 's/\(.*\)\(.\{3\}$\)/\1ac3.\2/')
echo "Output file: $OUT_FILE"

# If the video file has an EAC3 audio encoding, then re-encode to AC3.
pushd $TORRENT_DIR
if mediainfo $IN_FILE|grep EAC3; then
    echo -e "Found EAC3 audio encoding.\nRe-encondig to AC3:"
    $(ffmpeg -hwaccel auto -y -i $IN_FILE -map 0 -c:s copy -c:v copy -c:a ac3 -b:a 640k $OUT_FILE) && rm -f $IN_FILE
else
    echo -e "No EAC3 encondig found.\nSkipping audio re-encoding.\n"
fi
popd

# Remove torrent file
if eval $TREMOTE -t $TR_TORRENT_ID -it|grep 'speedapp\|torrentleech\|td-peers.com'; then
	echo "Private Tracker, I will not remove the torrent."
else
	echo "Removing torrent."
	eval $TREMOTE -t $TR_TORRENT_ID -r
fi 

#eof
