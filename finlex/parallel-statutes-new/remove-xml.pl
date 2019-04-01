#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

while ( <> ) {
    s/^<[^><].*//;
    s/^\n$//;
    print;
}
