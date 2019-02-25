#!/bin/sh

if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo ""
    echo "Usage: court-process-xml-to-vrt.sh XMLFILE VRTFILE [--datefrom DATE] [--dateto DATE] [--kko|--kho] [--fin|--swe] --script-path PATH"
    echo ""
    exit 0
fi

datefrom=""
dateto=""
url_lang=""
court=""
path="."

for arg in "$@"
do
    if [ "$datefrom" = "next..." ]; then
	datefrom=$arg
    elif [ "$dateto" = "next..." ]; then
	dateto=$arg
    elif [ "$path" = "next..." ]; then
	path=$arg
    elif [ "$arg" = "--datefrom" ]; then
	datefrom="next..."
    elif [ "$arg" = "--dateto" ]; then
	dateto="next..."
    elif [ "$arg" = "--script-path" ]; then
	path="next..."
    elif [ "$arg" = "--fin" ]; then
	url_lang="fin"
    elif [ "$arg" = "--swe" ]; then
	url_lang="swe"
    elif [ "$arg" = "--kko" ]; then
	court="kko"
    elif [ "$arg" = "--kho" ]; then
	court="kho"
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


cp $1 tmp

if ! (cat tmp | $path/court-extract-text.pl > TMP); then
    echo "Error: in court-extract-text.pl("$1", "$2"), exiting..."
    exit 1
fi
$path/court-handle-punctuation.pl < TMP > tmp
if ! ($path/court-add-sentence-tags.pl < tmp > TMP); then
    echo "Error: in court-add-sentence-tags.pl("$1", "$2"), exiting..."
    exit 1
fi

rm tmp


url_year=`echo $1 | perl -pe 's/.*'${court}'([0-9][0-9][0-9][0-9]).*/$1/g;'`
url_number=""

# TODO: urls work only for Finnish documents
if [ "$court" = "kko" ]; then
    url_number=`echo $1 | perl -pe 's/\.xml//g; s/kko\/(fi|sv)\/[0-9][0-9][0-9][0-9]\///g; s/(s|t)$//g; s/'${court}'[0-9][0-9][0-9][0-9]//g; s/^0+//g;'`
    # For years until 1986, there is "II" in the urls for KKO decisions
    if [ "$url_year" -lt "1987" ]; then
	url_number="II"$url_number
    fi
elif [ "$court" = "kho" ]; then
    # <finlex:ecliIdentifier>ECLI:FI:KHO:1987:B659</finlex:ecliIdentifier>
    # url_number=`grep -m 1 '<finlex:ecliIdentifier' $1 | perl -pe 's/.*<finlex\:ecliIdentifier>.*\:(T?[0-9]+)<\/finlex\:ecliIdentifier>.*/$1/g;'`
    url_number=`grep -m 1 '<finlex:ecliIdentifier' $1 | perl -pe 's/[^<]*<finlex\:ecliIdentifier>[^<]*\:(.?[0-9]+)<\/finlex\:ecliIdentifier>.*/$1/g;'`
    length=`printf "%s" "$url_number" | wc -c`
    if [ "$length" -gt 5 ]; then
	echo "invalid ecli identifier field in file '"$1"', setting it to empty value"
	url_number=''
    fi
fi

url="http://data.finlex.fi/ecli/"$court"/"$url_year"/"$url_number"/"$url_lang".html"

if [ "$datefrom" = "" -a "$dateto" = "" ]; then
    datefrom=`grep -m 1 '<dcterms:issued' $1 | perl -pe 's/.*<dcterms\:issued( +pvm=\"[0-9]+\" *)?\>([^<]*)<.*/$2/g; s/\-//g;'`
    length=`printf "%s" "$datefrom" | wc -c`
    if [ "$length" = "0" ]; then
	datefrom=$url_year"0101"
	dateto=$url_year"1231"
	echo "could not find date in file '"$1"', setting it to "$datefrom" - "$dateto"..."
    elif [ "$length" -gt 8 -o "$length" -lt 8 ]; then
	datefrom=$url_year"0101"
	dateto=$url_year"1231"
	echo "invalid date in file '"$1"', setting it to "$datefrom" - "$dateto"..."
    else
	dateto=$datefrom
    fi
fi

echo '<text filename="'$2'" datefrom="'$datefrom'" dateto="'$dateto'" timefrom="000000" timeto="235959" url="'$url'">' > tmp
cat TMP >> tmp
echo "</text>" >> tmp
mv tmp $2
rm TMP
