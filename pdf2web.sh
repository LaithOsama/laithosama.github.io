#!/bin/sh

set -e
book="$(find books -name '*.pdf' | dmenu -l 15 -p 'Select the book:')"
title=$(basename "$book" .pdf)
title="$(echo $title | tr '_' ' ')" 
cover="$(find books -name cover.* | dmenu -l 15 -p 'Select the cover:')"
convert -sampling-factor 4:2:0 -resize 228x365\! -define jpeg:dct-method=float -interlace JPEG -quality 90% -strip -interlace Plane $cover ${cover%.*}.jpeg
author="$(printf "Martin Heidegger\\nRene Guenon\\nAleksandr Dugin\\nJulius Evola\\nCarl Schmitt\\nLeo Strauss\\nFriedrich Nietzsche" | dmenu -i -p 'Name the author:')"
printf "&ndash<div class=book>\\n&ndash &ndash<img src=%s alt=/> \\n&ndash &ndash<p><strong>%s</strong></p> \\n&ndash &ndash<p><a href=https://en.wikipedia.org/wiki/%s><i>%s</i></a></p>\\n &ndash &ndash<a href=%s>[English]</a>\\n&ndash</div>" "${cover%.*}.jpeg" "$title" "$author" "$author" "$book" > $tmpdir/index
sed "/<!-- Index -->/r $tmpdir/index" index.html > _; mv -f _ index.html

