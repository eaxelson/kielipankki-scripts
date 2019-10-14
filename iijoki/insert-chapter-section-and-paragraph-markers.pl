#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $empty_lines = 0;
my $line_number = 0;
my $latest_element = "";
my $first_line = "true";
my $first_part_encountered = "false";
my $first_chapter_of_part = "true";
my $first_section_of_chapter = "true";
my $notitletag = "false";
my $titletag = "false";

foreach my $line ( <STDIN> ) {    

    $line_number++;
    $line =~ s/\x{000D}\x{000A}/\x{000A}/;

    if ($line =~ /^<notitle>$/)
    {
	$notitletag = "true";
	next;
    }
    elsif ($line =~ /^<\/notitle>$/)
    {
	$notitletag = "false";
	next;
    }
    elsif ($line =~ /^<title>$/)
    {
	$titletag = "true";
    }
    elsif ($line =~ /^<\/title>$/)
    {
	$titletag = "false";
    }

    # text before first part
    if ($first_line eq "true")
    {
	$line = "###C: <paragraph>\n".$line;
	$first_line = "false";
    }
    # "I" and "II" are used only in the last book
    elsif ($line =~ /^(((ENSIMM\x{00C4}INEN|TOINEN|((KOLMAS|NELJ\x{00C4}S|VIIDES|KUUDES|SEITSEM\x{00C4}S|KAHDEKSAS|YHDEKS\x{00C4}S)(TOISTA)?)|KYMMENES|YHDESTOISTA|KAHDESTOISTA) LUKU)|(II?))$/)
    {
	if ($first_part_encountered eq "false")
	{
	    $line = "###C: <\/paragraph>\n###C: <chapter title=\"".$1."\">\n###C: <paragraph type=\"heading\">\n".$line."###C: <\/paragraph>\n";
	    $first_part_encountered = "true";
	}
	else
	{
	    $line = "###C: <\/paragraph>\n###C: <\/section>\n###C: <\/chapter>\n###C: <chapter title=\"".$1."\">\n###C: <paragraph type=\"heading\">\n".$line."###C: <\/paragraph>\n";
	}
	$empty_lines=0;
	$latest_element="<chapter>";
	$first_chapter_of_part = "true";
	print STDERR "chapter title: \"".$1."\"\n";
    }
    elsif ($first_part_encountered eq "true" && $notitletag eq "false" && $empty_lines > 1 && $line =~ /^([^a-z\n]+( [^a-z])*)$/)
    {
	my $title = $1;
	my $issue_warning = "false";
	if ($latest_element eq "<section>")
	{
	    $issue_warning = "true";
	}
	if ($line =~ /^[1-9]([0-9])?$/)
	{
	    ;
	}
	elsif ($line =~ /[A-Z\x{00C4}\x{00D6}] [A-Z\x{00C4}\x{00D6}] [A-Z\x{00C4}\x{00D6}] / || $line !~ /[A-Z\x{00C4}\x{00D6}]/)
	{
	    if ($titletag eq "false")
	    {
		$issue_warning = "true";
	    }
	}

	if ($issue_warning eq "true")
	{
	    print STDERR "----- warning: spurious title (on line ".$line_number.")\n";
	}

	if ($first_chapter_of_part eq "true")
	{
	    $line = "###C: <section title=\"".$title."\">\n###C: <paragraph type=\"heading\">\n".$line."###C: <\/paragraph>\n";
	    $first_chapter_of_part = "false";
	}
	else
	{
	    $line = "###C: <\/paragraph>\n###C: <\/section>\n###C: <section title=\"".$title."\">\n###C: <paragraph type=\"heading\">\n".$line."###C: <\/paragraph>\n";
	}

	$empty_lines=0;
	$latest_element="<section>";
	$first_section_of_chapter = "true";
	print STDERR "  section title: \"".$title."\"\n";
    }
    elsif ($first_part_encountered eq "true" && $line =~ /^ *$/)
    {
	$empty_lines++;
    }
    elsif ($first_part_encountered eq "true")
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
	$empty_lines = 0;
    }
    
    print $line;
}

print "###C: <\/paragraph>\n###C: <\/section>\n###C: <\/chapter>\nTNPP_INPUT_CANNOT_END_IN_COMMENT_LINE\n";
