#!/bin/sh


set -e
TMP="$(mktemp -d)"
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
TITLE="$(pdfinfo '$EBOOK' | grep Title)"
DIR_NAME=$( echo "${TITLE#*:}" | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/-\+/-/g;s/\(^-\|-\$\)//g')
AUTHOR="$(pdfinfo '$EBOOK')"
AUTHOR_DIR="$( echo '${AUTHOR#*:}' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/-\+/-/g;s/\(^-\|-\$\)//g')"
COVER="books/$AUTHOR_DIR/$EBOOK_DIR/cover.jpeg"
PAGES="$(pdfinfo '$EBOOK')"
TAGS="$(pdfinfo '$EBOOK')"
DESC="$(pdfinfo '$EBOOK')"
DATE="$(pdfinfo '$EBOOK')"
}

compress() {
convert -sampling-factor 4:2:0 -resize 524x734 -define jpeg:dct-method=float -interlace JPEG -quality 80% -strip -interlace Plane $COVER ${COVER%.*}.jpeg
avifenc --min 0 --max 63 -a end-usage=q -a cq-level=48 -a tune=ssim $COVER ${COVER%.*}.avif
}

publish() {
mv -f "$book" $("$book" | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/-\+/-/g;s/\(^-\|-\$\)//g')
printf "<li class=ebook>\\n<a href=%s tabindex='-1' property='schema:url' height='335px' width='224px' loading='lazy'>\\n<picture>\\n<source srcset=%s type='image/avif'>\\n<source srcset=%s type='image/jpeg'>\\n<img src=%s alt=%s >\\n</picture>\\n</a>\\n<p><a href=%s property='schema:url'>%s</a></p>\\n<p> <a href=%s>%s<i></i></a></p>\\n</li>" books/$AUTHOR_DIR/$EBOOK_DIR/index.html "${COVER%.*}.avif" $COVER $COVER "${TITLE#*:} book cover" books/$AUTHOR_DIR/$EBOOK_DIR/index.html "${TITLE#*:}" books/$AUTHOR_DIR/index.html "${AUTHOR#*:}"  ${PAGES#*:} > $TMP/index 
mkdir -p books/$AUTHOR_DIR/$EBOOK_DIR/
printf "---\\ntitle: "${TITLE#*:}"\\nauthor: "${AUTHOR#*:}"\\ndate:"${DATE#*:}"\\ntags:"${TAGS#*:}"\\n---" > books/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md
$EDITOR books/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md
sed /---/,/---/d  books/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md > /tmp/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md
content="$(smu /tmp/$AUTHOR_DIR/$EBOOK_DIR/$EBOOKS_DIR-$AUTHOR_DIR.md)"
printf "<!DOCTYPE html> <html xmlns=http://www.w3.org/1999/xhtml> <title>Based eBooks | %s - %s</title> <link rel=icon href=data:, /> <meta charset=utf-8 /> <meta name=description content="An independent, non-profit digital library, I hold it in my hands for the benefit of my Arabian Islamic nation." /> <link rel="stylesheet" type="text/css" href="../../../style.css" /> <link href="../../../dark.css" media="screen and (prefers-color-scheme: dark)" rel="stylesheet" type="text/css" /> <meta name="viewport" content= "width=device-width, initial-scale=1" /> <header> <img src="../../../images/header.png" alt="header's image"/> <a href="../../../index.html">Based eBooks</a> </header> <nav> <a href="../../../index.html">Home</a> <a href="../../../about.html">About</a> <a href="../../../faq.html">FAQ</a> </nav> <main> <section id="book-info"> <div id="book-table"> <picture> <source srcset="cover.avif" type="image/avif"> <source srcset="cover.jpeg" type="image/jpeg"> <img src="cover.jpeg" alt="%s cover"> </picture> <section id="book-details-cell"> <div id="book-details"> <p><strong>Title</strong>: %s<br> <strong>Author</strong>: %s<br> <strong>Genres</strong>: %s<br> <strong>Publish Date</strong>: %s<br> <strong>PDF</strong>: <a href="%s-%s.pdf">English</a> | <a href="%s-%s-ar.pdf">Arabic</a><br> <strong>EPUB</strong> (WIP): <a href="%s-%s.epub">English</a> | <a href="%s-%s-ar.epub">Arabic</a><br> <strong>Audiobook</strong> (WIP): <a href="%s-$s-ar-audiobook.opus">Arabic</a><br> You can also <a href="%s-%s.html">read it online</a> via your browser.</p> <p>%s</p> </div> </section> </div> </section>"

# sed "/<!-- Index -->/r $(mktemp -d)/index" index.html > _; mv -f _ index.html# 
# sed "/<!-- Index -->/r $(mktemp -d)/index" $PWD/books/$author/index.html > _; mv -f _ $PWD/books/$author/index.html# 
}

list compress publish