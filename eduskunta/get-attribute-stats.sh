#!/bin/sh

for attr in group role type
do
    echo $attr:
    cat $1 | grep '<paragraph' | grep $attr'="' | perl -pe 's/.*'$attr'="([^"]*)".*/\1/;' | sort | uniq -c | sort -nr
done
echo ""
echo speaker:
cat $1 | grep '<paragraph' | grep 'speaker="' | perl -pe 's/.*speaker="([^"]*)".*/\1/;' | sort | uniq -c | sort -nr
