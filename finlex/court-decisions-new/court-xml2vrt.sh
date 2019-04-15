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

cat $xmlfile | $path/court-separate-xml-tags.pl > tmp1
cat tmp1 | $path/court-trim.pl > tmp2
cat tmp2 | $path/court-mark-doc-parts.pl > tmp3
cat tmp3 | $path/court-mark-heading-paragraphs.pl > tmp4
cat tmp4 | $path/court-process-description.pl > tmp5
cat tmp5 | $path/court-process-abstract.pl > tmp6
cat tmp6 | $path/court-insert-vrt-tags.pl --filename $xmlfile> tmp7
cat tmp7 | $path/court-remove-orig-xml-tags.pl > tmp8
cat tmp8 | $path/court-check-paragraphs.pl --filename $xmlfile > tmp9
cat tmp9 | $path/court-move-titles.pl > tmp10
cat tmp10 | $path/court-tokenize.pl > tmp11
cat tmp11  | $path/court-insert-sentence-tags.pl --filename $xmlfile --limit 150 > tmp

year=`echo $xmlfile | perl -pe 's/.*(kho|kko)([0-9][0-9][0-9][0-9]).*/\2/g;'`
datefrom=$year"0101"
dateto=$year"1231"
url=""
keywords=`egrep -m 1 '<keywords=' tmp | perl -pe 's/<keywords="([^"]*)">/\1/;'`

echo '<text filename="'$xmlfile'" datefrom="'$datefrom'" dateto="'$dateto'" timefrom="000000" timeto="235959" url="'$url'" keywords="'$keywords'">' > $vrtfile
cat tmp | egrep -v '^<keywords=' >> $vrtfile
echo '</text>' >> $vrtfile
