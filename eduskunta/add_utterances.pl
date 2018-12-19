#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

# first change <text filename="YYYY_NNN.eaf" into <text filename="YYYY-MM-DD.vrt"
# see https://github.com/eaxelson/fin-clarin-misc/wiki/Eduskunta for creating all-info.txt 
# (or use https://github.com/eaxelson/fin-clarin-misc/blob/master/eduskunta/all-info.txt)
# and further process it with
# cat all-info.txt | cut -f1,6 | perl -pe 's/^([0-9]{2}\t)/0$1/; s/^([0-9]\t)/00$1/; s/([0-9]{1,3}\t)([0-9]{4})(.*)/$2_$1$2$3/;'
# to get all replacements in tab-separated format

my $utterance_number = 0;
my $sentence = "";
my $previous_line = "";

my $begin_time = 0;
my $end_time = 0;
my $duration = 0;

my $korp_url = 'https://korp.csc.fi/eduskunta/';
my $filename = "";
my $year = "";
my $month = "";
my $day = "";
my $season = "";

foreach my $line ( <STDIN> )
{
    # get begin time
    if ($previous_line eq "<sentence>\n")
    {
	$begin_time = $line;
	$begin_time =~ s/[^\t]+\t[^\t]+\t[^\t]+\t[^\t]+\t([^\t]+)\t.*/$1/g;
	chomp $begin_time;
    }

    # just print tags other than sentence and continue, get filename from text tag
    if ($line =~ /^<\/?paragraph/ || $line =~ /^<\/?text/)
    {
	print $line;
	$previous_line = $line;
	
	if ($line =~ /^<text/)
	{
	    $filename = $line;
	    $filename =~ s/<text filename="([^"]+)".*/$1/; # extract filename
	    $filename =~ s/\..*//; # get rid of possible extension in filename

	    # extract year, month and day
	    $year = $filename;
	    $year =~ s/(....)-..-../$1/;
	    $month = $filename;
	    $month =~ s/....-(..)-../$1/;
	    $day = $filename;
	    $day =~ s/....-..-(..)/$1/;
	    
	    chomp $year; chomp $month; chomp $day; chomp $filename;

	    # extract season
	    if ($month =~ /0[1-7]/)
	    {
		$season = 'kevat';
	    }
	    else
	    {
		$season = 'syksy';
	    }
	}
	next;
    }
    
    # get end time, calculate duration, print utterance tag and whole sentence
    if ($line eq "</sentence>\n")
    {
	$end_time = $previous_line;
	$end_time =~ s/[^\t]+\t[^\t]+\t[^\t]+\t[^\t]+\t[^\t]+\t([^\t]+)\t.*/$1/g;
	chomp $end_time;
	$duration = $end_time - $begin_time;
	$sentence .= $line;
	my $dir = $year . '-' . $season;
	my $annex_link = 'extAnno=' . $korp_url . $dir . '/Annotations/' . $filename . '.eaf&extMedia=' . $korp_url . $dir . '/Media/' . $filename . '.mp4&amp;time=' . $begin_time . '&amp;duration=' . $duration;
	my $utterance = '<utterance participant="NN" annex_link="' . $annex_link . '" end_time="' . $end_time . '" begin_time="' . $begin_time . '" duration="' . $duration . '" id="' . ++$utterance_number . '"' . ">\n";
	print $utterance;
	print $sentence;
	print "</utterance>\n";
	$sentence = "";
    }
    else
    {
	$sentence .= $line;
    }
    
    $previous_line = $line;
}



# example of an utterance:
#
# <utterance participant="AL" annex_link="extAnno=https://korp.csc.fi/eduskunta/2008-syksy/Annotations/2008-09-09.eaf&extMedia=https://korp.csc.fi/eduskunta/2008-syksy/Media/2008-09-09.mp4&amp;time=302032&amp;duration=6176" 
# end_time="308208" begin_time="302032" duration="6176" id="1">
#    Tästä   a336    ts671   ts672   302032  302352  1       tämä    Pron    SUBCAT_Dem|NUM_Sg|CASE_Ela|CASECHANGE_Up        2       det     _
#    lainkäsittelystä        a337    ts673   ts674   302352  302592  2       laki|käsittely  N       NUM_Sg|CASE_Ela 6       nommod  _
#    on      a338    ts675   ts676   303160  303240  3       olla    V       PRS_Sg3|VOICE_Act|TENSE_Prs|MOOD_Ind    5       cop     _
#    ihan    a339    ts677   ts678   304120  304552  4       ihan    Adv     _       5       advmod  _
#    hyvä    a340    ts679   ts680   304552  304888  5       hyvä    A       NUM_Sg|CASE_Nom|CMP_Pos 0       ROOT    _
#    aloittaa        a341    ts681   ts682   304888  306040  6       aloittaa        V       NUM_Sg|CASE_Lat|VOICE_Act|INF_Inf1      5       iccomp  _
#    eduskunnan      a342    ts683   ts684   306040  306368  7       edus|kunta      N       NUM_Sg|CASE_Gen 8       poss    EnamexOrgCrp/
#    syyskausi       a343    ts685   ts686   306368  307432  8       syys|kausi      N       NUM_Sg|CASE_Nom 6       dobj    _
#    .       a344    ts687   ts688   307896  308208  9       .       Punct   _       5       punct   _
# </utterance>
    
