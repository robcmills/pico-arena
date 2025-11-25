#!/bin/bash

# generate palette
# ffmpeg -i arena_0.gif -vf "palettegen" pico8-palette.png

# ffmpeg -i arena_128.gif -i pico8-palette.png -filter_complex "scale=128:128:flags=neighbor[x];[x][1:v]paletteuse=dither=none" arena_128_128.gif

for f in *.gif; do
    if [[ "$f" == *_128.gif ]]; then
        continue
    fi
    base="${f%.gif}"
    ffmpeg -i "$f" -i pico8-palette.png \
        -filter_complex "scale=128:128:flags=neighbor[x];[x][1:v]paletteuse=dither=none" \
        "${base}_128.gif"
done
