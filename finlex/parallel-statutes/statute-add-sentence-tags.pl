#!/usr/bin/perl

# Read VRT from standard input. Add sentence tags and write
# result to standard output. Input comes by default from script
# statute-handle-punctuation.pl.

use strict;
use warnings;
use open qw(:std :utf8);

my $sentence_number = 0; # number of sentence
my $first_line = "true"; # control sentence tags
my $end_tag_printed = "true"; # control sentence tags
my $sentence = ""; # the current sentence
my $words = 0; # number of words in a sentence, including punctuation
my $limit = 100000; # limit of sentence length, print warning if exceeded

# interpret the following symbols as sentence separators if the respective threshold is exceeded:
my $tag_threshold = 100000; # <>
my $comma_threshold = 100000; # comma
my $threshold = 100000; # hyphen, hyphen-minus, n dash, m dash and horizontal bar

my $delayed = "false"; # delayed printing of sentences, required automatically if --limit is set
my $filename = ""; # for more informative warning messages

foreach (@ARGV)
{
    if ( $_ eq "--delayed" ) { $delayed = "true"; }
    elsif ( $_ eq "--limit" ) { $limit = -1; $delayed = "true"; }
    elsif ( $_ eq "--comma-threshold" ) { $comma_threshold = -1; }
    elsif ( $_ eq "--tag-threshold" ) { $tag_threshold = -1; }
    elsif ( $_ eq "--threshold" ) { $threshold = -1; }
    elsif ( $_ eq "--filename" ) { $filename = "next..."; }
    elsif ( $_ eq "--help" || $_ eq "-h" ) { print "Usage: $0 [--limit LIMIT] [--comma-threshold CT] [--tag-threshold TT] [--threshold T] [--delayed] [--filename FILENAME]\n"; exit 0; }
    elsif ( $limit == -1 ) { $limit = $_; }
    elsif ( $comma_threshold == -1 ) { $comma_threshold = $_; }
    elsif ( $tag_threshold == -1 ) { $tag_threshold = $_; }
    elsif ( $threshold == -1 ) { $threshold = $_; }
    elsif ( $filename eq "next..." ) { $filename = $_; }
    else { print "Error: argument "; print $_; print " not recognized\n"; exit 1; }
}

foreach my $line ( <STDIN> ) {

    # skip links
    if ( $line =~ /^<\/?link/ )
    {
	if ( $end_tag_printed eq "false" )
	{
	    if ( $delayed eq "true" )
	    {
		$sentence .= '</sentence>';
		if ( $words > $limit ) { print STDERR "warning: sentence length is "; print STDERR $words; print STDERR " words in sentence number "; print STDERR $sentence_number; print STDERR " in file "; print STDERR $filename; print STDERR "\n"; }
		$sentence .= "\n";
		print $sentence;
		$sentence = "";
	    }
	    else
	    {
		print '</sentence>';
		print "\n";
	    }
	    $end_tag_printed = "true";
	    $first_line = "true";
	    $words = 0;
	}
	if ( $delayed eq "true" ) { $sentence .= $line;	} else { print $line; }
    }
    # end of sentence
    elsif ( $line =~ /^\.$/ || $line =~ /^\.\)$/ || $line =~ /^\.\]$/ || $line =~ /^\;$/ || $line =~ /^\:$/ || $line =~ /^\.\.\.$/  || ( $words > $tag_threshold && $line =~ /^<>$/ ) || ( $words > $comma_threshold && $line =~ /^,$/ ) || ($words > $threshold && $line =~ /^\-|\x{002D}|\x{2013}|\x{2014}|\x{2015}$/ ) )
    {
	unless ( $line =~ /^<>$/ )
	{
	    $words++;
	    if ( $line =~ /^\.\)$/ )
	    {
		if ( $delayed eq "true" ) { $sentence .= ".\n)\n"; } else { print ".\n)\n"; }
	    }
	    elsif ( $line =~ /^\.\]$/ )
	    {
		if ( $delayed eq "true" ) { $sentence .= ".\n]\n"; } else { print ".\n]\n"; }
	    }
	    else
	    {
		if ( $delayed eq "true" ) { $sentence .= $line; } else { print $line; }
	    }
	}
	if ( $delayed eq "true" )
	{
	    $sentence .= '</sentence>';
	    if ( $words > $limit ) { print STDERR "warning: sentence length is "; print STDERR $words; print STDERR " words in sentence number "; print STDERR $sentence_number; print STDERR " in file "; print STDERR $filename; print STDERR "\n"; }
	    $sentence .= "\n";
	    print $sentence;
	    $sentence = "";
	}
	else
	{
	    print '</sentence>';
	    print "\n";
	}
	$end_tag_printed = "true";
	$first_line = "true";
	$words = 0;
    }
    else
    {
	unless ( $line =~ /^<>$/ )
	{
	    $words++;
	}
	if ($first_line eq "true")
	{
	    if ( $delayed eq "true" )
	    {
		$sentence .= '<sentence n="';
		$sentence .= ++$sentence_number;
		$sentence .= '">';
		$sentence .= "\n";
	    }
	    else
	    {
		print '<sentence n="';
		print ++$sentence_number;
		print '">';
		print "\n";
	    }
	    $end_tag_printed = "false";
	}
	$first_line = "false";
	unless ( $line =~ /^<>$/ )
	{
	    if ( $delayed eq "true" ) { $sentence .= $line; } else { print $line; }
	}
    }
}


if ($end_tag_printed eq "false")
{
    # print STDERR "court-add-sentence-tags.pl: warning: missing '.' at the end of last sentence, adding a sentence end tag anyway.\n";
    if ( $delayed eq "true" )
    {
	$sentence .= '</sentence>';
	if ( $words > $limit ) { print STDERR "warning: sentence length is "; print STDERR $words; print STDERR " words in sentence number "; print STDERR $sentence_number; print STDERR " in file "; print STDERR $filename; print STDERR "\n"; }
	$sentence .= "\n";
	print $sentence;
    }
    else
    {
	print '</sentence>';
	print "\n";
    }
}
else
{
    # sentence might contain the last </link> that has not yet been printed
    if ( $delayed eq "true" ) { print $sentence; }
}

