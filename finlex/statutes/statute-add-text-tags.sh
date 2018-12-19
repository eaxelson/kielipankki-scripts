#!/bin/sh

if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo ""
    echo "Usage: statute-add-text-tags INFILE VRTFILE [--fin|--swe]"
    echo ""
    exit 0
fi

datefrom=""
dateto=""
url_lang=""

for arg in "$@"
do
    if [ "$arg" = "--fin" ]; then
	url_lang="fin"
    elif [ "$arg" = "--swe" ]; then
	url_lang="swe"
    fi
done

if [ "$url_lang" = "" ]; then
    echo "Error: language must be defined with --fin or --swe."
    exit 1
fi

# extract year and statute number from the name of VRTFILE
url_year=`echo $2 | perl -pe 's/.*asd([0-9][0-9][0-9][0-9]).*/$1/g;'`
url_number=`echo $2 | perl -pe 's/\.vrt//g; s/(fi|sv)\/[0-9][0-9][0-9][0-9]\///g; s/(s|t)$//g; s/asd[0-9][0-9][0-9][0-9]//g; s/^0+//g;'`

url="http://data.finlex.fi/eli/sd/"$url_year"/"$url_number"/alkup/"$url_lang".html"


# extract date of document from INFILE
datefrom=`grep -m 1 'met1:laadintaPvm=' $1 | perl -pe 's/^.*met1\:laadintaPvm="([0-9]{4}\-[0-9]{2}\-[0-9]{2})".*$/$1/g; s/\-//g;'`
length=`printf "%s" "$datefrom" | wc -c`
if [ "$length" = "0" ]; then
    datefrom=$url_year"0101"
    dateto=$url_year"1231"
    echo "could not find date in file '"$1"', setting it to "$datefrom" - "$dateto" for output file '"$2"'..."
elif [ "$datefrom" = "21000101" ]; then
    datefrom=$url_year"0101"
    dateto=$url_year"1231"
    echo "date '2100-01-01' given in file '"$1"', setting it to "$datefrom" - "$dateto" for output file '"$2"'..."
elif [ "$length" -gt 8 -o "$length" -lt 8 ]; then
    echo "invalid date in file '"$1"' (output file '"$2"'), exiting..."
    exit 1
else
    dateto=$datefrom
fi


# add text tags around the output
echo '<text filename="'$2'" datefrom="'$datefrom'" dateto="'$dateto'" timefrom="000000" timeto="235959" url="'$url'">' > tmp
cat TMP >> tmp
echo "</text>" >> tmp
mv tmp $2
rm TMP

