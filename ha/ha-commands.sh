# With CWB tools:
#
# /usr/local/cwb-3.4.12/bin/cwb-encode -s -p - -d corpora/data/ha -R corpora/registry/ha -x -c utf8 -f story_of_a_king.vrt -P word -P morph -P gloss -P pos -S sentence:0+n -S text:0+title+date+datefrom+dateto+timefrom+timeto
# /usr/local/cwb-3.4.12/bin/cwb-makeall -V -r corpora/registry HA

# With Kielipankki tools:
#
# export CWB_BINDIR=/usr/local/cwb-3.4.12/bin/
# mkdir registry
# ~/Kielipankki-konversio/scripts/korp-make --log-file=log --corpus-root=/home/eaxelson/HA_orig_20170809/HA_orig_20170809 --tsv-dir=/home/eaxelson/HA_orig_20170809/HA_orig_20170809 --no-lemgrams --no-logging --verbose --input-attributes "lemma morph gloss pos" ha_stories ha_stories.vrt

# <text filename="ha_stories.vrt" datefrom="20021212" dateto="20040709" timefrom="000000" timeto="235959"> ... </text>

# python ./sfm2vrt.py kitxtall_preprocessed.txt foo
# ./postprocess-ha-whitespace-and-punctuation.pl < foo > bar
# ./postprocess-ha-add-lemmas.pl < bar > baz
# mv baz ha_stories.vrt

# sudo cp -R data/ha_stories/* /usr/lib/cgi-bin/corpora/data/ha_stories/
# sudo cp -R registry/ha_stories /usr/lib/cgi-bin/corpora/registry/ha_stories



# TESTING:
# ~/Kielipankki-konversio/scripts/korp-make --log-file=log --corpus-root=/home/eaxelson/HA_orig_20170809/HA_orig_20170809 --tsv-dir=/home/eaxelson/HA_orig_20170809/HA_orig_20170809 --no-lemgrams --no-logging --verbose --input-attributes "pos" testcorpus_korp testcorpus.vrt

# On Taito:
# iconv -f ISO-8859-1 -t utf-8 < ha_stories.vrt > output
# PATH=$PATH:/proj/clarin/korp/cwb/bin:/proj/clarin/korp/scripts
# korp-make --input-attributes "lemma morph gloss pos" ha_stories ha_stories.vrt

# git checkout -b ha
# git push -u origin ha

# Before:
# Remove carriage returns: sed -i $'s/\r//'
# Remove empty lines: sed -i '/^\s*$/d'

# After: run postprocess-ha-whitespace-and-punctuation.pl on VRTFILE
# and then postprocess-ha-add-lemmas.pl.
# Also add <text filename="" title="" datefrom="YYYYMMDD" dateto="YYYYMMDD">
# ... </text> tags around the file.
