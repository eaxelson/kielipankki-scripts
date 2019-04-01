#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $whole_file = "";

foreach my $line ( <STDIN> ) {
    $whole_file .= $line
}

$whole_file =~ s/<\/heading_paragraph>\n<heading_paragraph>\n/<\.>\n/g;

# remove empty paragraphs
$whole_file =~ s/<paragraph type="[^"]*">\n( *<\.?> *\n)?<\/paragraph>\n//g;    
$whole_file =~ s/<heading_paragraph>\n( *<\.?> *\n)?<\/heading_paragraph>\n//g;    

print $whole_file;
