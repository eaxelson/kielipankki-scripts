#!/bin/sh

year="*"
if [ "$1" != "" ]; then
    year=$1
fi

files=0
different_numbers=0
different_names=0

for file_fi in asd/fi/${year}/*.vrt
do
    file_sv=`echo $file_fi | perl -pe 's/\/fi\//\/sv\//;'`
    if (ls $file_sv > /dev/null 2> /dev/null); then
	files=$(($files+1))
	grep '<link' $file_fi > tmp1
	grep '<link' $file_sv > tmp2
	links_fi=`wc -l tmp1 | cut -f1 -d' '`
	links_sv=`wc -l tmp2 | cut -f1 -d' '`
	if !( diff tmp1 tmp2 > tmp3 ); then
	    if [ "$links_fi" != "$links_sv" ]; then
		different_numbers=$(($different_numbers+1))
		echo "different numbers of links: "$file_fi" "$file_sv
		cat tmp3
	    else
		different_names=$(($different_names+1))
		echo "different names for links:  "$file_fi" "$file_sv
		cat tmp3
	    fi
	fi
    fi
done

echo "Files with different numbers of links:                                  "$different_numbers
echo "Files with equal numbers of links, but part of links differently named: "$different_names
echo "Files with the same links:                                              "$(($files-$different_numbers-$different_names))
echo "Files in total:                                                         "$files
