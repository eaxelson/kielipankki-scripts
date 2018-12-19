#!/bin/sh
# PATH=$PATH:/proj/clarin/korp/cwb/bin:/proj/clarin/korp/scripts
registrydir="/proj/clarin/korp/corpora/registry"
corpusrootdir="/proj/clarin/korp/corpora"
corpusname="test_asd_par"
sourcedir="asd_par"
korp-make --no-package --corpus-root=$corpusrootdir --log-file=log --no-lemgrams --no-logging --verbose --input-attributes "" ${corpusname}_fi ${sourcedir}/fi/*/*.vrt
korp-make --no-package --corpus-root=$corpusrootdir --log-file=log --no-lemgrams --no-logging --verbose --input-attributes "" ${corpusname}_sv ${sourcedir}/sv/*/*.vrt
cwb-align -v -r $registrydir -o ${corpusname}_fi_sv.align -V link_id ${corpusname}_fi ${corpusname}_sv link
cwb-align -v -r $registrydir -o ${corpusname}_sv_fi.align -V link_id ${corpusname}_sv ${corpusname}_fi link
cwb-regedit -r $registrydir ${corpusname}_fi :add :a ${corpusname}_sv
cwb-regedit -r $registrydir ${corpusname}_sv :add :a ${corpusname}_fi
cwb-align-encode -v -r $registrydir -D ${corpusname}_fi_sv.align
cwb-align-encode -v -r $registrydir -D ${corpusname}_sv_fi.align
korp-make-corpus-package.sh --target-corpus-root=/v/corpora --corpus-root=$corpusrootdir --database-format tsv --include-vrt-dir ${corpusname} ${corpusname}_fi ${corpusname}_sv
