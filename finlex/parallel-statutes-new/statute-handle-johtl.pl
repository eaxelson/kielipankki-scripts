#!/usr/bin/perl

# Move <johtl> inside following <saa:SaadosKappaleKooste>.

use strict;
use warnings;
use open qw(:std :utf8);

my $johtolause = "";

while (<>) 
{
    if (/<johtl>/)
    {
	$johtolause = $_;
	$johtolause =~ s/<johtl>(.*)<\/johtl>/$1/;
    }
    elsif ($johtolause ne "" && /<ko>/)
    {
	next;
    }
    elsif ($johtolause ne "" && /<saa:SaadosKappaleKooste>/)
    {
	print;
	print $johtolause;
	$johtolause = "";
    }
    else
    {
	print;
    }
}

if ($johtolause ne "")
{
    print STDERR join('',"Error: could not insert <johtl>: \"",$johtl,"\"\n");
    exit 1;
}
