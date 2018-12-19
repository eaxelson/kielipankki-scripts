#!/bin/sh

for file in `cat fullnames`;
do
    dir=`echo $file | perl -pe 's/(.*)_SKNA_.*/finka\/$1/g; s/\/[^\/]*_wav//g;'`
    filename=`echo $file | perl -pe 's/.*\/(.*)\.wav/$1/g;'`
    imdifile=`echo $dir".imdi"`
    directory=`echo $imdifile | perl -pe 's/.*\/(.*)\.imdi/$1/g;'`
    # echo $imdifile $directory $filename
    echo "cat template.imdi | perl -pe 's/{DIRECTORY}/'$directory'/g; s/{FILENAME}/'$filename'/g;' > $imdifile"
done
