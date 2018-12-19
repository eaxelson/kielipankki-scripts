#!/bin/sh

if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo ""
    echo "Usage: court-generate-all-vrt-files.sh [--kko|--kho] [--fin|--swe]"
    echo ""
    exit 0
fi

url_lang=""
dir_lang=""
court=""
courtdir=""

for arg in "$@"
do
    if [ "$arg" = "--fin" ]; then
	url_lang="--fin"
	dir_lang="fi"
    elif [ "$arg" = "--swe" ]; then
	url_lang="--swe"
	dir_lang="sv"
    elif [ "$arg" = "--kko" ]; then
	court="--kko"
	courtdir="kko"
    elif [ "$arg" = "--kho" ]; then
	court="--kho"
	courtdir="kho"
    fi
done

if [ "$url_lang" = "" ]; then
    echo "Error: language must be defined with --fin or --swe."
    exit 1
fi

if [ "$court" = "" ]; then
    echo "Error: court must be defined with --kko or --kho."
    exit 1
fi

for f in ${courtdir}/${dir_lang}/*/*.xml
do
    echo "processing xml file "$f"..."
    if ! (./court-process-xml-to-vrt.sh $f `echo $f | perl -pe 's/\.xml/\.vrt/g;'` ${url_lang} ${court} ); then
	exit 1
    fi
done
