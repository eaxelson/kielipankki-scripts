#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $sentence_number = 0;
my $continu_p = 0; # for handling paragraphs
my $continu_d = 0; # for handling descriptions

foreach my $line ( <STDIN> ) {

    # skip descriptions
    if ( $continu_d == 1 )
    {
	if ( $line =~ /<\/dcterms:description>/ )
	{
	    $continu_d = 0;
	}
	next;
    }
    elsif ( $line =~ /<dcterms:description>/ )
    {
	$continu_d = 1;
	next;
    }
    
    if ( $line =~ /<p>/ || $continu_p == 1 )
    {
	unless ( $line =~ /<\/p>/ )
	{
	    $continu_p = 1;
	}
	else
	{
	    $continu_p = 0;
	}
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
	# get rid of xml tags (other than <>)
	$line =~ s/<[^>]+>//g;
	# get rid of ( .. .. .) lines
	$line =~ s/\(( |\.)+\)//g;
	print $line;
    }	
}
