#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $type = "";
my $luku_id = "";
my $pykala_id = "";

foreach my $line ( <STDIN> ) {

    if ( $line =~ /^<link / )
    {
	if ( $line =~ /_identifiointiosa/ ) { $type = "identifiointiosa"; }
	elsif ( $line =~ /_saadosnimeke/ ) { $type = "saadosnimeke"; }
	elsif ( $line =~ /_johtolause/ ) { $type = "johtolause"; }
	elsif ( $line =~ /_pykala_VoimaantuloSaannos/ ) { $type = "voimaantulosaannos"; }
	elsif ( $line =~ /_pykala/ ) { $type = "pykala"; }
	elsif ( $line =~ /_allekirjoitusosa/ ) { $type = "allekirjoitusosa"; }
	else { $type = "undefined"; }

	if ( $line =~ /_luku_([^_"]+)[_"]/ )
	{
	    $luku_id = $1;
	}
	if ( $line =~ /_pykala_([^"]+)"/ )
	{
	    $pykala_id = $1;
	}
    }
    elsif ( $line =~ /<\/link>/ )
    {
	$type = "";
	$luku_id = "";
	$pykala_id = "";
    }
    elsif ( $line =~ /<sentence /)
    {
	$line =~ s/>/ type="${type}" luku_id="${luku_id}" pykala_id="${pykala_id}">/;
    }
    else
    {
	;
    }
    print $line;
}
