
for file in Iijoki-sarja/*.txt:
  ./insert-part-chapter-section-and-paragraph-markers.pl
  python3 full_pipeline_stream.py --gpu -1 --conf models_fi_tdt/pipelines.yaml parse_plaintext
  head -n -6 | ./conllu-to-vrt.pl # skip 6 last lines to get rid of "TNPP_INPUT_CANNOT_END_IN_COMMENT_LINE"
  (vrt-validate)

conllu-to-vrt commands:
-----------------------

cat $conllu_dir/001_Huonemiehen_poika.conllu | head -n -6 | ./conllu-to-vrt.pl "Huonemiehen poika" 1971 001_Huonemiehen_poika.txt > $vrt_dir/001_Huonemiehen_poika.vrt
cat $conllu_dir/002_Tammettu_virta.conllu | head -n -6 | ./conllu-to-vrt.pl "Tammettu virta" 1972 002_Tammettu_virta.txt > $vrt_dir/002_Tammettu_virta.vrt
cat $conllu_dir/003_Kunnan_jauhot.conllu | head -n -6 | ./conllu-to-vrt.pl "Kunnan jauhot" 1973 003_Kunnan_jauhot.txt > $vrt_dir/003_Kunnan_jauhot.vrt
cat $conllu_dir/004_Taysi_tuntiraha.conllu | head -n -6 | ./conllu-to-vrt.pl "Täysi tuntiraha" 1974 004_Taysi_tuntiraha.txt > $vrt_dir/004_Taysi_tuntiraha.vrt
cat $conllu_dir/005_Nuoruuden_savotat.conllu | head -n -6 | ./conllu-to-vrt.pl "Nuoruuden savotat" 1975 005_Nuoruuden_savotat.txt > $vrt_dir/005_Nuoruuden_savotat.vrt
cat $conllu_dir/006_Loimujen_aikaan.conllu | head -n -6 | ./conllu-to-vrt.pl "Loimujen aikaan" 1976 006_Loimujen_aikaan.txt > $vrt_dir/006_Loimujen_aikaan.vrt
cat $conllu_dir/007_Ahdistettu_maa.conllu | head -n -6 | ./conllu-to-vrt.pl "Ahdistettu maa" 1977 007_Ahdistettu_maa.txt > $vrt_dir/007_Ahdistettu_maa.vrt
cat $conllu_dir/008_Miinoitettu_rauha.conllu | head -n -6 | ./conllu-to-vrt.pl "Miinoitettu rauha" 1978 008_Miinoitettu_rauha.txt > $vrt_dir/008_Miinoitettu_rauha.vrt
cat $conllu_dir/009_Ukkosen_aani.conllu | head -n -6 | ./conllu-to-vrt.pl "Ukkosen ääni" 1979 009_Ukkosen_aani.txt > $vrt_dir/009_Ukkosen_aani.vrt
cat $conllu_dir/010_Liekkeja_laulumailla.conllu | head -n -6 | ./conllu-to-vrt.pl "Liekkejä laulumailla" 1980 010_Liekkeja_laulumailla.txt > $vrt_dir/010_Liekkeja_laulumailla.vrt
cat $conllu_dir/011_Tuulessa_ja_tuiskussa.conllu | head -n -6 | ./conllu-to-vrt.pl "Tuulessa ja tuiskussa" 1981 011_Tuulessa_ja_tuiskussa.txt > $vrt_dir/011_Tuulessa_ja_tuiskussa.vrt
cat $conllu_dir/012_Tammerkosken_sillalla.conllu | head -n -6 | ./conllu-to-vrt.pl "Tammerkosken sillalla" 1982 012_Tammerkosken_sillalla.txt > $vrt_dir/012_Tammerkosken_sillalla.vrt
cat $conllu_dir/013_Pohjalta_ponnistaen.conllu | head -n -6 | ./conllu-to-vrt.pl "Pohjalta ponnistaen" 1983 013_Pohjalta_ponnistaen.txt > $vrt_dir/013_Pohjalta_ponnistaen.vrt
cat $conllu_dir/014_Nuorikkoa_nayttamassa.conllu | head -n -6 | ./conllu-to-vrt.pl "Nuorikkoa näyttämässä" 1984 014_Nuorikkoa_nayttamassa.txt > $vrt_dir/014_Nuorikkoa_nayttamassa.vrt
cat $conllu_dir/015_Nouseva_maa.conllu | head -n -6 | ./conllu-to-vrt.pl "Nouseva maa" 1985 015_Nouseva_maa.txt > $vrt_dir/015_Nouseva_maa.vrt
cat $conllu_dir/016_Ratkaisujen_aika.conllu | head -n -6 | ./conllu-to-vrt.pl "Ratkaisujen aika" 1986 016_Ratkaisujen_aika.txt > $vrt_dir/016_Ratkaisujen_aika.vrt
cat $conllu_dir/017_Pyynikin_rinteessa.conllu | head -n -6 | ./conllu-to-vrt.pl "Pyynikin rinteessä" 1987 017_Pyynikin_rinteessa.txt > $vrt_dir/017_Pyynikin_rinteessa.vrt
cat $conllu_dir/018_Reissutyossa.conllu | head -n -6 | ./conllu-to-vrt.pl "Reissutyössä" 1988 018_Reissutyossa.txt > $vrt_dir/018_Reissutyossa.vrt
cat $conllu_dir/019_Oman_katon_alle.conllu | head -n -6 | ./conllu-to-vrt.pl "Oman katon alle" 1989 019_Oman_katon_alle.txt > $vrt_dir/019_Oman_katon_alle.vrt
cat $conllu_dir/020_Iijoen_kutsu.conllu | head -n -6 | ./conllu-to-vrt.pl "Iijoen kutsu" 1990 020_Iijoen_kutsu.txt > $vrt_dir/020_Iijoen_kutsu.vrt
cat $conllu_dir/021_Muuttunut_selkonen.conllu | head -n -6 | ./conllu-to-vrt.pl "Muuttunut selkonen" 1991 021_Muuttunut_selkonen.txt > $vrt_dir/021_Muuttunut_selkonen.vrt
cat $conllu_dir/022_Epatietoisuuden_talvi.conllu | head -n -6 | ./conllu-to-vrt.pl "Epätietoisuuden talvi" 1992 022_Epatietoisuuden_talvi.txt > $vrt_dir/022_Epatietoisuuden_talvi.vrt
cat $conllu_dir/023_Iijoelta_etelaan.conllu | head -n -6 | ./conllu-to-vrt.pl "Iijoelta etelään" 1993 023_Iijoelta_etelaan.txt > $vrt_dir/023_Iijoelta_etelaan.vrt
cat $conllu_dir/024_Pato_murtuu.conllu | head -n -6 | ./conllu-to-vrt.pl "Pato murtuu" 1994 024_Pato_murtuu.txt > $vrt_dir/024_Pato_murtuu.vrt
cat $conllu_dir/025_Hyvasti_Iijoki.conllu | head -n -6 | ./conllu-to-vrt.pl "Hyvästi Iijoki" 1995 025_Hyvasti_Iijoki.txt > $vrt_dir/025_Hyvasti_Iijoki.vrt
cat $conllu_dir/026_Polhokanto_Iijoen_tormassa.conllu | head -n -6 | ./conllu-to-vrt.pl "Pölhökanto Iijoen törmässä" 1998 026_Polhokanto_Iijoen_tormassa.txt > $vrt_dir/026_Polhokanto_Iijoen_tormassa.vrt