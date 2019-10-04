#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $first_sentence_in_paragraph = "true";

print "<text>\n";

foreach my $line ( <STDIN> ) {    

    if ($line =~ /^# <\/paragraph>$/)
    {
	$first_sentence_in_paragraph = "true";
	$line = "<\/sentence>\n<\/paragraph>\n";
    }
    elsif ($line =~ /^# sent_id = [0-9]+$/)
    {
	if ($first_sentence_in_paragraph eq "true")
	{
	    $line = "<sentence>\n";
	    $first_sentence_in_paragraph = "false";
	}
	else
	{
	    $line = "<\/sentence>\n<sentence>\n";
	}
    }
    $line =~ s/<section_before_first_part>/<section type="???">/;
    $line =~ s/<\/section_before_first_part>/<\/section>/;
    $line =~ s/^# [^<].*//;
    $line =~ s/^# //;
    $line =~ s/^\n$//;
    print $line;

}

print "<\/text>\n";