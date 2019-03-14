#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $sentence_number = 0;
my $first_line = "true";
my $end_tag_printed = "false";
my $words = 0; # number of words in a sentence, including punctuation
my $limit = 100000;
my $comma_threshold = 100000;

foreach (@ARGV)
{
    if ( $_ eq "--limit" ) { $limit = -1; }
    elsif ( $_ eq "--comma-threshold" ) { $comma_threshold = -1; }
    elsif ( $limit == -1 ) { $limit = $_; }
    elsif ( $comma_threshold == -1 ) { $comma_threshold = $_; }
    else { print "Error: argument "; print $_; print " not recognized\n"; exit 1; }
}

foreach my $line ( <STDIN> ) {

    # This case should already have been handled by court-handle-punctuation.pl.
    if ( $line =~ /^ *$/)
    {
	;
    }
    elsif ( $line =~ /^(\.|\;|\:)$/ || ( $words > $comma_threshold && $line =~ /^,$/ ) )
    {
	if ($first_line eq "true")
	{
	    print STDERR "court-add-sentence-tags.pl: error: first non-empty line in sentence "; print STDERR $sentence_number; print STDERR " is '.', ';' or ':', exiting.\n";
	    exit 1;
	}
	if ( ++$words > $limit ) { print STDERR "Warning: number of words in sentence "; print STDERR $sentence_number; print STDERR " is "; print STDERR $words; print STDERR "\n"; }
	print $line;
	print '</sentence>';
	print "\n";
	$end_tag_printed = "true";
	$first_line = "true";
	$words = 0;
    }
    else
    {
	++$words;
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
    if ( ++$words > $limit ) { print STDERR "Warning: number of words in a sentence is "; print STDERR $words; print STDERR "\n"; }
    print '</sentence>';
    print "\n";
}
