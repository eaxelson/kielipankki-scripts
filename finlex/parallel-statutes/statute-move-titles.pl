#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $whole_file = "";

foreach my $line ( <STDIN> ) {
    $whole_file .= $line
}

$whole_file =~ s/<(part|chapter|section)>\n(<link[^>]*>\n)<title=([^>]+)>\n/<$1 title=$3>\n$2/g;
$whole_file =~ s/<(part|chapter|section)>\n<title=([^>]+)>\n/<$1 title=$2>\n/g;
print $whole_file;
