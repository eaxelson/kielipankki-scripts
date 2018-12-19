#!/bin/sh
username="username"
KORP_DIR="/home/$username/Kielipankki-konversio/scripts"
export CWB_BINDIR=/usr/local/cwb-3.4.12/bin/
registrydir="/data/$username/test-parallel-finlex/registry"
corpusdir="/data/$username/test-parallel-finlex"
targetdir="/usr/lib/cgi-bin/corpora"

$KORP_DIR/korp-make --no-package --no-lemgrams --no-logging --verbose --input-attributes "" --corpus-root=$corpusdir test_asd_1980_fi test_asd_1980_fi.vrt
$KORP_DIR/korp-make --no-package --no-lemgrams --no-logging --verbose --input-attributes "" --corpus-root=$corpusdir test_asd_1980_sv test_asd_1980_sv.vrt

$CWB_BINDIR/cwb-align -v -r $registrydir -o test_asd_1980_fi_sv.align -V link_id test_asd_1980_fi test_asd_1980_sv link
$CWB_BINDIR/cwb-align -v -r $registrydir -o test_asd_1980_sv_fi.align -V link_id test_asd_1980_sv test_asd_1980_fi link

/usr/local/bin/cwb-regedit -r $registrydir test_asd_1980_fi :add :a test_asd_1980_sv
/usr/local/bin/cwb-regedit -r $registrydir test_asd_1980_sv :add :a test_asd_1980_fi

$CWB_BINDIR/cwb-align-encode -v -r $registrydir -D test_asd_1980_fi_sv.align
$CWB_BINDIR/cwb-align-encode -v -r $registrydir -D test_asd_1980_sv_fi.align
# both give "I skipped 0 0:1 alignments and 0 1:0 alignments.", this shouldn't be a problem

$KORP_DIR/korp-make-corpus-package.sh -r $registrydir --target-corpus-root $targetdir --corpus-root=$corpusdir --database-format tsv --include-vrt-dir test_asd_1980 test_asd_1980_fi test_asd_1980_sv
# Created corpus package /data/username/test-parallel-finlex/pkgs/test_asd_1980/test_asd_1980_korp_20180503.tgz

# fix paths, something like (corpusdir is for example "usr/lib/cgi-bin/corpora")

# copy generated files, something like:
sudo cp registry/* /usr/lib/cgi-bin/corpora/registry/
sudo cp -R data/* /usr/lib/cgi-bin/corpora/data/
