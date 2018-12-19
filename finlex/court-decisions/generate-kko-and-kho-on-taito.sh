#!/bin/sh
# PATH=$PATH:/proj/clarin/korp/cwb/bin:/proj/clarin/korp/scripts
registrydir="/proj/clarin/korp/corpora/registry"
corpusrootdir="/proj/clarin/korp/corpora"

for court in kko kho;
do
    korp-make --corpus-root=$corpusrootdir --log-file=log --no-lemgrams --no-logging --verbose --input-attributes "" test_${court}_fi ${court}/fi/*/*.vrt
    korp-make --corpus-root=$corpusrootdir --log-file=log --no-lemgrams --no-logging --verbose --input-attributes "" test_${court}_sv ${court}/sv/*/*.vrt
done
