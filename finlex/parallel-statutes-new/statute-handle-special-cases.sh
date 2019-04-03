perl -pe 's/<viite>(.*)<\/viite>/<paragraph type="VIITE">\1<\/paragraph>/;';
perl -pe 's/(<saa:Pykala>)(.*)(<\/saa:Pykala>)/\1<paragraph type="paragraph">\2<\/paragraph>\3/;'
statute-handle-johtl.pl
wc -c # if empty rename to *.xml.empty (this should be done earlier)
