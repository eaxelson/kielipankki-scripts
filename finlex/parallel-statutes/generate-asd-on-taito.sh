#!/bin/sh
# PATH=$PATH:/proj/clarin/korp/cwb/bin:/proj/clarin/korp/scripts
registrydir="/proj/clarin/korp/corpora/registry"
corpusrootdir="/proj/clarin/korp/corpora"
corpusname="test_asd"
sourcedir="asd"
korp-make --corpus-root=$corpusrootdir --log-file=log --no-lemgrams --no-logging --verbose --input-attributes "" ${corpusname}_fi ${sourcedir}/fi/*/*.vrt
korp-make --corpus-root=$corpusrootdir --log-file=log --no-lemgrams --no-logging --verbose --input-attributes "" ${corpusname}_sv ${sourcedir}/sv/*/*.vrt
