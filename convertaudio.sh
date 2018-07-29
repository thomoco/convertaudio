#!/bin/bash
#
# convertaudio.sh
# thom o'connor
# v0.1: 2015-08-29
# v0.2: 2018-07-27
# v0.5: 2018-07-29
# purpose: convert audio formats for directories of audio files
# * current encoder formats supported: WAV, FLAC 16-bit, FLAC 24-bit, MP3
# * also attempts to include cover image in files where possible

PATH=/usr/bin:/bin:/usr/sbin:/usr/local/bin:/usr/local/tbin
export PATH

usage()
{
        echo "Usage: $0 [-e <MP3|FLAC16|FLAC24> (encoder)] [-v (verbose)] [-i (image)] -s <source-directory> -d <destination-directory>"
        exit 1
}

if [ -z "$4" ]; then
        usage
fi

# declare
DEBUG=0
IMAGE=0

# getopt
while [ $# -ge 1 ]; do
   case $1 in
      -e)       shift;  ENCODER="$1" ;;
      -s)       shift;  SRCDIR="$1" ;;
      -d)       shift;  WORKDIR="$1" ;;
      -i)       IMAGE=1 ;;
      -v)       DEBUG=1 ;;
      -*)       usage ;;
      *)        usage ;;
   esac
   shift
done

[ "$DEBUG" -ge 1 ] && echo "DEBUG: SRCDIR=\"${SRCDIR}\""
[ "$DEBUG" -ge 1 ] && echo "DEBUG: WORKDIR=\"${WORKDIR}\""

if [ ! -d "${SRCDIR}" ];
 then
 echo "$SRCDIR missing, exiting"
 exit 1
fi

# prep workdir
if [ ! -d "${WORKDIR}" ];
 then
 echo "${WORKDIR} missing, creating"
 mkdir -m 1777 -p "${WORKDIR}" || exit 1
fi

# prep directories
CURDIR="`pwd`"
[ "$DEBUG" -ge 1 ] && echo "DEBUG: CURDIR=\"${CURDIR}\""
cd "${WORKDIR}"
FULLWORKDIR="`pwd`"
[ "$DEBUG" -ge 1 ] && echo "DEBUG: FULLWORKDIR=\"${FULLWORKDIR}\""
cd "${CURDIR}"

# create dirs
cd "${SRCDIR}"
find . -type d -exec mkdir -m 1777 -p "${FULLWORKDIR}/{}" \;

# convert
case "$ENCODER" in
 MP3) find . -type f -exec convertmp3.sh -s "{}" -d "${FULLWORKDIR}" \; ;;
 FLAC16) find . -type f -exec convertflac.sh -b 16 -v "${DEBUG}" -i "${IMAGE}" -s "{}" -d "${FULLWORKDIR}" \; ;; # 16 bit
 FLAC24) find . -type f -exec convertflac.sh -b 24 -v "${DEBUG}" -i "${IMAGE}" -s "{}" -d "${FULLWORKDIR}" \; ;; # 24 bit
esac

exit 0
