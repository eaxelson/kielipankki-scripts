#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $continu_p = 0; # for handling paragraphs
my $continu_h = 0; # for handling headers
my $continu_d = 0; # for handling descriptions
my $continu_a = 0; # for handling abstracts

foreach my $line ( <STDIN> ) {

    if ( $line =~ /<dcterms:description>/ || $continu_d == 1 )
    {
	unless ( $line =~ /<\/dcterms:description>/ ) {	$continu_d = 1;	}
	else { $continu_d = 0; }

	$line =~ s/<p>//g;
	$line =~ s/<\/p>/<>/g; # mark paragraph end as sentence boundary
	$line =~ s/(<\/span>)/<> $1/g; # mark <span> end as sentence boundary
	$line =~ s/(<\/strong>)/<> $1/g; # mark <strong> end as sentence boundary
	$line =~ s/\t//g;
	$line =~ s/ +/ /g;
	$line =~ s/^ //g;
	$line =~ s/ $//g;
	# separate xml tags other than <> on their own lines
	$line =~ s/(<[^>]+>)/\n$1\n/g;
	print $line;
    }
    elsif ( $line =~ /<dcterms:abstract>/ || $continu_a == 1 )
    {
	unless ( $line =~ /<\/dcterms:abstract>/ ) { $continu_a = 1; }
	else { $continu_a = 0; }

	$line =~ s/<p>//g;
	$line =~ s/<\/p>/<>/g; # mark paragraph end as sentence boundary
	$line =~ s/\t//g;
	$line =~ s/ +/ /g;
	$line =~ s/^ //g;
	$line =~ s/ $//g;
	# separate xml tags other than <> on their own lines
	$line =~ s/(<[^>]+>)/\n$1\n/g;
	print $line;
    }
    elsif ( $line =~ /<p>/ || $continu_p == 1 )
    {
	unless ( $line =~ /<\/p>/ ) { $continu_p = 1; }
	else { $continu_p = 0; }

	# get rid of <p>.</p>
	$line =~ s/<p>\.<\/p>//g;
	# and " ( )."
	$line =~ s/ \( \)\.//g;
	# and replace ";  . " with "; "
	$line =~ s/\;  \. /\; /g;

	$line =~ s/<p>//g;
	$line =~ s/<\/p>/<>/g; # mark paragraph end as sentence boundary
	# replace <br/> with space
	$line =~ s/<br\/>/ /g;
	$line =~ s/\t//g;
	$line =~ s/ +/ /g;
	$line =~ s/^ //g;
	$line =~ s/ $//g;
	# get rid of ( .. .. .) lines
	$line =~ s/\(( |\.)+\)//g;
	# separate xml tags other than <> on their own lines
	$line =~ s/(<[^>]+>)/\n$1\n/g;
	print $line;
    }
    elsif ( $line =~ /<h[123]( [^>]*)?>/ || $continu_h == 1 )
    {
	unless ( $line =~ /<\/h[123]>/ ) { $continu_h = 1; }
	else { $continu_h = 0; }

	#$line =~ s/(<h[123])( [^>]*)?>/$1>/g;
	$line =~ s/(<\/h[123]>)/$1 <>/g; # mark header end as sentence boundary
	$line =~ s/\t//g;
	$line =~ s/ +/ /g;
	$line =~ s/^ //g;
	$line =~ s/ $//g;
	# separate xml tags other than <> on their own lines
	$line =~ s/(<[^>]+>)/\n$1\n/g;
	print $line;
    }
}
