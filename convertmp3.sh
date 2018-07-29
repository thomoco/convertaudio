#!/bin/bash
#
# convertmp3.sh
# thom o'connor
# v0.1: 2015-08-29
# v0.2: 2018-07-27
# purpose: encode MP3 audio files with VBR 0
# dependencies:
# * ffmpeg with libmp3lame libraries

PATH=/usr/bin:/bin:/usr/sbin:/usr/local/bin:/usr/local/tbin
export PATH

usage()
{
        echo "Usage: $0 [-b <bitrate>] [-v (verbose)] -s <input-file> -d <destination-directory>"
        exit 1
}

if [ -z "$4" ]; then
        usage
fi

# declare
DEBUG=0

# getopt
while [ $# -ge 1 ]; do
   case $1 in
      -b)       shift;  BITRATE="$1" ;;
      -s)       shift;  input="$1" ;;
      -d)       shift;  output="$1" ;;
      -v)       DEBUG=1 ;;
      -*)       usage ;;
      *)        usage ;;
   esac
   shift
done

[ "$DEBUG" -ge 1 ] && echo "DEBUG: input=\"${input}\""
[ "$DEBUG" -ge 1 ] && echo "DEBUG: output=\"${output}\""

if [ -z "${input}" -o -z "${output}" ];
then
 usage
fi

# create final filename 
mydirname="`dirname \"${output}\"`"
[ "$DEBUG" -ge 1 ] && echo "DEBUG: mydirname=\"${mydirname}\""
outdirname="${output}"
[ "$DEBUG" -ge 1 ] && echo "DEBUG: outdirname=\"${outdirname}\""

myfilename="`basename \"${input}\"`"
[ "$DEBUG" -ge 1 ] && echo "DEBUG: myfilename=\"${myfilename}\""
mytype="`echo ${myfilename} | sed -e 's/^.*\.\([^.]*\)$/\1/;'`"
[ "$DEBUG" -ge 1 ] && echo "DEBUG: mytype=\"${mytype}\""
finalname="${myfilename%${mytype}}mp3"
[ "$DEBUG" -ge 1 ] && echo "DEBUG: finalname=\"${finalname}\""

# convert
echo "Converting $input to mp3..."
ffmpeg -i "${input}" -ac 2 -map_metadata 0 -id3v2_version 3 -vsync 2 -c:v copy -codec:a libmp3lame -qscale:a 0 "${outdirname}/${finalname}"

exit 0
