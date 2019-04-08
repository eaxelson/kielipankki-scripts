#!/bin/sh

path=""
xmlfile=""
vrtfile=""

for arg in "$@"
do
    if [ "$arg" = "--script-path" ]; then
	path="next...";
    elif [ "$arg" = "--vrt-file" ]; then
	vrtfile="next...";
    elif [ "$path" = "next..." ]; then
	path=$arg;
    elif [ "$vrtfile" = "next..." ]; then
	vrtfile=$arg;
    elif [ "$arg" = "--help" -o "$arg" = "-h" ]; then
	echo "Usage: "$0" XMLFILE [--script-path PATH] [--vrt-file VRTFILE]";
	exit 0;
    elif [ "$xmlfile" = "" ];then
	xmlfile=$arg;
    else
	echo "Option not recognized: "$arg;
	echo "Usage: "$0" XMLFILE [--script-path PATH] [--vrt-file VRTFILE]";
	exit 1;
    fi
done

if [ "$xmlfile" = "" ]; then
    echo "ERROR: name of xml file must be given"; exit 1;
fi
if !(ls $xmlfile > /dev/null 2> /dev/null); then
    echo "ERROR: no such file: "$xmlfile; exit 1;
fi
if [ "$vrtfile" = "" ]; then
    vrtfile=`echo $xmlfile | perl -pe 's/\.xml/\.vrt/'`
fi

cat $xmlfile | \
    $path/court-separate-xml-tags.pl | \
    $path/court-trim.pl | \
    $path/court-mark-doc-parts.pl | \
    $path/court-mark-heading-paragraphs.pl | \
    $path/court-process-description.pl | \
    $path/court-insert-vrt-tags.pl | \
    $path/court-remove-orig-xml-tags.pl | \
    $path/court-check-paragraphs.pl | \
    $path/court-move-titles.pl > tmp
