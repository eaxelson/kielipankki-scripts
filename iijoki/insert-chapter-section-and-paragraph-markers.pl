#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $empty_lines = 0;
my $latest_element = "";
my $first_line = "true";
my $first_part_encountered = "false";
my $first_chapter_of_part = "true";
my $first_section_of_chapter = "true";

foreach my $line ( <STDIN> ) {    

    $line =~ s/\x{000D}\x{000A}/\x{000A}/;

    if ($first_line eq "true")
    {
	$line = "###C: <section_before_first_part>\n###C: <paragraph>\n".$line;
	$first_line = "false";
    }
    # 025_Hyvasti_Iijoki.txt: luvussa 'YHDEKSÄS LUKU' on väliotsikko 'I LUKU' väliotsikoiden '3' ja '4' välissä.
    # Tämä tulkitaan väliotsikoksi seuraavassa elsif-kohdassa.
    elsif ($line =~ /^((ENSIMM\x{00C4}INEN|TOINEN|((KOLMAS|NELJ\x{00C4}S|VIIDES|KUUDES|SEITSEM\x{00C4}S|KAHDEKSAS|YHDEKS\x{00C4}S)(TOISTA)?)|KYMMENES|YHDESTOISTA|KAHDESTOISTA) LUKU)$/)
    {
	if ($first_part_encountered eq "false")
	{
	    $line = "###C: <\/paragraph>\n###C: <\/section_before_first_part>\n###C: <chapter title=\"".$1."\">\n###C: <paragraph type=\"heading\">\n".$line."###C: <\/paragraph>\n";
	    $first_part_encountered = "true";
	}
	else
	{
	    $line = "###C: <\/paragraph>\n###C: <\/section>\n###C: <\/chapter>\n###C: <chapter title=\"".$1."\">\n###C: <paragraph type=\"heading\">\n".$line."###C: <\/paragraph>\n";
	}
	$latest_element="<part>";
	$first_chapter_of_part = "true";
	print STDERR "chapter title: \"".$1."\"\n";
    }
    elsif ($first_part_encountered eq "true" && $line =~ /^([^a-z\n]+( [^a-z])*)$/)
    {
	if ($first_chapter_of_part eq "true")
	{
	    $line = "###C: <section title=\"".$1."\">\n###C: <paragraph type=\"heading\">\n".$line."###C: <\/paragraph>\n";
	    $first_chapter_of_part = "false";
	}
	else
	{
	    $line = "###C: <\/paragraph>\n###C: <\/section>\n###C: <section title=\"".$1."\">\n###C: <paragraph type=\"heading\">\n".$line."###C: <\/paragraph>\n";
	}
	$latest_element="<chapter>";
	$first_section_of_chapter = "true";
	print STDERR "  section title: \"".$1."\"\n";
    }
    elsif ($first_part_encountered eq "true" && $line =~ /^ *$/)
    {
	$empty_lines++;
    }
    elsif ($first_part_encountered eq "true")
    {
	if ($empty_lines > 0)
	{
	    if ($first_section_of_chapter eq "true")
	    {
		$line = "###C: <paragraph>\n".$line;
		$first_section_of_chapter = "false";
	    }
	    else
	    {
		$line = "###C: <\/paragraph>\n###C: <paragraph>\n".$line;
	    }
	    $latest_element = "<paragraph>";
	}
	elsif ($empty_lines == 1)
	{
	    $line = "###C: <\/paragraph>\n###C: <paragraph>\n".$line;
	    $latest_element = "<paragraph>";
	}
	$empty_lines = 0;
    }
    
    print $line;
}

print "###C: <\/paragraph>\n###C: <\/section>\n###C: <\/chapter>\nTNPP_INPUT_CANNOT_END_IN_COMMENT_LINE\n";
