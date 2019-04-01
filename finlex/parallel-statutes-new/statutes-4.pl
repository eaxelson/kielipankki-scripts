#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $title = "";
my $tunnuskooste = 0;
my $waiting = 0;
my $saadosotsikkokooste = 0;

while (<>) {
    if (/^<saa:(Osa|Luku|Pykala)TunnusKooste/) { $tunnuskooste = 1; }
    elsif (/^<saa:SaadosOtsikkoKooste/) { $saadosotsikkokooste = 1; }
    elsif (/^<\/saa:(Osa|Luku|Pykala)TunnusKooste/) { $tunnuskooste = 0; $waiting = 1; }
    elsif (/^<\/saa:SaadosOtsikkoKooste/) { $saadosotsikkokooste = 0; }
    elsif ($tunnuskooste eq 1 || $saadosotsikkokooste eq 1) { $title .= $_; $title =~ s/\n/ /g; }
    elsif ($waiting eq 1) { $waiting = 0; $title =~ s/^ +//; $title =~ s/ +$//; print join('','<<title="',$title,'">>',"\n"); $title = ""; }
    print;
}
