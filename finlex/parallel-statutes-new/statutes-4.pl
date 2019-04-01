#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $title = "";
my $tunnuskooste = 0;
my $waiting = 0;
my $saadosotsikkokooste = 0;

my $delayed = "";

while (<>) {
    if (/^<saa:(Osa|Luku|Pykala)TunnusKooste/) { $tunnuskooste = 1; $delayed .= join('','<<paragraph type="heading">>',"\n"); }
    elsif (/^<saa:SaadosOtsikkoKooste/) { $saadosotsikkokooste = 1; }
    elsif (/^<\/saa:(Osa|Luku|Pykala)TunnusKooste/) { $tunnuskooste = 0; $waiting = 1; }
    elsif (/^<\/saa:SaadosOtsikkoKooste/) { $saadosotsikkokooste = 0; }
    elsif ($tunnuskooste eq 1 || $saadosotsikkokooste eq 1) { $title .= $_; $title =~ s/\n/ /g; }
    elsif ($waiting eq 1) { $waiting = 0; $delayed .= join('','<</paragraph>>',"\n"); $title =~ s/^ +//; $title =~ s/ +$//; $delayed = join('','<<title="',$title,'">>',"\n",$delayed); $title = ""; }

    if ($tunnuskooste eq 1 || $saadosotsikkokooste eq 1 || $waiting eq 1) { $delayed .= $_; }
    else { print $delayed; $delayed = ""; print; }
}
