#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $sentence_number = 0; # number of sentence
my $first_line = "true"; # control sentence tags
my $end_tag_printed = "true"; # control sentence tags
my $sentence = ""; # the current sentence
my $words = 0; # number of words in a sentence, including punctuation
my $limit = 100000; # limit of sentence length
my $delayed = "false"; # delayed printing of sentences, required automatically if --limit is set

foreach (@ARGV)
{
    if ( $_ eq "--delayed" ) { $delayed = "true"; }
    elsif ( $_ eq "--limit" ) { $limit = 0; $delayed = "true"; }
    elsif ( $limit == 0 ) { $limit = $_; }
    elsif ( $_ eq "--help" || $_ eq "-h" ) { print "Usage: $0 [--limit LIMIT] [--delayed]\n"; exit 0; }
    else {}
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
		if ( $words > $limit ) { $sentence .= $words; }
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
    elsif ( $line =~ /^\.$/ || $line =~ /^\.\)$/ || $line =~ /^\.\]$/ || $line =~ /^\;$/ || $line =~ /^\:$/ )
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
	if ( $delayed eq "true" )
	{
	    $sentence .= '</sentence>';
	    if ( $words > $limit ) { $sentence .= $words; }
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
	$words++;
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
	if ( $delayed eq "true" ) { $sentence .= $line; } else { print $line; }
    }
}


if ($end_tag_printed eq "false")
{
    # print STDERR "court-add-sentence-tags.pl: warning: missing '.' at the end of last sentence, adding a sentence end tag anyway.\n";
    if ( $delayed eq "true" )
    {
	$sentence .= '</sentence>';
	if ( $words > $limit ) { $sentence .= $words; }
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

