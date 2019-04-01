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
my $type_found = 1; # whether type of statute has been extracted
my $osa_id = ""; # <saa:Osa> used in naming links

my $begin_paragraph = "";
my $end_paragraph = "";
my $begin_section = "";
my $end_section = "";
my $begin_chapter = "";
my $end_chapter = "";
my $begin_part = "";
my $end_part = "";

my $begin_heading_paragraph = "";
my $end_heading_paragraph = "";

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

    # Extract type of statute and print it as a separate line <type="type_of_statute">.
    # This line is used later when inserting <text> tag and finally removed from the vrt file.
    if ( $type_found != 0 && $line =~ /<saa:Saados met1:kieliKoodi=".." saa1:saadostyyppiNimi="([^"]*)">/ )
    {
	my $type = $1;
	# convert to lowercase ascii
	$type =~ s/\x{00E4}/a/g;
	$type =~ s/\x{00F6}/o/g;
	$type = lc $type;
	print join('','<type="',$type,'">',"\n");
	$type_found = 0;
    }

    # Extract IdentifiointiOsa, SaadosOsa, AllekirjoitusOsa
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
        # table entries sometimes contain hyphenated words extending to several lines
	# (,- is used when referring to money such as 200,-)
	# $line =~ s/^<te>(.*)[^, \t]\-<\/te>\n/$1<\->/g;

	if ( $line =~ /<saa:(Osa|Luku|Pykala)TunnusKooste>/ || $line =~ /<saa:SaadosOtsikkoKooste>/ )
	{
	    $begin_heading_paragraph = "<heading_paragraph>\n";
	}
	if ( $line =~ /<\/saa:(Osa|Luku|Pykala)TunnusKooste>/ || $line =~ /<\/saa:SaadosOtsikkoKooste>/ )
	{
	    $end_heading_paragraph = "<\/heading_paragraph>\n";
	}
	
	if ($link eq 1)
	{
	    # Osa tag encountered
	    if ($line =~ /<saa:Osa saa1:identifiointiTunnus="([^"]*)">/)
	    {
		$osa_id = $1;
		# Finnish: OSA, OSASTO, Osa, Osasto, osa, osasto
		$osa_id =~ s/(((O|o)sa(sto)?)|(OSA(STO)?))\.?//g;
		# Swedish: DEL, AVDELNINGEN, AVDELNING, Avdelning, Avdelningen, avdelning, avdelningen
		$osa_id =~ s/(AVDELNING(EN)?|(A|a)vdelning(en)?)\.?//;
		$osa_id =~ s/DEL//;

		# e.g. " II A " -> "II_A"
		$osa_id =~ s/^ +//;
		$osa_id =~ s/ +$//;
		$osa_id =~ s/ /_/g;

		if ( $osa_id eq "" ) { $osa_id = "EMPTY"; }

		$begin_part = "<part>\n";
	    }
	    # Osa end tag encountered
	    if ($line =~ /<\/saa:Osa>/)
	    {
		$osa_id = "";
		$end_part = "<\/part>\n"
	    }
	    # Luku tag encountered
	    if ($line =~ /<saa:Luku saa1:identifiointiTunnus="([^"]*)">/)
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
		    $luku_id = "EMPTY";
		}
		$begin_chapter = "<chapter>\n";
	    }
	    # Luku end tag encountered
	    if ($line =~ /<\/saa:Luku>/)
	    {
		# $luku_id = "";
		$end_chapter = "<\/chapter>\n";
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
		elsif ($line =~ /<saa:Pykala [^>]*saa1:identifiointiTunnus="([^"]+)">/)
		{
		    my $pykala = $1;
		    $pykala =~ s/[\.§]//g;
		    $pykala =~ s/\&amp\;//g; # sometimes this is part of tag
		    $pykala =~ s/ //g; # e.g. "21 a " -> "21a"
		    # add <link> elements (e.g. <link id="osa_2_luku_4_pykala_15">) and escape them as ¤link¤
		    my $link_id = $link_prefix;
		    if ( $osa_id ne "" ) { $link_id .= join("","osa_",$osa_id,"_"); }
		    if ( $luku_id ne "" ) { $link_id .= join("","luku_",$luku_id,"_"); }
		    $link_id .= join("","pykala_",$pykala);
		    $begin_section = join('','<link id=',$link_id,'">',"\n");
		    #$line =~ s/<saa:Pykala [^>]*"([^" \.§]+).*">/¤link id="${link_id}"¤/g;
		}
		else
		{
		    $link_rejected = 1; # something wrong with identification attribute
		}
		$begin_section .= "<section>\n";
	    }

	    # Pykala end tag encountered
	    if ($line =~ /<\/saa:Pykala>/)
	    {
		$link_depth = $link_depth - 1;
		if ($link_depth eq 0 && $link_rejected eq 1)
		{
		    $link_rejected = 0;
		    $end_section = "<\/section>\n";
		}
		elsif ($link_depth eq 0)
		{
		    $end_section = "<\/section>\n<\/link>\n"
		    #$line =~ s/<\/saa:Pykala>/¤\/link¤/g;
		}
		else
		{
		    $end_section = "<\/section>\n";
		}
	    }

	    # Momentti tag encountered (these do not overlap with each other or with
	    # "asi:AllekirjoitusOsa","saa:SaadosNimeke","saa:Johtolause","asi:IdentifiointiOsa").
	    if ($line =~ /<saa:MomenttiKooste>|<saa:KohdatMomentti>/)
	    {
		$begin_paragraph = join('','<paragraph type="paragraph">',"\n");
	    }
	    # Momentti end tag encountered
	    if ($line =~ /<\/saa:MomenttiKooste>|<\/saa:KohdatMomentti>/)
	    {
		$end_paragraph = "<\/paragraph>\n";
	    }

	    if ($line =~ /<saa:SisaltoMuuSaados>/)
	    {
		$begin_paragraph = join('','<paragraph type="other">',"\n");
	    }
	    if ($line =~ /<\/saa:SisaltoMuuSaados>/)
	    {
		$end_paragraph = "<\/paragraph>\n";
	    }

	    if ($line =~ /<saa:SaadosValiotsikkoKooste>/)
	    {
		$begin_paragraph = join('','<paragraph type="other">',"\n");
	    }
	    if ($line =~ /<\/saa:SaadosValiotsikkoKooste>/)
	    {
		$end_paragraph = "<\/paragraph>\n";
	    }

	    if ($line =~ /<ete>/)
	    {
		$begin_paragraph = join('','<paragraph type="other">',"\n");
	    }
	    if ($line =~ /<\/ete>/)
	    {
		$end_paragraph = "<\/paragraph>\n";
	    }
	    
	    # Insert <paragraph> and <link> around these tags
	    # (e.g. <paragraph type="saadosnimeke"> and <link id="saadosnimeke">)
	    my @tags = ("asi:AllekirjoitusOsa","saa:SaadosNimeke","saa:Johtolause","asi:IdentifiointiOsa");
	    for my $tag (@tags)
	    {
		if ( $line =~ /<${tag}>/ )
		{
		    my $ptype = $tag;
		    $ptype =~ s/asi\:|saa\://;
		    $ptype = lc $ptype;
		    $begin_paragraph = join('','<link id="',$link_prefix,$ptype,'">',"\n",'<paragraph type="',$ptype,'">',"\n");
		    #$line =~ s/<${tag}>/¤link id="${ptype}"¤/g;
		}
		if ( $line =~ /<\/${tag}>/ )
		{
		    $end_paragraph = "<\/paragraph>\n<\/link>\n";
		    #$line =~ s/<\/${tag}>/¤\/link¤/g;
		}
	    }
	}

	# mark tags with <> to signal that sentence boundary can be inserted here, if needed
	$line =~ s/<saa:Momentti(Alakohta|Kohta|Johdanto)?Kooste>/<>/g;
	# and with <.> to signal that it must be inserted here
	$line =~ s/<\/saa:Saados(Valiotsikko|Otsikko)Kooste>/<.>/g;

	# get rid of xml tags (other than <>, <.> and <->)
	$line =~ s/<[^>][^>]+>//g;
	$line =~ s/<[^>\-\.]>//g;

	# get rid of empty lines
	$line =~ s/^ *\n//g;

	# todo: get rid of empty links:
	# perl -pe 's/>\n/>/g;' | perl -pe 's/<link[^>]*><\/link>//g;' | perl -pe 's/>/>\n/g;'

	# Do not print empty heading paragraphs
	if ( $begin_heading_paragraph ne "" && $line eq "" ) { $begin_heading_paragraph = ""; }
	if ( $end_heading_paragraph ne "" && $line eq "" ) { $end_heading_paragraph = ""; }

	# <part><chapter><section><paragraph>
	print $begin_part;
	print $begin_chapter;
	print $begin_section;
	if ( $begin_paragraph ne "" && $begin_heading_paragraph ne "" ) { print "ERROR\n"; exit 1; }
	print $begin_paragraph;
	print $begin_heading_paragraph;

	print $line;

	# </paragraph></section></chapter></part>
	if ( $end_paragraph ne "" && $end_heading_paragraph ne "" ) { print "ERROR\n"; exit 1; }
	print $end_heading_paragraph;
	print $end_paragraph;
	print $end_section;
	print $end_chapter;
	print $end_part;

	$begin_heading_paragraph = ""; $end_heading_paragraph = "";
	$begin_paragraph = ""; $end_paragraph = "";
	$begin_section = ""; $end_section = "";
	$begin_chapter = "";  $end_chapter = "";
	$begin_part = "";  $end_part = "";
    }
}
