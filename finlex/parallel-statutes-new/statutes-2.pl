#!/usr/bin/perl


use strict;
use warnings;
use open qw(:std :utf8);

my $continu = 0;

foreach my $line ( <STDIN> ) {

    # Extract IdentifiointiOsa, SaadosOsa, AllekirjoitusOsa
    if ( $line =~ /<saa:SaadosOsa>/ || $continu == 1 || $line =~ /<\/tau:table>/ || $line =~ /<asi:AllekirjoitusOsa>/ || $line =~ /<asi:PaivaysKooste[ >]/ || $line =~ /<asi1:JohdantoTeksti[ >]/ || $line =~ /<asi:Allekirjoittaja[ >]/ || $line =~ /<asi:IdentifiointiOsa>/ || $line =~ /<asi:LiiteOsa>/)
    {
	unless ( $line =~ /<\/saa:SaadosOsa>/ || $line =~ /<\/asi:AllekirjoitusOsa>/ || $line =~ /<\/asi:PaivaysKooste[ >]/ || $line =~ /<\/asi1:JohdantoTeksti[ >]/ || $line =~ /<\/asi:Allekirjoittaja[ >]/ || $line =~ /<\/asi:IdentifiointiOsa>/ || $line =~ /<\/asi:LiiteOsa>/ )
	{
	    $continu = 1;
	}
	else
	{
	    $continu = 0;
	}

	# skip tables
	if ( $line =~ /<tau:table[^>]*>/ )
	{
	    if ( $line =~ /<\/tau:table>/ )
	    {
		next;
	    }
	    $continu = 0;
	    next;
	}

	# Replace <br/> with space
	$line =~ s/<br\/>/ /g;
	# Get rid of extra whitespace
	$line =~ s/\t//g;
	$line =~ s/ +/ /g;
	$line =~ s/^ //g;
	$line =~ s/ $//g;

	# table entries are sometimes not inside <tau:table>, get rid of them
	$line =~ s/^<te>.*<\/te>\n//g;

	print $line;
    }
}
