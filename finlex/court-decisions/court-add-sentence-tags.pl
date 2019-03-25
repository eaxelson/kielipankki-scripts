#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $sentence_number = 0;
my $first_line = "true";
my $end_tag_printed = "false";
my $words = 0; # number of words in a sentence, including punctuation
my $limit = 100000;
my $threshold = 100000;
my $filename = "";

# Information extracted from tags
my $continu_h = 0; # for handling headers
my $continu_d = 0; # for handling descriptions
my $continu_a = 0; # for handling abstracts

foreach (@ARGV)
{
    if ( $_ eq "--limit" ) { $limit = -1; }
    elsif ( $_ eq "--threshold" ) { $threshold = -1; }
    elsif ( $_ eq "--filename" ) { $filename = "next..."; }
    elsif ( $limit == -1 ) { $limit = $_; }
    elsif ( $threshold == -1 ) { $threshold = $_; }
    elsif ( $filename eq "next..." ) { $filename = $_; }
    else { print "Error: argument "; print $_; print " not recognized\n"; exit 1; }
}

foreach my $line ( <STDIN> ) {

    # Skip empty lines
    if ( $line =~ /^ *$/ )
    {
	;
    }
    # Skip tags other than <> and extract information from them
    elsif ( $line =~ /^<\// || $line =~ /^<[^>]/ )
    {
	if ( $line =~ /^<dcterms:description/ ) { $continu_d = 1; }
	elsif ( $line =~ /^<\/dcterms:description/ ) { $continu_d = 0; }
	elsif ( $line =~ /^<dcterms:abstract/ ) { $continu_a = 1; }
	elsif ( $line =~ /^<\/dcterms:abstract/ ) { $continu_a = 0; }
	elsif ( $line =~ /^<h[123]/ ) { $continu_h = 1; }
	elsif ( $line =~ /^<\/h[123]/ ) { $continu_h = 0; }
    }
    elsif ( $line =~ /^(\.|\;|\:)$/ || ( $words > $threshold && $line =~ /^(,|\-)$/ ) || $line =~ /^<>$/ )
    {
	if ($first_line eq "true")
	{
	    # no need to end sentence as we are starting a new one
	    if ( $line =~ /^<>$/ )
	    {
		next;
	    }
	    print STDERR "court-add-sentence-tags.pl: error: in file '"; print STDERR $filename; print STDERR "': first non-empty line in sentence "; print STDERR $sentence_number; print STDERR " is '.', ';' or ':', exiting.\n";
	    exit 1;
	}
	unless ( $line =~ /^<>$/ ) { ++$words; } # sentence separator is not counted as a word ...
	if ( $words > $limit ) { print STDERR "Warning: number of words in sentence "; print STDERR $sentence_number; print STDERR " is "; print STDERR $words; print STDERR " in file '"; print STDERR $filename; print STDERR "'\n"; }
	unless ( $line =~ /^<>$/ ) { print $line; } # ... or printed
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
	    print '" type="';
	    if ( $continu_h eq 1 ) { print 'header'; }
	    elsif ( $continu_a eq 1 ) { print 'abstract'; }
	    elsif ( $continu_d eq 1 ) { print 'description'; }
	    else { print 'undefined'; }
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
    if ( $words > $limit ) { print STDERR "Warning: number of words in sentence "; print STDERR $sentence_number; print STDERR " is "; print STDERR $words; print STDERR " in file '"; print STDERR $filename; print STDERR "'\n"; }
    print '</sentence>';
    print "\n";
}
