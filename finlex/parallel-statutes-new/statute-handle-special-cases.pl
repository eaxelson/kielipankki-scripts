#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

while (<>)
{
    s/^ *<viite>(.*)<\/viite>/<paragraph type="VIITE">$1<\/paragraph>/;
    s/^ *(<saa:Pykala>)(.*)(<\/saa:Pykala>)/$1<paragraph type="paragraph">$2<\/paragraph>$3/;
    print;
}
