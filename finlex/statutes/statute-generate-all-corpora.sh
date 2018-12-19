#!/bin/sh

KORP_MAKE="/home/eaxelson/Kielipankki-konversio/scripts/korp-make"
input_attributes=""
export CWB_BINDIR=/usr/local/cwb-3.4.12/bin/

if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo ""
    echo "Usage: statute-generate-all-corpora.sh [--fin|--swe] [--separate-years]"
    echo ""
    echo "Note: you must have generated all vrt files with statute-generate-all-vrt-files.sh."
    echo ""
    exit 0
fi

dir_lang=""
years=""
separate_years="false"
court="asd"

for arg in "$@"
do
    if [ "$arg" = "--fin" ]; then
	dir_lang="fi"
	years=`ls fi`
    elif [ "$arg" = "--swe" ]; then
	dir_lang="sv"
	years=`ls sv`
    elif [ "$arg" = "--separate-years" ]; then
	separate_years="true"
    fi
done

if [ "$dir_lang" = "" ]; then
    echo "Error: language must be defined with --fin or --swe."
    exit 1
fi


corpus_root="/data/eaxelson/"${court}"/sf-data/orig/"${court}
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

