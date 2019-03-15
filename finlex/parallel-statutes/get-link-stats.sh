#!/bin/sh

year="*"
if [ "$1" != "" ]; then
    year=$1
fi

files=0
different_numbers=0
different_names=0

for file in asd_par/fi/${year}/*.vrt
do
    files=$(($files+1))
    grep '<link' $file > tmp1
    grep '<link' `echo $file | perl -pe 's/\/fi\//\/sv\//;'` > tmp2
    links_fi=`wc -l tmp1 | cut -f1 -d' '`
    links_sv=`wc -l tmp2 | cut -f1 -d' '`
    if !( diff tmp1 tmp2 > /dev/null ); then
	if [ "$links_fi" != "$links_sv" ]; then
	    different_numbers=$(($different_numbers+1))
	    #echo "different numbers of links: "$file
	else
	    different_names=$(($different_names+1))
	    #echo "different names for links: "$file
	fi
    fi
done

echo "Files with different names for links: "$different_names
echo "Files with different numbers of links: "$different_numbers
echo "Files in total: "$files
