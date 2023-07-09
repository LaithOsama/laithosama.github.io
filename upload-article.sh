#!/bin/sh

if [ "{$1##*.}" = html ]; then
    content="$(sed -n '/<main>/,/<\/main>/p' $1)" #I n case the article in HTML file; grep content between <main>/</main> elements.
else
    content="${smu $1}" # In case the article in markdown or plaintext, convert it to HTML code.
fi

title=$(grep 'title:' $dir/drafts/$filename.md) || title=$2
date=$(grep 'date:' $dir/drafts/$filename.md)
author=$(grep 'author:' $dir/drafts/$filename.md)
tag=$(grep 'subject:' $dir/drafts/$filename.md) 

output=$(printf "<!DOCTYPE html>\\n<html xmlns='http://www.w3.org/1999/xhtml'>\\n<head>\\n <meta charset='utf-8'/>\\n<title>Based eBooks</title>\\n <link rel='icon' href='data:,'/>\\n<meta name='description' content='An independent, non-profit digital library, I hold it in my hands for the benefit of my Arabian Islamic nation.'/>\\n<link rel='stylesheet' type='text/css' href='../../../style.css'/>\\n<link href='../../../dark.css' media='screen and (prefers-color-scheme: dark)' rel='stylesheet' type='text/css' />\\n<meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'/>\\n</head>\\n<body>\\n<header>\\n<img src='.../../../images/header.png' alt='header image' fetchpriority='high'/>\\n<a href='../../../index.html'>Based eBooks</a>\\n</header>\\n<nav>\\n<a href='../../../index.html'>Home</a>\\n<a href='../../../about.html'>About</a>\\n<a href='../../../faq.html'>FAQ</a>\\n</nav>\\n<main dir='ltr'>\\n<div id='metadata'>\\n<p><strong>Title</strong>: %s<br>\\n<strong>Author</strong>: %s<br>\\n<strong>Genres</strong>: %s<br>\\n<strong>Publish Date</strong>: %s<br>\\n</div>\\n<footer><a href='../../../index.html#ebooks'>Ebooks</a>&#x2022; <a href='../../../index.html#authors'>Authors</a> &#x2022; <a href='../../../about.html'>About</a> &#x2022; <a href='../../../donate.html'>Donate</a>&#x2022; <a href='https://github.com/LaithOsama/Based-eBooks'>Source</a> &#x2022; <a href='../../../rss.xml'>Ebook Feeds</a>\\n<p>Based eBooks is inspired by <a href='https://standardebooks.org'>Standard Ebooks</a>library.<br/> Most of the ebooks here is taken from Internet Archive, Library Genesis and Project Gutenberg.<br/> Yes, most of content here is copyrighted by someone, wanna fight ? Go fuck yourself bastard, enemy copyright is bullshit for me.</p>\\n</footer>\\n</main>\\n</body>\\n </html>""${title#*:}" "${date#*:}" "${title#*:}" "$content" "$url" "${author#*:}" "$filename" "$email" "${title#*:}")