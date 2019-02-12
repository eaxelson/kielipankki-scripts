#!/bin/sh

path="."
if [ "$1" = "--script-path" ]
then
    path="$2"
fi

if !(ls $path/finlex-preprocess.pl > /dev/null 2> /dev/null)
then
    echo "finlex-preprocess not found (path can be given with --script-path), exiting"
    exit 1
fi

for file in asd/*/*/*.xml kko/*/*/*.xml kho/*/*/*.xml
do
    echo $file
    $path/finlex-preprocess.pl < $file > tmp
    mv tmp $file
done
