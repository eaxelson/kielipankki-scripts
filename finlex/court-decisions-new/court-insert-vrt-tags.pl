#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $before = "";
my $after = "";

while (<>) {

    if (/^<div[ >]/)
    {
	$before = "<<section>>\n";
    }
    elsif (/^<\/div>/)
    {
	$after = "<</section>>\n";
    }
    elsif (/^<p[ >]/)
    {
	$before = "<<paragraph type=\"paragraph\">>\n";
    }
    elsif (/^<\/p>/)
    {
	$after = "<</paragraph>>\n";
    }

    print $before;
    $before = "";
    print;
    print $after;
    $after = "";
}
