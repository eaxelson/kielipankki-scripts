#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $sentence_number = 0;
my $continu = 0; # for handling statutes

foreach my $line ( <STDIN> ) {

    if ( $line =~ /<saa:SaadosOsa>/ || $continu == 1 || $line =~ /<\/tau:table>/ || $line =~ /<asi:AllekirjoitusOsa>/)
    {
	unless ( $line =~ /<\/saa:SaadosOsa>/ || $line =~ /<\/asi:AllekirjoitusOsa>/)
	{
	    $continu = 1;
	}
	else
	{
	    $continu = 0;
	}

	# skip tables
	if ( $line =~ /<tau:table>/ )
	{
	    $continu = 0;
	    next;
	}
	
	# special symbol <> means end of sentence (in titles)
	if ( $line =~ /<\/saa:SaadosOtsikkoKooste>/ || $line =~ /<\/saa:SaadosNimeke>/ || $line =~ /<\/saa:SaadosKappaleKooste>/ )
	{
	    $line .= "<>";
	}

	# replace <br/> with space
	$line =~ s/<br\/>/ /g;
	
	$line =~ s/\t//g;
	$line =~ s/ +/ /g;
	$line =~ s/^ //g;
	$line =~ s/ $//g;
	
        # table entries sometimes contain hyphenated words extending to several lines
	$line =~ s/^<te>(.*)\-<\/te>\n/$1<\->/g;
	
	# get rid of xml tags (other than <> and <->)
	$line =~ s/<[^>][^>]+>//g;
	$line =~ s/<[^>\-]>//g;
	
	print $line;
    }
}
