#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $paragraph = 0;
my $line = 0;

while ( <> ) {
    ++$line;
    if (/^<paragraph/) 
    {
	if(++$paragraph > 1)
	{
	    print STDERR join('','ERROR: paragraph inside paragraph on line ',$line,"\n");
	    exit 1;
	}
    }
    elsif (/^<\/paragraph/) { $paragraph = 0; }
    elsif (/^</) { } # other tags
    elsif ($paragraph eq 0) # content that should be inside paragraph
    {
	print STDERR "ERROR: content not inside paragraph:\n";
	print STDERR $_;
	exit 1;
    }
    print;
}
