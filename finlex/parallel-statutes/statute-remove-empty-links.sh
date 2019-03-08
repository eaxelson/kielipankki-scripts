#!/bin/sh

# Read VRT from standard input and remove all link tags
# that contain nothing and write the result to standard output.
# The input comes by default from statute-extract-text-and-add-links.pl.

perl -pe 's/([^<-])>\n/$1>/g;' | perl -pe 's/<link[^>]*><\/link>//g;' | perl -pe 's/([^<-])>/$1>\n/g;'
