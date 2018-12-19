Raja-Karjalan korpus:

Fetched from IDA (ida/sa/clarin/corpora/Raja-Karjalan_korpus/Raja-Karjalan_korpus.zip).

Edited version:

# Lower sample frequency:
for f in */*/*.wav; do ffmpeg -i $f -ar 22050 output.wav && mv --force output.wav $f; done

# "Using AVStream.codec.time_base as a timebase hint to the muxer is deprecated. Set AVStream.time_base instead."?

# For each .wav file, offer a .m4a version:
for f in */*/*.wav; do ffmpeg -i $f -c:a libfdk_aac -vbr 1 `echo $f | perl -pe 's/\.wav/\.m4a/;'`; done

# [libfdk_aac @ 0x1f97380] Note, the VBR setting is unsupported and only works with some parameter combinations
# [ipod @ 0x1f96420] Using AVStream.codec.time_base as a timebase hint to the muxer is deprecated. Set AVStream.time_base instead.

# Get rid of lowest tier named "original" from TextGrid files: not needed

# Convert TextGrid files from UTF-16 to UTF-8:
for f in */*/*.TextGrid; do iconv -f UTF-16 -t UTF-8 $f -o tmp && mv --force tmp $f; done

# Change non-ascii characters in file names/paths to ascii, i.e. ÄÖäö -> AOao
