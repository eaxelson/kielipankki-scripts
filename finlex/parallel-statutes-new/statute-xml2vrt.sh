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
    $path/statute-move-johtolause.pl | \
    $path/statute-insert-paragraphs.pl | \
    $path/statute-separate-xml-tags.pl | \
    $path/statute-trim.pl | \
    $path/statute-mark-doc-parts.pl | \
    $path/statute-mark-heading-paragraphs.pl | \
    $path/statute-insert-vrt-tags.pl | \
    $path/statute-process-identifiointiosa.pl | \
    $path/statute-process-allekirjoitusosa.pl | \
    $path/statute-remove-orig-xml-tags.pl | \
    $path/statute-check-paragraphs.pl | \
    $path/statute-move-titles.pl | \
    $path/statute-tokenize.pl | \
    $path/statute-insert-sentence-tags.pl --filename $xmlfile --limit 150 | \
    $path/statute-insert-links.pl > tmp

doctype=`cat $xmlfile | $path/statute-get-doc-type.pl`

url_year=`echo $xmlfile | perl -pe 's/.*asd([0-9][0-9][0-9][0-9]).*/\1/g;'`
url_number=`echo $xmlfile | perl -pe 's/\.xml//g; s/asd\/(fi|sv)\/[0-9][0-9][0-9][0-9]\///g; s/(s|t)$//g; s/asd[0-9][0-9][0-9][0-9]//g; s/^0+//g;'`
url_lang=`echo $xmlfile | perl -pe 's/asd\/(fi|sv).*/\1/'`

url=""
# if statute number is too long, leave the url field empty
length=`printf "%s" "$url_number" | wc -c`
if [ "$length" -gt 4 ]; then
    url="";
else
    url="http://data.finlex.fi/eli/sd/"$url_year"/"$url_number"/alkup/"$url_lang".html"
fi

datefrom=$url_year"0101"
dateto=$url_year"1231"

echo '<text filename="'$xmlfile'" datefrom="'$datefrom'" dateto="'$dateto'" timefrom="000000" timeto="235959" url="'$url'" type="'$doctype'">' > $vrtfile
cat tmp >> $vrtfile
echo '</text>' >> $vrtfile
