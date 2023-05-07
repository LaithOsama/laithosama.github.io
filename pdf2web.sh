#!/bin/sh


set -e

if tty -s || [ ! "$DISPLAY" ]; then
   menu=fzy "$@"
else
   menu=dmenu "$@"
fi

# Metadata, Need exiftool!.
# TODO: find something simpler to extract them.



# EPUBs require harfbuzz library, which is written in C++ and couldn't be
# stictly compiled, so always use PDFs. 
# TODO: try to grep both PDFs and EPUBs books, so if
# the ext was epub I could convert it to pdf automaticlly
EBOOK="$(find books -name *.pdf | $menu)"

# Metadata, Need exiftool!.
# TODO: find something simpler to extract them.

TITLE="$(exiftool -Title '$EBOOK')"
EBOOK_DIR=$( echo "${TITLE#*:}" | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/-\+/-/g;s/\(^-\|-\$\)//g')
AUTHOR="$(exiftool -Author "$EBOOK")"
AUTHOR_DIR="$( echo "${AUTHOR#*:}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/-\+/-/g;s/\(^-\|-\$\)//g')"
COVER="books/$AUTHOR_DIR/$EBOOK_DIR/cover.jpeg"
PAGES="$(exiftool -PageCount "$EBOOK")"
TAGS="$(exiftool -Tags "$EBOOK")"
DESC="$(exiftool -Description "$EBOOK")"
DATE="$(exiftool -Date "$EBOOK")"

# mv -f "$book" $("$book" | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/-\+/-/g;s/\(^-\|-\$\)//g')
# convert -sampling-factor 4:2:0 -resize 224x335\! -define jpeg:dct-method=float -interlace JPEG -quality 90% -strip -interlace Plane $cover ${cover%.*}.jpeg# 
# convert -sampling-factor 4:2:0 -resize 224x335\! -quality 90% -strip -interlace Plane $cover ${cover%.*}.avif# 
printf "<li class=ebook>\\n<a href=%s tabindex='-1' property='schema:url' height='335px' width='224px' loading='lazy'>\\n<picture>\\n<source srcset=%s type='image/avif'>\\n<source srcset=%s type='image/jpeg'>\\n<img src=%s alt=%s >\\n</picture>\\n</a>\\n<p><a href=%s property='schema:url'>%s</a></p>\\n<p> <a href=%s>%s<i></i></a></p>\\n<div class="details"><p>%s Pages</p><p>Philosophy</p><p>Politics</p></div>\\n</li>" "books/$AUTHOR_DIR/$EBOOK_DIR/index.html" ${COVER%.*}.avif "$COVER" "$COVER" "${TITLE#*:} book cover" "books/$AUTHOR_DIR/$EBOOK_DIR/index.html" "${TITLE#*:}" "books/$AUTHOR_DIR/index.html" "${AUTHOR#*:}"  ${PAGES#*:} > $(mktemp -d)/index 
mkdir -p books/$AUTHOR_DIR/$EBOOK_DIR/
printf "---\\ntitle: "${TITLE#*:}"\\nauthor: "${AUTHOR#*:}"\\ndate:"${DATE#*:}"\\ntags:"${TAGS#*:}"\\n---" > books/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md
$EDITOR books/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md
sed /---/,/---/d  books/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md > /tmp/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md
content="$(smu /tmp/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md)"
# sed "/<!-- Index -->/r $(mktemp -d)/index" index.html > _; mv -f _ index.html# 
# sed "/<!-- Index -->/r $(mktemp -d)/index" $PWD/books/$author/index.html > _; mv -f _ $PWD/books/$author/index.html# 

