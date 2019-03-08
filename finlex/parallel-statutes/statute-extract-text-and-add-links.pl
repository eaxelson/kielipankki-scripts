#!/usr/bin/perl

# Read a statute in XML format from standard input, extract text,
# add vrt links around Pykala, AllekirjoitusOsa, SaadosNimeke,
# Johtolause and IdentifiointiOsa tags. Replace MomenttiKooste,
# MomenttiKohtaKooste, MomenttiAlakohtaKooste and
# SaadosValiotsikkoKooste tags with <> which marks a possible
# sentence boundary in later stages. Output to standard output.

use strict;
use warnings;
use open qw(:std :utf8);

my $sentence_number = 0;
my $continu = 0; # for handling statutes
my $link = 1; # whether links are added
my $link_prefix = ""; # prefix used in naming links
my $link_depth = 0;
my $link_rejected = 0;
my $luku_id = ""; # <saa:Luku> used in naming links

if (@ARGV)
{
    foreach my $argnum (0 .. $#ARGV)
    {
	if ($ARGV[$argnum] eq "--help" || $ARGV[$argnum] eq "-h")
	{
	    print $0;
	    print ": [--no-links] [--link-prefix FILENAME]\n";
	    exit(0);
	}
	if ($ARGV[$argnum] eq "--no-links")
	{
	    $link = 0;
	}
	if ($ARGV[$argnum] eq "--link-prefix")
	{
	    if ($ARGV[$argnum + 1])
	    {
		$link_prefix = $ARGV[$argnum + 1];
	    }
	    else
	    {
		print "option --link-prefix requires an argument\n";
		exit(1);
	    }
	}
    }
}

foreach my $line ( <STDIN> ) {

    if ( $line =~ /<saa:SaadosOsa>/ || $continu == 1 || $line =~ /<\/tau:table>/ || $line =~ /<asi:AllekirjoitusOsa>/ || $line =~ /<asi:IdentifiointiOsa>/)
    {
	unless ( $line =~ /<\/saa:SaadosOsa>/ || $line =~ /<\/asi:AllekirjoitusOsa>/ || $line =~ /<\/asi:IdentifiointiOsa>/)
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
	    if ( $line =~ /<\/tau:table>/ )
	    {
		next;
	    }
	    $continu = 0;
	    next;
	}

	# replace <br/> with space
	$line =~ s/<br\/>/ /g;
	
	$line =~ s/\t//g;
	$line =~ s/ +/ /g;
	$line =~ s/^ //g;
	$line =~ s/ $//g;

	# table entries are sometimes not inside <tau:table>, get rid of them
	$line =~ s/^<te>.*<\/te>\n//g;
        # table entries sometimes contain hyphenated words extending to several lines
	# (,- is used when referring to money such as 200,-)
	# $line =~ s/^<te>(.*)[^, \t]\-<\/te>\n/$1<\->/g;
	
	if ($link eq 1)
	{
	    # Luku tag encountered
	    if ($line =~ /<saa:Luku saa1:identifiointiTunnus="([^"]+)">/)
	    {
		$luku_id = $1;
		if ($luku_id =~ /([0-9]+( [a-z] )?)/)
		{
		    $luku_id = $1;
		    $luku_id =~ s/ //g;
		}
		elsif ($luku_id =~ /([IVX]+)/)
		{
		    $luku_id = $1;
		}
		else
		{
		    $luku_id = "foo";
		}
	    }
	    # Luku end tag encountered
	    if ($line =~ /<\/saa:Luku>/)
	    {
		$luku_id = "";
	    }	    
	    # Pykala tag encountered
	    if ($line =~ /<saa:Pykala(>| )/)
	    {
		$link_depth = $link_depth + 1;
		if ($link_depth > 1)
		{
		    ; # no links inside links allowed
		}
		elsif ($line =~ /<saa:Pykala>/)
		{
		    $link_rejected = 1; # tag without identification
		}	
		elsif ($line =~ /<saa:Pykala ([^ ]+ )?saa1:identifiointiTunnus="[^"]{12,}">/)
		{
		    $link_rejected = 1; # too long identification attribute, probably quoted language-dependent text
		}
		elsif ($line =~ /<saa:Pykala [^>]*"([^" \.§]+).*">/)
		{
		    # add <link> elements and escape them as ¤link¤
		    if ($luku_id eq "")
		    {
			$line =~ s/<saa:Pykala [^>]*"([^" \.§]+).*">/¤link id="pykala_$1"¤/g;
		    }
		    else
		    {
			$line =~ s/<saa:Pykala [^>]*"([^" \.§]+).*">/¤link id="luku_${luku_id}_pykala_$1"¤/g;
		    }
		}
		else
		{
		    $link_rejected = 1; # something wrong with identification attribute
		}
	    }
	    # Pykala end tag encountered
	    if ($line =~ /<\/saa:Pykala>/)
	    {
		$link_depth = $link_depth - 1;
		if ($link_depth eq 0 && $link_rejected eq 1)
		{
		    $link_rejected = 0;
		}
		elsif ($link_depth eq 0)
		{
		    $line =~ s/<\/saa:Pykala>/¤\/link¤/g;
		}
	    }
	    
	    $line =~ s/<asi:AllekirjoitusOsa>/¤link id="allekirjoitusosa"¤/g;
	    $line =~ s/<\/asi:AllekirjoitusOsa>/¤\/link¤/g;
	    
	    $line =~ s/<saa:SaadosNimeke>/¤link id="saadosnimeke"¤/g;
	    $line =~ s/<\/saa:SaadosNimeke>/¤\/link¤/g;
	    
	    $line =~ s/<saa:Johtolause>/¤link id="johtolause"¤/g;
	    $line =~ s/<\/saa:Johtolause>/¤\/link¤/g;
	    
	    $line =~ s/<asi:IdentifiointiOsa>/¤link id="identifiointiosa"¤/g;
	    $line =~ s/<\/asi:IdentifiointiOsa>/¤\/link¤/g;
	}

	# mark tags to signal that sentence boundary can be inserted there, if needed
	$line =~ s/<saa:Momentti(Alakohta|Kohta)?Kooste>/<>/g;
	$line =~ s/<saa:SaadosValiotsikkoKooste>/<>/g;
	
	# get rid of xml tags (other than <> and <->)
	$line =~ s/<[^>][^>]+>//g;
	$line =~ s/<[^>\-]>//g;

	if ($link eq 1)
	{
	    # remove escape from ¤link¤ elements
	    $line =~ s/¤\/link/<\/link/g;
	    $line =~ s/¤link/<link/g;
	    $line =~ s/¤/>/g;
	    unless ($link_prefix eq "")
	    {
		# add filename to link ids
		$line =~ s/<link id="/<link id="${link_prefix}/g;
	    }
	}

	# get rid of empty lines
	$line =~ s/^ *\n//g;

	# todo: get rid of empty links:
	# perl -pe 's/>\n/>/g;' | perl -pe 's/<link[^>]*><\/link>//g;' | perl -pe 's/>/>\n/g;'

	print $line;
    }
}
