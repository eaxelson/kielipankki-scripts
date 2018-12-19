#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $sentence_number = 0;
my $first_line = "true";
my $end_tag_printed = "false";

foreach my $line ( <STDIN> ) {

    # This case should already have been handled by court-handle-punctuation.pl.
    if ( $line =~ /^ *$/)
    {
	;
    }
    elsif ( $line =~ /^\.$/)
    {
	if ($first_line eq "true")
	{
	    print STDERR "court-add-sentence-tags.pl: error: first non-empty line in sentence is '.', exiting.\n";
	    exit 1;
	}
	print $line;
	print '</sentence>';
	print "\n";
	$end_tag_printed = "true";
	$first_line = "true";
    }
    else
    {
	if ($first_line eq "true")
	{
	    print '<sentence n="';
	    print ++$sentence_number;
	    print '">';
	    print "\n";
	    $end_tag_printed = "false";
	}
	$first_line = "false";
	print $line;
    }
}


if ($end_tag_printed eq "false")
{
    #print STDERR "court-add-sentence-tags.pl: warning: missing '.' at the end of last sentence, adding a sentence end tag anyway.\n";
    print '</sentence>';
    print "\n";
}
