#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

foreach my $line ( <STDIN> ) {

    unless ( $line =~ /^<[^>]/)
    {
	# special symbol <> used for end of sentence in titles etc.
	$line =~ s/<>/ <> /g;

	# special symbol <-> (from tables) checked here; preserve it only in cases like 'kuorma-auto'
	$line =~ s/([a|e|i|o|u|y|\x{e4}|\x{f6}])<\->\1/$1\-$1/g;
	# and 'Helsinki-Vantaa'
	$line =~ s/<\->(\p{Lower})/$1/g;
	$line =~ s/<\->/\-/g;
	
	# literal '\n'
	$line =~ s/\\n/ /g;

	# separate parentheses () and []
	$line =~ s/([^ ])\(/$1 \(/g;
	$line =~ s/\)([^ ])/\) $1/g;
	$line =~ s/([^ ])\[/$1 \[/g;
	$line =~ s/\]([^ ])/\] $1/g;

	# escape &amp; &quot; &apos; &lt; &gt;
	$line =~ s/\&((amp)|(quot)|(apos)|(lt)|(gt))\;/\&$1¤/g;
	# , ; and : at the end of a word or line is separated
	$line =~ s/(,|\;|:) / $1 /g;
	$line =~ s/(,|\;|:)$/ $1/;
	# unescape &amp; &quot; &apos; &lt; &gt;
	$line =~ s/\&((amp)|(quot)|(apos)|(lt)|(gt))¤/\&$1\;/g;

	# escape some common abbreviations that end in dot and do not (ever?) end a sentence: . -> <.>
	$line =~ s/ esim\./ esim<\.>/g;
	$line =~ s/ v\./ v<\.>/g;
	$line =~ s/ t\. ?ex\./ t<\.>ex<\.>/g; # almost always written together: "t.ex."
	$line =~ s/Vt\./Vt<\.>/g;
	$line =~ s/Tf\./Tf<\.>/g;
	# and abbreviations in capital letters, e.g. 'C.G.E. Mannerheim' or 'J. K. Paasikivi'
	# (must be done twice for overlapping matches)
	$line =~ s/(\p{Upper})\. ?(\p{Upper})/$1<\.> $2/g;
	$line =~ s/(\p{Upper})\. ?(\p{Upper})/$1<\.> $2/g;

	# . at the end of a word (followed by space and capital letter or opening parenthesis) or line is separated
	$line =~ s/(.)\. (\p{Upper}|\(|\[)/$1 \. $2/g;
	$line =~ s/\. *$/ \./;
	# .) and .] are handled later

	# unescape escaped dots
	$line =~ s/<\.>/\./g;
	
	# separate content inside parentheses from parentheses
	$line =~ s/\(([^\)]+)\)/\( $1 \)/g;
	$line =~ s/\[([^\]]+)\]/\[ $1 \]/g;

	# handle .) and .] that were just separated
	$line =~ s/\. \)/ \.\)/g;
	$line =~ s/\. \]/ \.\]/g;

	# separate hyphen, n dash, m dash and horizontal bar in numerical ranges and dates (e.g. 250-300; 1.2.-5.2.)
	$line =~ s/([0-9\.])(\-|\x{2013}|\x{2014}|\x{2015})([0-9])/$1 $2 $3/g;
	# and single-symbol ranges (e.g. ' 250-300 henkeä '; ' alakohdissa a-c mainitut ')
	$line =~ s/( [^ ])(\-|\x{2013}|\x{2014}|\x{2015})([^ ] )/$1 $2 $3/g;
	
	# separate double quotes
	$line =~ s/"/ " /g;
	
	# previous replacements might have generated too many spaces
	$line =~ s/ +/ /g;
	
	# each word/punctuation on its own line
	$line =~ s/^ +//g;
	$line =~ s/ +$//g;
	$line =~ s/ /\n/g;

    }
    
    print $line;

}
