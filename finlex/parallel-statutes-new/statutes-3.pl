#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $identifiointiosa = "";
my $saadososa = "";
my $allekirjoitusosa = "";
my $liiteosa = "";
my $part = "";

while (<>) {
    if (/^ *$/) { next; }
    
    if (/^<asi:IdentifiointiOsa[ >]/) { $part = "identifiointiosa"; }
    elsif (/^<saa:SaadosOsa[ >]/) { $part = "saadososa"; }
    elsif (/^<asi:AllekirjoitusOsa[ >]/) { $part = "allekirjoitusosa"; }
    elsif (/^<asi:LiiteOsa[ >]/) { $part = "liiteosa"; }
    
    if ($part eq "identifiointiosa") { $identifiointiosa .= $_; }
    if ($part eq "saadososa") { $saadososa .= $_; }
    if ($part eq "allekirjoitusosa") { $allekirjoitusosa .= $_; }
    if ($part eq "liiteosa") { $liiteosa .= $_; }
    
    if (/^<\/asi:IdentifiointiOsa>/ || /^<\/saa:SaadosOsa>/ || /^<\/asi:AllekirjoitusOsa>/ || /^<\/asi:LiiteOsa>/) { $part = ""; }
}

print $saadososa;

