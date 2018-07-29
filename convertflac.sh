#!/bin/bash
#
# convertflac.sh
# thom o'connor
# v0.1: 2015-08-29
# v0.2: 2018-07-27
# v0.5: 2018-07-29
# purpose: encode FLAC 16-bit and 24-bit audio files
# dependencies:
# * ffmpeg with flac libraries
# * metaflac for embedding cover image

PATH=/usr/bin:/bin:/usr/sbin:/usr/local/bin:/usr/local/tbin
export PATH

usage()
{
        echo "Usage: $0 [-b <16|24> (bits)] [-v <0|1> (verbose FALSE|TRUE)] [-i <0|1> (image FALSE|TRUE)] -s <input-file> -d <destination-directory>"
        exit 1
}

if [ -z "$4" ]; then
        usage
fi

# declare
DEBUG=0
IMAGE=0
BITS=0
input=0
output=0

# getopt
while [ $# -ge 1 ]; do
   case $1 in
      -b)       shift; BITS="$1" ;;
      -s)       shift; input="$1" ;;
      -d)       shift; output="$1" ;;
      -i)       shift; IMAGE="$1" ;;
      -v)       shift; DEBUG="$1" ;;
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
finalname="${myfilename%${mytype}}flac"
[ "$DEBUG" -ge 1 ] && echo "DEBUG: finalname=\"${finalname}\""

# convert audio file
# options used with intent:
#   -map_metadata 0 - try to capture all metadata from original files
#   -vsync 2 - eliminated some frame rate errors reported, not sure if optimal
#   -sample_fmt s16 or s32 - encode to 16-bit or 24-bit
#   -ar 48000 or 96000 - encode to 48000 or 96000 Hz
#   -codec:a flac - encode audio to flac format
#   -c:v copy - attempt to copy cover art, but now using metaflac instead as ffmpeg cannot embed cover art in flac files apparently
case "$BITS" in
 16)
  ffmpeg -i "${input}" -map_metadata 0 -vsync 2 -sample_fmt s16 -ar 48000 -codec:a flac -c:v copy "${outdirname}/${finalname}"
 ;;
 24)
  ffmpeg -i "${input}" -map_metadata 0 -vsync 2 -sample_fmt s32 -ar 96000 -codec:a flac -c:v copy "${outdirname}/${finalname}"
 ;;
 *)        usage ;;
esac

# import cover image to final flac
if [ "$IMAGE" -ge 1 ]; then
 [ -e "${outdirname}/tmp.jpg" ] && rm -f "${outdirname}/tmp.jpg"
 metaflac --export-picture-to="${outdirname}/tmp.jpg" --block-number=2 "${input}"
 metaflac --import-picture-from="3|image/jpeg|||${outdirname}/tmp.jpg" "${outdirname}/${finalname}"
 [ "$DEBUG" -lt 1 -a -e "${outdirname}/tmp.jpg" ] && rm -f "${outdirname}/tmp.jpg"
fi

exit 0
