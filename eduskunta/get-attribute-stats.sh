#!/bin/sh

for attr in group role type
do
    echo $attr:
    cat $1 | grep '<paragraph' | grep $attr'="' | perl -pe 's/.*'$attr'="([^"]+)".*/\1/;' | sort | uniq -c | sort -nr
done
echo participant:
cat $1 | grep '<paragraph' | grep 'participant="' | perl -pe 's/.*participant="([^"]*)".*/\1/;' | sort | uniq -c | sort -nr
