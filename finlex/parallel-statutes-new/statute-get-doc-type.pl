#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

while (<>) {
    if (/saa1:saadostyyppiNimi="([^"]+)"/)
    {
	print $1;
	print "\n";
	exit 0;
    }
}

print "(none)\n";
