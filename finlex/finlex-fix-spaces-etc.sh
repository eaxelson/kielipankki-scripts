#!/bin/sh

path="."
if [ "$1" = "--script-path" ]
then
    path="$2"
fi

if !(ls $path/finlex-fix-spaces-etc.pl > /dev/null 2> /dev/null)
then
    echo "perl script finlex-fix-spaces-etc.pl not found (path can be given with --script-path), exiting"
    exit 1
fi

for file in asd/*/*/*.xml kko/*/*/*.xml kho/*/*/*.xml
do
    echo $file
    $path/finlex-fix-spaces-etc.pl < $file > tmp
    mv tmp $file
done
