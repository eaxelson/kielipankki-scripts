#!/bin/sh

KORP_MAKE="/home/eaxelson/Kielipankki-konversio/scripts/korp-make"
KORP_MAKE_CORPUS_PACKAGE="/home/eaxelson/Kielipankki-konversio/scripts/korp-make-corpus-package.sh"
input_attributes=""
export CWB_BINDIR=/usr/local/cwb-3.4.12/bin/

if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo ""
    echo "Usage: statute-generate-test-corpora.sh FISTATUTE SVSTATUTE"
    echo ""
    echo "Note: you must have generated all vrt files with statute-generate-all-vrt-files.sh."
    echo ""
    exit 0
fi

corpus_root="/data/eaxelson/finlex-preprocessed"
corpusdir="/usr/lib/cgi-bin/corpora"
c=$(echo ${corpusdir} | perl -pe 's/\//\\\//g;')

# 1)
if ! (${KORP_MAKE} --no-package --corpus-root=${corpus_root} --log-file=log --no-lemgrams --no-logging --verbose --input-attributes "$input_attributes" test_asd_fi $1); then
    echo "Error in korp-make, exiting..."
    exit 1
fi
if ! (${KORP_MAKE} --no-package --corpus-root=${corpus_root} --log-file=log --no-lemgrams --no-logging --verbose --input-attributes "$input_attributes" test_asd_sv $2); then
    echo "Error in korp-make, exiting..."
    exit 1
fi

for corpusname in "test_asd_fi" "test_asd_sv";
do
    perl -i -pe 's/^HOME .*/HOME '${c}'\/data\/'${corpusname}'/;' registry/${corpusname}
    perl -i -pe 's/^INFO .*/INFO '${c}'\/data\/'${corpusname}'\/\.info/;' registry/${corpusname}
done

for corpusname in "test_asd_fi" "test_asd_sv";
do
    cp -R ./data/${corpusname} ${corpusdir}/data/
    cp ./registry/${corpusname} ${corpusdir}/registry/
done

# 2)
${CWB_BINDIR}/cwb-align -v -r ${corpusdir}/registry -o test_asd_fi_sv.align -V link_id test_asd_fi test_asd_sv link
${CWB_BINDIR}/cwb-align -v -r ${corpusdir}/registry -o test_asd_sv_fi.align -V link_id test_asd_sv test_asd_fi link

# 3)
/home/eaxelson/perl5/bin/cwb-regedit -r ${corpusdir}/registry test_asd_fi :add :a test_asd_sv
/home/eaxelson/perl5/bin/cwb-regedit -r ${corpusdir}/registry test_asd_sv :add :a test_asd_fi

# 4)
${CWB_BINDIR}/cwb-align-encode -v -r ${corpusdir}/registry -D test_asd_fi_sv.align
${CWB_BINDIR}/cwb-align-encode -v -r ${corpusdir}/registry -D test_asd_sv_fi.align

# 5)
${KORP_MAKE_CORPUS_PACKAGE} --target-corpus-root ${corpusdir} --corpus-root=${corpus_root} --database-format tsv --include-vrt-dir test_asd test_asd_fi test_asd_sv
