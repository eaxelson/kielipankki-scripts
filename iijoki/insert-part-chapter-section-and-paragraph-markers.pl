#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $empty_lines = 0;
my $latest_element = "";

foreach my $line ( <STDIN> ) {    

    $line =~ s/\x{000D}\x{000A}/\x{000A}/;
    
    if ($line =~ /^((ENSIMM\x{00C4}INEN|TOINEN|((KOLMAS|NELJ\x{00C4}S|VIIDES|KUUDES|SEITSEM\x{00C4}S|KAHDEKSAS|YHDEKS\x{00C4}S)(TOISTA)?)|KYMMENES|YHDESTOISTA|KAHDESTOISTA) LUKU)$/)
    {
	$line = "<part> ".$line;
	$latest_element="<part>";
    }
    elsif ($line =~ /^([A-Z\x{00C5}\x{00C4}\x{00D6}]+( [A-Z\x{00C5}\x{00C4}\x{00D6}]+)*)$/)
    {
	$line = "<chapter> ".$line;
	$latest_element="<chapter>";
    }
    elsif ($line =~ /^ *$/)
    {
	$empty_lines++;
    }
    else
    {
	if ($empty_lines > 1)
	{
	    $line = "<section>\n<paragraph>\n".$line;
	    $latest_element = "<paragraph>";
	}
	elsif ($empty_lines == 1)
	{
	    $line = "<paragraph>\n".$line;
	    $latest_element = "<paragraph>";
	}
	$empty_lines = 0;
    }
    
    print $line;
}
