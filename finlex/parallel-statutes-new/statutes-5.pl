#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $before = "";
my $after = "";

while (<>) {

    ## PARTS
    if (/^<saa:Osa saa1:identifiointiTunnus="([^"]*)">/)
    {
	my $osa_id = $1;
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

	$before = join('','<<part id="',$osa_id,'">>',"\n");
    }
    elsif (/^<\/saa:Osa>/) { $after = "<</part>>\n"; }

    ## CHAPTERS
    # <saa:Luku saa1:identifiointiTunnus="6 luku">
    # <saa:Luku saa1:identifiointiTunnus="">
    # 2 LUKU (31.3.1879/12)
    # "Kiinteistövarallisuuden hallinta ja hoito"
    elsif (/^<saa:Luku saa1:identifiointiTunnus="([^"]*)">/)
    {
	my $luku_id = $1;
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
	print join('','<<chapter id="',$luku_id,'">>',"\n");
    }
    elsif (/^<saa:Luku>/)
    {
	$before = join('','<<chapter id="EMPTY"',">>\n");
    }
    elsif (/^<\/saa:Luku>/) { $after = "<</chapter>>\n"; }

    ## SECTIONS    
    # <saa:Pykala saa1:pykalaLuokitusKoodi="VoimaantuloPykala" saa1:identifiointiTunnus="27 §.">
    # <saa:Pykala saa1:pykalaLuokitusKoodi="Pykala" saa1:identifiointiTunnus="32 §.">
    # <saa:Pykala saa1:identifiointiTunnus="Voimaantulo" saa1:pykalaLuokitusKoodi="VoimaantuloSaannos">
    # <saa:Pykala>
    elsif (/^<saa:Pykala /)
    {
	if (/saa1:identifiointiTunnus="([^"]+)"/)
	{
	    my $pykala_id = $1;
	    if ($pykala_id =~ /.{12}/)
	    {
		$pykala_id = "EMPTY";
	    }
	    else
	    {
		$pykala_id =~ s/[\.§]//g;
		$pykala_id =~ s/\&amp\;//g; # sometimes this is part of tag
		$pykala_id =~ s/ //g; # e.g. "21 a " -> "21a"
	    }
	    $before = join('','<<section id="',$pykala_id,'"',">>\n");
	}	
    }
    elsif (/^<saa:Pykala>/)
    {
	$before = join('','<<section id="EMPTY"',">>\n");
    }
    elsif (/^<\/saa:Pykala>/) { $after = "<</section>>\n"; }

    ## PARAGRAPHS
    # <saa:KohdatMomentti>
    # <saa:MomenttiKooste>
    # <asi:SisaltoLiite>
    # <asi:SaadosLiite>
    # <saa:SaadosNimeke>
    # <saa:Johtolause>
    elsif (/^(<saa:KohdatMomentti>|<saa:MomenttiKooste>)/) { $before = join('','<<paragraph type="paragraph">>',"\n"); }
    elsif (/^(<\/saa:KohdatMomentti>|<\/saa:MomenttiKooste>)/) { $after = join('',"<</paragraph>>\n"); }
    elsif (/^<asi:(Sisalto|Saados)Liite>/) { $before = join('','<<paragraph type="LIITE">>',"\n"); }
    elsif (/^<\/asi:(Sisalto|Saados)Liite>/) { $after = join('',"<</paragraph>>\n"); }
    elsif (/^<saa:SaadosNimeke>/) { $before = join('','<<paragraph type="SAADOSNIMEKE">>',"\n"); }
    elsif (/^<\/saa:SaadosNimeke>/) { $after = join('',"<</paragraph>>\n"); }
    elsif (/^<saa:Johtolause>/) { $before = join('','<<paragraph type="JOHTOLAUSE">>',"\n"); }
    elsif (/^<\/saa:Johtolause>/) { $after = join('',"<</paragraph>>\n"); }

    ## SENTENCES
    # <sis:KappaleKooste>
    # <sis:SaadosKappaleKooste>
    # <saa:MomenttiJohdantoKooste>
    # <saa:MomenttiKohtaKooste>
    # <saa:MomenttiAlakohtaKooste>

    elsif (/^<\/sis:(Saados)?KappaleKooste>/) { $before = "<>\n"; }
    elsif (/^<\/saa:Momentti(Johdanto|Kohta|Alakohta)Kooste>/) { $before = "<>\n"; }

    print $before;
    $before = "";
    print;
    print $after;
    $after = "";
}
