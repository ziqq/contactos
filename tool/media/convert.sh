#!/usr/bin/env bash
# Converts a screen recording into web-friendly README media:
#   <name>.mp4  - H.264, no audio, streamable
#   <name>.webp - animated preview
#   <name>.gif  - animated preview for renderers without WebP support
# Usage: tool/media/convert.sh input.(mov|mp4) [output_dir] [name]
set -euo pipefail

input="${1:?Pass the recording to convert}"
output_dir="${2:-.github/images}"
name="${3:-example}"
width="${WIDTH:-320}"
fps="${FPS:-15}"
mkdir -p "$output_dir"

ffmpeg -y -loglevel error -i "$input" -an \
  -vf "scale=720:-2:flags=lanczos,fps=30" \
  -c:v libx264 -preset slow -crf 28 -pix_fmt yuv420p -movflags +faststart \
  "$output_dir/$name.mp4"

ffmpeg -y -loglevel error -i "$input" -an \
  -vf "fps=$fps,scale=$width:-2:flags=lanczos" \
  -c:v libwebp -lossless 0 -q:v 60 -loop 0 \
  "$output_dir/$name.webp"

ffmpeg -y -loglevel error -i "$input" -an \
  -vf "fps=$fps,scale=$width:-2:flags=lanczos,split[a][b];[a]palettegen=max_colors=128[p];[b][p]paletteuse=dither=bayer:bayer_scale=5" \
  -loop 0 "$output_dir/$name.gif"

ls -lh "$output_dir/$name".{mp4,webp,gif}
