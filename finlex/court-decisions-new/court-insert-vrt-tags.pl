#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $before = "";
my $after = "";
my $div_depth = 0;

while (<>) {

    if (/^<div[ >]/)
    {
	$div_depth++;
	if ($div_depth eq 1) { $before = "<<chapter>>\n"; }
	elsif ($div_depth eq 2) { $before = "<<section>>\n"; }
	else { print STDERR "Error: <div> depth exceeds 2.\n"; exit 1; }
    }
    elsif (/^<\/div>/)
    {
	$div_depth--;
	if ($div_depth eq 0) { $before = "<</chapter>>\n"; }
	elsif ($div_depth eq 1) { $before = "<</section>>\n"; }
	else { print STDERR "Error: <div> depth exceeds 2.\n"; exit 1; }
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
