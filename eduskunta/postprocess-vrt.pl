#!/usr/bin/perl

# Read vrt from standard input and perform the following substitutions:
#
# * substitute speaker value "UNKNOWN" with the empty string ""
#
# Output vrt to standard output.

use strict;
use warnings;
use open qw(:std :utf8);

foreach my $line ( <STDIN> ) {

    if ( $line =~ /^<paragraph/ )
    {
	$line =~ s/speaker="UNKNOWN"/speaker=""/;
    }
    print $line;
}    
