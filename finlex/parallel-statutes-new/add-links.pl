#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $id = "";

while (<>)
{
    if (/^<chapter id="([^"]*)"/)
    {
	$id = $1;
	print join('',"<link id=\"",$id,"\">\n");
	print;
    }
    elsif (/^<\/chapter>/)
    {
	print;
	print "</link>\n";
    }
    else
    {
	print;
    }
}
