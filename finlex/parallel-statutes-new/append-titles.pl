#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $line = "";

while ( <> ) {
    if (/^<(part|chapter|section)/)
    {
	$line = $_;
    }
    elsif ($line ne "")
    {
	if (/^<title="([^"]+)">/)
	{
	    my $title = $1;
	    $line =~ s/>/ title="${title}">/;
	    print $line;
	    $line = "";
	}
	else
	{
	    print $line;
	    $line = "";
	    print;
	}
    }
    else
    {
	print;
    }
}
