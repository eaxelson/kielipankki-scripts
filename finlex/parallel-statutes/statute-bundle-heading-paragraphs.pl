#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $whole_file = "";

foreach my $line ( <STDIN> ) {
    $whole_file .= $line
}

$whole_file =~ s/<\/heading_paragraph>\n<heading_paragraph>\n/<\.>\n/g;
print $whole_file;
