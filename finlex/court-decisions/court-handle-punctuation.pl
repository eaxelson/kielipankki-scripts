#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

foreach my $line ( <STDIN> ) {

    unless ( $line =~ /^</)
    {
	# literal '\n'
	$line =~ s/\\n/ /g;

	# separate sentence boundary marker and other tags
	$line =~ s/<([^>]*)>/ <$1> /g;

	# separate parentheses
	$line =~ s/([^ ])\(/$1 \(/g;
	$line =~ s/\)([^ ])/\) $1/g;

        # escape &amp; &quot; &apos; &lt; &gt;
	$line =~ s/\&((amp)|(quot)|(apos)|(lt)|(gt))\;/\&$1¤/g;
	
	# , ; and : at the end of a word or line is separated
	$line =~ s/, / , /g;
	$line =~ s/\; / \; /g;
	$line =~ s/: / : /g;
	$line =~ s/,$/ ,/;
	$line =~ s/\;$/ \;/;
	$line =~ s/:$/ :/;

	# / is separated if surrounded by alpha characters
	$line =~ s/([a-z\x{00E5}\x{00E4}\x{00F6}\x{00E9}A-Z\x{00C5}\x{00C4}\x{00D6}])\/([a-z\x{00E5}\x{00E4}\x{00F6}\x{00E9}A-Z\x{00C5}\x{00C4}\x{00D6}])/$1 \/ $2/g;

	# unescape &amp; &quot; &apos; &lt; &gt;
	$line =~ s/\&((amp)|(quot)|(apos)|(lt)|(gt))¤/\&$1\;/g;
	
	# . at the end of a word (followed by space and capital letter or parenthesis or sentence separator <>)
	# or line is separated with the exception of v. = vuosi|vuonna and ... = (omitted text)
	$line =~ s/([^v\.])\. (\p{Upper}|\(|(<>))/$1 \. $2/g;
	$line =~ s/([^\.])\.$/$1 \./;

	# separate content inside parentheses from parentheses
	$line =~ s/\(([^\)]+)\)/\( $1 \)/g;

	# separate double quotes
	$line =~ s/"/ " /g;
	# todo: ?, !, even smileys possible inside quotes

	# previous replacements might have generated too many spaces
	$line =~ s/ +/ /g;
	
	# each word/punctuation on its own line
	$line =~ s/^ +//g;
	$line =~ s/ +$//g;
	$line =~ s/ /\n/g;

    }

    print $line;

}
