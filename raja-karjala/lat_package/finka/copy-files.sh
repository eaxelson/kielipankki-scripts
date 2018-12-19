#!/bin/sh

for Place in Ilomantsi Impilahti Korpiselka Salmi Suistamo Suojarvi;
do
    place=`echo $Place | tr 'A-Z' 'a-z'`
    for ext in wav m4a;
    do
	for file in `ls /wrk/axelson/Raja-Karjalan_korpus_lat/$Place/${place}_wav/*.$ext`; do
	    dir=`echo $file | perl -pe 's/.*('$Place'[^\/]*)_SKNA.*\.'$ext'/$1/g;'`
	    echo "cp $file $Place/$dir/"
	done
    done

    for file in `ls /wrk/axelson/Raja-Karjalan_korpus_lat/$Place/${place}_textgrid/*.TextGrid`; do
	dir=`echo $file | perl -pe 's/.*('$Place'[^\/]*)_SKNA.*\.TextGrid/$1/g;'`
	echo "cp $file $Place/$dir/"
    done

done
