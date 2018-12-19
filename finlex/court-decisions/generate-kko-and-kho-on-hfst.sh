#!/bin/sh

# rm -fR data pkgs registry vrt
# mkdir registry

username=
KORP_MAKE="/home/"${username}"/Kielipankki-konversio/scripts/korp-make"
input_attributes=""
export CWB_BINDIR=/usr/local/cwb-3.4.12/bin/

if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo ""
    echo "Usage: generate-kko-and-kho-on-hfst.sh [--kko|--kho] [--fin|--swe] [--separate-years]"
    echo ""
    echo "Note: you must have generated all vrt files with court-generate-all-vrt-files.sh."
    echo ""
    exit 0
fi

dir_lang=""
court=""
years=""
separate_years="false"

for arg in "$@"
do
    if [ "$arg" = "--fin" ]; then
	dir_lang="fi"
    elif [ "$arg" = "--swe" ]; then
	dir_lang="sv"
    elif [ "$arg" = "--kko" ]; then
	court="kko"
    elif [ "$arg" = "--kho" ]; then
	court="kho"
    elif [ "$arg" = "--separate-years" ]; then
	separate_years="true"
    fi
done

if [ "$dir_lang" = "" ]; then
    echo "Error: language must be defined with --fin or --swe."
    exit 1
fi

if [ "$court" = "" ]; then
    echo "Error: court must be defined with --kko or --kho."
    exit 1
fi

if [ "$court" = "kho" ]; then
    if [ "$dir_lang" = "fi" ]; then
	years=`seq 1987 2017`
    elif [ "$dir_lang" = "sv" ]; then
	years=`seq 2001 2017`
    else
	echo "Error: language '"$dir_lang"' not recognized."
	exit 1
    fi
elif [ "$court" = "kko" ]; then
    years=`seq 1980 2017`
else
    echo "Error: court '"$court"' not recognized."
    exit 1    
fi


corpus_root="/data/"${username}"/"${court}"/sf-data/orig/"${court}
corpusdir="/usr/lib/cgi-bin/corpora"
c=$(echo ${corpusdir} | perl -pe 's/\//\\\//g;')

if [ "$separate_years" = "true" ]; then
    for year in ${years}
    do
	
	echo "processing vrt files for year "$year"..."
	corpusname=${court}"_"${year}"_"${dir_lang}
	
	if ! (${KORP_MAKE} --corpus-root=${corpus_root} --log-file=log --no-lemgrams --no-logging --verbose --input-attributes "$input_attributes" ${corpusname} ${dir_lang}/${year}/*.vrt); then
	    echo "Error in korp-make, exiting..."
	    exit 1
	fi
	
	perl -i -pe 's/^HOME .*/HOME '${c}'\/data\/'${corpusname}'/;' registry/${corpusname}
	perl -i -pe 's/^INFO .*/INFO '${c}'\/data\/'${corpusname}'\/\.info/;' registry/${corpusname}
	
    done
else
    
    echo "processing vrt files for all years..."
    corpusname=${court}"_"${dir_lang}
    
    if ! (${KORP_MAKE} --corpus-root=${corpus_root} --log-file=log --no-lemgrams --no-logging --verbose --input-attributes "$input_attributes" ${corpusname} ${dir_lang}/*/*.vrt); then
	echo "Error in korp-make, exiting..."
	exit 1
    fi
        
    perl -i -pe 's/^HOME .*/HOME '${c}'\/data\/'${corpusname}'/;' registry/${corpusname}
    perl -i -pe 's/^INFO .*/INFO '${c}'\/data\/'${corpusname}'\/\.info/;' registry/${corpusname}

fi

