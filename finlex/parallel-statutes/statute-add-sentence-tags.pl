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
    # skip links
    elsif ( $line =~ /^<\/?link/ )
    {
	print $line;
    }
    # <> is special symbol for end of sentence in titles etc (not visible in the result)
    elsif ( $line =~ /^\.$/ || $line =~ /^<>$/ || $line =~ /^\.\)$/ || $line =~ /^\.\]$/ )
    {
	if ($first_line eq "true")
	{
	    # just ignore strange dots, they are probably from tables...
	    #if ( $line =~ /^\.$/ )
	    #{
		#print "court-add-sentence-tags.pl: error: first non-empty line in sentence is '.', exiting.\n";
		#exit 1;
	    #}
	    # just ignore <> at the start of sentence...
	    next;
	}
	if ( $line =~ /^\.\)$/ )
	{
	    print ".\n)\n";
	}
	elsif ( $line =~ /^\.\]$/ )
	{
	    print ".\n]\n";
	}
	elsif ( $line =~ /^<>$/ )
	{
	    ;
	}
	else
	{
	    print $line;
	}
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
    # print STDERR "court-add-sentence-tags.pl: warning: missing '.' at the end of last sentence, adding a sentence end tag anyway.\n";
    print '</sentence>';
    print "\n";
}
