#!/bin/sh

echo group:
cat $1 | grep '<paragraph' | grep 'group="' | perl -pe 's/.*group="([^"]+)".*/\1/;' | sort | uniq -c | sort -nr
echo role:
cat $1 | grep '<paragraph' | grep 'role="' | perl -pe 's/.*role="([^"]+)".*/\1/;' | sort | uniq -c | sort -nr
echo type:
cat $1 | grep '<paragraph' | grep 'type="' | perl -pe 's/.*type="([^"]+)".*/\1/;' | sort | uniq -c | sort -nr
