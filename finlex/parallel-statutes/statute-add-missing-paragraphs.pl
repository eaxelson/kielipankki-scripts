#!/usr/bin/perl

# Add missing <paragraph> around separate sentences.

use strict;
use warnings;
use open qw(:std :utf8);

my $paragraph = "no";

foreach my $line ( <STDIN> ) {

    if ( $line =~ /^<paragraph[ >]/ )
    {
	if ( $paragraph eq "added" )
	{
	    print "<\/paragraph>\n";
	}
	$paragraph = "yes";
    }
    elsif ( $line =~ /^<chapter[ >]/ )
    {
	if ( $paragraph eq "added" )
	{
	    print "<\/paragraph>\n";
	}
	$paragraph = "no";
    }
    elsif ( $line =~ /^<\/paragraph>/ )
    {
	$paragraph = "no";
    }
    elsif ( $line =~ /<sentence[ >]/)
    {
	if ( $paragraph eq "no" )
	{ 
	    print "<paragraph>\n";
	    $paragraph = "added";
	}
    }
    print $line;
}
