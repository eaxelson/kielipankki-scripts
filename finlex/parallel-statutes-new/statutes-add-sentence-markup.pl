#!/usr/bin/perl

# Read VRT from standard input. Add sentence tags and write
# result to standard output. Input comes by default from script
# statute-handle-punctuation.pl.

# TODO: interpret some xml markup as sentence boundary.

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
my $comma_threshold = 100000; # comma
my $threshold = 100000; # hyphen, hyphen-minus, n dash, m dash and horizontal bar

my $delayed = "false"; # delayed printing of sentences, required automatically if --limit is set
my $filename = ""; # for more informative warning messages

foreach (@ARGV)
{
    if ( $_ eq "--delayed" ) { $delayed = "true"; }
    elsif ( $_ eq "--limit" ) { $limit = -1; $delayed = "true"; }
    elsif ( $_ eq "--comma-threshold" ) { $comma_threshold = -1; }
    elsif ( $_ eq "--threshold" ) { $threshold = -1; }
    elsif ( $_ eq "--filename" ) { $filename = "next..."; }
    elsif ( $_ eq "--help" || $_ eq "-h" ) { print "Usage: $0 [--limit LIMIT] [--comma-threshold CT] [--threshold T] [--delayed] [--filename FILENAME]\n"; exit 0; }
    elsif ( $limit == -1 ) { $limit = $_; }
    elsif ( $comma_threshold == -1 ) { $comma_threshold = $_; }
    elsif ( $threshold == -1 ) { $threshold = $_; }
    elsif ( $filename eq "next..." ) { $filename = $_; }
    else { print join("","Error: argument ",$_," not recognized\n"); exit 1; }
}

foreach my $line ( <STDIN> ) {

    # do not process xml markup or count it as a word
    if ( $line =~ /^</ )
    {
	$sentence .= $line;
    }
    # end of sentence
    elsif ( $line =~ /^\.$/ || $line =~ /^\.\)$/ || $line =~ /^\.\]$/ || $line =~ /^\;$/ || $line =~ /^\:$/ || $line =~ /^\.\.\.$/ || ( $words > $comma_threshold && $line =~ /^,$/ ) || ($words > $threshold && $line =~ /^(\-|\x{002D}|\x{2013}|\x{2014}|\x{2015})$/ ) )
    {
	$words++;
	if ( $line =~ /^\.\)$/ )
	{
	    $sentence .= ".\n)\n";
	}
	elsif ( $line =~ /^\.\]$/ )
	{
	    $sentence .= ".\n]\n";
	}
	else
	{
	    $sentence .= $line;
	}
	
	$sentence .= '</sentence>';
	if ( $words > $limit ) { print STDERR join("","warning: sentence length is ",$words," words in sentence number ",$sentence_number," in file ",$filename,"\n"); }
	$sentence .= "\n";
	print $sentence;
	$sentence = "";
	$end_tag_printed = "true";
	$first_line = "true";
	$words = 0;
    }
    else
    {
	$words++;
	if ($first_line eq "true")
	{
	    $sentence .= join("",'<sentence n="',++$sentence_number,'">',"\n");
	    $end_tag_printed = "false";
	}
	$first_line = "false";
	$sentence .= $line;
    }
}


if ($end_tag_printed eq "false")
{
    # print STDERR "court-add-sentence-tags.pl: warning: missing '.' at the end of last sentence, adding a sentence end tag anyway.\n";
    $sentence .= '</sentence>';
    if ( $words > $limit ) { print STDERR join("","warning: sentence length is ",$words," words in sentence number ",$sentence_number," in file ",$filename,"\n"); }
    $sentence .= "\n";
    print $sentence;
}
else
{
    # sentence might contain the last xml markup that has not yet been printed
    print $sentence;
}
