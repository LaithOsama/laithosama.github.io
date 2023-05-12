#!/bin/sh


set -e

# EPUBs require harfbuzz library, which is written in C++ and couldn't be
# stictly compiled, so always use PDFs. 

# Metadata, Need exiftool!.
# TODO: find something simpler to extract them.

list() {
        case "$(find books -type f \( -name *.pdf -o -name *.epub \) | wc -l)" in
                0) echo "There's nothing to $2." && exit 1 ;;
                *) find books -type f \( -name *.pdf -o -name *.epub \) | awk -F '/' '{print $NF}' | nl
                read -r number ;;
        esac
        chosen="$(find books -type f \( -name *.pdf -o -name *.epub \) | nl | grep -w " $number")"
        filename="$(basename "$chosen")" && filename="${filename%.*}"
}

metadata() {
EBOOK="$(find books -type f \( -name *.pdf -o -name *.epub \) | $menu)"
if [ "${EBOOK##*.}" = epub ]; then

elif ["${EBOOK##*.}" = pdf ]; then

fi
# ebook-convert "$BOOK" $
TITLE="$(exiftool -Title '$EBOOK')"
EBOOK_DIR=$( echo "${TITLE#*:}" | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/-\+/-/g;s/\(^-\|-\$\)//g')
AUTHOR="$(exiftool -Author "$EBOOK")"
AUTHOR_DIR="$( echo "${AUTHOR#*:}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/-\+/-/g;s/\(^-\|-\$\)//g')"
COVER="books/$AUTHOR_DIR/$EBOOK_DIR/cover.jpeg"
PAGES="$(exiftool -PageCount "$EBOOK")"
TAGS="$(exiftool -Tags "$EBOOK")"
DESC="$(exiftool -Description "$EBOOK")"
DATE="$(exiftool -Date "$EBOOK")"
}

compress() {
convert -sampling-factor 4:2:0 -resize 400x400\! -define jpeg:dct-method=float -interlace JPEG -quality 90% -strip -interlace Plane $COVER ${COVER%.*}.jpeg
convert -sampling-factor 4:2:0 -strip -interlace Plane $COVER ${COVER%.*}.avif
}

publish() {
mv -f "$book" $("$book" | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/-\+/-/g;s/\(^-\|-\$\)//g')
printf "<li class=ebook>\\n<a href=%s tabindex='-1' property='schema:url' height='335px' width='224px' loading='lazy'>\\n<picture>\\n<source srcset=%s type='image/avif'>\\n<source srcset=%s type='image/jpeg'>\\n<img src=%s alt=%s >\\n</picture>\\n</a>\\n<p><a href=%s property='schema:url'>%s</a></p>\\n<p> <a href=%s>%s<i></i></a></p>\\n<div class="details"><p>%s Pages</p><p>Philosophy</p><p>Politics</p></div>\\n</li>" books/$AUTHOR_DIR/$EBOOK_DIR/index.html "${COVER%.*}.avif" $COVER $COVER "${TITLE#*:} book cover" books/$AUTHOR_DIR/$EBOOK_DIR/index.html "${TITLE#*:}" books/$AUTHOR_DIR/index.html "${AUTHOR#*:}"  ${PAGES#*:} > $(mktemp -d)/index 
mkdir -p books/$AUTHOR_DIR/$EBOOK_DIR/
printf "---\\ntitle: "${TITLE#*:}"\\nauthor: "${AUTHOR#*:}"\\ndate:"${DATE#*:}"\\ntags:"${TAGS#*:}"\\n---" > books/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md
$EDITOR books/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md
sed /---/,/---/d  books/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md > /tmp/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md
content="$(smu /tmp/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md)"
# sed "/<!-- Index -->/r $(mktemp -d)/index" index.html > _; mv -f _ index.html# 
# sed "/<!-- Index -->/r $(mktemp -d)/index" $PWD/books/$author/index.html > _; mv -f _ $PWD/books/$author/index.html# 
}

list compress publish