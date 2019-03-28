#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $header_paragraph = "";

foreach my $line ( <STDIN> ) {

    if ( $line =~ /^<heading_paragraph>$/ )
    {
	$header_paragraph .= $line;
    }
    elsif ( $line =~ /^<\/heading_paragraph>$/ )
    {
	$header_paragraph .= $line;
	my $title = $header_paragraph;
	$title =~ s/<\/?heading_paragraph>//g;
	$title =~ s/<\/?sentence( n="[0-9]+")?>//g;
	$title =~ s/\n/ /g;
	$title =~ s/^ +//g;
	$title =~ s/ +$//g;
	$title =~ s/ +/ /g;
	$title =~ s/^(.*)$/<title="$1">/;
	$title .= "\n";
	print $title;
	print $header_paragraph;
	$header_paragraph = "";
    }
    elsif ( $header_paragraph ne "" )
    {
	$header_paragraph .= $line;
    }
    else
    {
	print $line;
    }

}

