#!/bin/sh

if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo ""
    echo "Usage: statute-generate-all-vrt-files.sh"
    echo "       [--fin|--swe] --ignore-dates --from-year YEAR --to-year YEAR --only-file FILE"
    echo ""
    echo "Purpose: generate a vrt file for each statute xml file."
    echo ""
    echo "Option --fin or --swe defines whether files in Finnish or Swedish"
    echo "are processed. Either option must be used."
    echo "If --from-year and --to-year are omitted, all years are processed."
    echo "If --only-file is used, only FILE is processed."
    echo ""
    echo "The script assumes that statutes for a given year YYYY and language"
    echo "(fi = Finnish, sv = Swedish) are in directory 'asd/[fi|sv]/YYYY'."
    echo ""
    echo "The script generates a *.vrt file for each *.xml file. During this,"
    echo "intermediary files named *.ext; *.punct; *.sent are also generated."
    echo "They must be manually removed from a distribution package."
    echo ""
    exit 0
fi

url_lang=""
dir_lang=""
from_year=""
to_year=""
only_file=""
only_vrt_step=""
ignore_dates="false"

for arg in "$@"
do
    if [ "$arg" = "--fin" ]; then
	url_lang="fin"
	dir_lang="fi"
    elif [ "$arg" = "--swe" ]; then
	url_lang="swe"
	dir_lang="sv"
    elif [ "$arg" = "--ignore-dates" ]; then
	ignore_dates="true"
    elif [ "$arg" = "--only-vrt-step" ]; then
	only_vrt_step="true"
    elif [ "$arg" = "--from-year" ]; then
	from_year="next..."
    elif [ "$arg" = "--to-year" ]; then
	to_year="next..."
    elif [ "$arg" = "--only-file" ]; then
	only_file="next..."
    elif [ "$from_year" = "next..." ]; then
	from_year=$arg
    elif [ "$to_year" = "next..." ]; then
	to_year=$arg
    elif [ "$only_file" = "next..." ]; then
	if ! (ls $arg > /dev/null 2> /dev/null); then
	    echo "Error: file '"$arg"' given with --only-file not found (full relative path must be given), exiting..."
	    exit 1
	fi
	only_file=$arg
    fi
done

if [ "$url_lang" = "" ]; then
    echo "Error: language must be defined with --fin or --swe."
    exit 1
fi


for dir in asd/${dir_lang}/*
do

    year=`echo $dir | perl -pe 's/(?:fi)|(?:sv)//; s/asd//; s/\///g'`
    if [ "$from_year" != "" ]; then
	if [ "$year" -lt "$from_year" ]; then
	    continue
	fi
    fi
    if [ "$to_year" != "" ]; then
	if [ "$year" -gt "$to_year" ]; then
	    continue
	fi
    fi

    for f in $dir/*.xml
    do

	if [ "$only_file" != "" ]; then
	    if [ "$only_file" != "$f" ]; then
		continue
	    fi
	fi	
    
	#prefile=`echo $f | perl -pe 's/\.xml/\.pre/'`
	extfile=`echo $f | perl -pe 's/\.xml/\.ext/'`
	punctfile=`echo $f | perl -pe 's/\.xml/\.punct/'`
	sentfile=`echo $f | perl -pe 's/\.xml/\.sent/'`
	vrtfile=`echo $f | perl -pe 's/\.xml/\.vrt/'`

	# use filename (without full path or file extension) as prefix for link ids
	link_prefix=`echo $f | rev | perl -pe 's/([^\/]+)\/.*/$1/;' | rev | perl -pe 's/\.xml/_/;'`

	if [ "$only_vrt_step" != "true" ]; then
	    echo "processing xml file "$f"..."

	    if ! (./statute-extract-text-and-add-links.pl --link-prefix $link_prefix < $f > $extfile); then
		echo "Error: in statute-extract-text-and-add-links.pl, exiting..."
		exit 1
	    fi
	    if ! (./statute-handle-punctuation.pl < $extfile > $punctfile); then
		echo "Error: in statute-handle-punctuation.pl, exiting..."
		exit 1
	    fi
	    if ! (./statute-add-sentence-tags.pl < $punctfile > $sentfile); then
		echo "Error: in statute-add-sentence-tags.pl, exiting..."
		exit 1
	    fi
	else
	    if (ls $sentfile > /dev/null 2> /dev/null); then
		echo "processing *.sent file "$sentfile"..."
	    else
		echo "No such file: "$sentfile", exiting...";
		exit 1
	    fi
	fi

	# extract year and statute number from the name of vrt file
	# TODO: urls work only for Finnish documents
	# TODO: some documents are not found in semantix finlex, basically files
	# that have a seven-digit statute number (e.g. asd19170125009.vrt).
	# Link to original finlex pages (e.g. https://www.finlex.fi/fi/laki/alkup/1917/19170125009) instead?
	url_year=`echo $vrtfile | perl -pe 's/.*asd([0-9][0-9][0-9][0-9]).*/$1/g;'`
	url_number=`echo $vrtfile | perl -pe 's/\.vrt//g; s/asd\/(fi|sv)\/[0-9][0-9][0-9][0-9]\///g; s/(s|t)$//g; s/asd[0-9][0-9][0-9][0-9]//g; s/^0+//g;'`

	url=""
	# if statute number is too long, leave the url field empty
	length=`printf "%s" "$url_number" | wc -c`
	if [ "$length" -gt 4 ]; then
	    url="";
	else
	    url="http://data.finlex.fi/eli/sd/"$url_year"/"$url_number"/alkup/"$url_lang".html"
	fi
	
	# extract date of document from xml file
	datefrom=`grep -m 1 'met1:laadintaPvm=' $f | perl -pe 's/^.*met1\:laadintaPvm="([0-9]{4}\-[0-9]{2}\-[0-9]{2})".*$/$1/g; s/\-//g;'`
	length=`printf "%s" "$datefrom" | wc -c`
	if [ "$length" = "0" ]; then
	    datefrom=$url_year"0101"
	    dateto=$url_year"1231"
	    if [ "$ignore_dates" = "false" ]; then
		echo "could not find date in file '"$f"', setting it to "$datefrom" - "$dateto" for output file '"$vrtfile"'..."
	    fi
	elif [ "$datefrom" = "21000101" ]; then
	    datefrom=$url_year"0101"
	    dateto=$url_year"1231"
	    if [ "$ignore_dates" = "false" ]; then
		echo "date '2100-01-01' given in file '"$f"', setting it to "$datefrom" - "$dateto" for output file '"$vrtfile"'..."
	    fi
	elif [ "$length" -gt 8 -o "$length" -lt 8 ]; then
	    echo "invalid date in file '"$f"' (output file '"$vrtfile"'), exiting..."
	    exit 1
	else
	    dateto=$datefrom
	fi
		
	# add text tags around the output
	echo '<text filename="'$vrtfile'" datefrom="'$datefrom'" dateto="'$dateto'" timefrom="000000" timeto="235959" url="'$url'">' > $vrtfile
	cat $sentfile >> $vrtfile
	echo "</text>" >> $vrtfile

    done 

done
