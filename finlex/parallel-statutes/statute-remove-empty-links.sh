#!/bin/sh

perl -pe 's/([^<-])>\n/$1>/g;' | perl -pe 's/<link[^>]*><\/link>//g;' | perl -pe 's/([^<-])>/$1>\n/g;'
