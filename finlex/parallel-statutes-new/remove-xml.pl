#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

while ( <> ) {
    s/^<[^><].*//;
    s/^<</</;
    s/>>$/>/;
    s/<\/?saadososa.*//;
    s/<\/?liiteosa.*//;
    s/^\n$//;
    print;
}
