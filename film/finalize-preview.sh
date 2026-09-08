#!/bin/sh
set -eu
# Call with source MP4 and output MP4. No upload is performed.
ffmpeg -hide_banner -loglevel error -y -i "$1" \
  -vf 'scale=886:1920:flags=lanczos,fps=30,setsar=1' \
  -c:v libx264 -profile:v high -level:v 4.0 -pix_fmt yuv420p \
  -b:v 11M -minrate 11M -maxrate 11M -bufsize 22M \
  -x264-params 'nal-hrd=cbr:force-cfr=1' -preset slow \
  -c:a aac -b:a 256k -ar 48000 -ac 2 -movflags +faststart "$2"
