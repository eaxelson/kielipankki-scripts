#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

my $first_sentence_in_paragraph = "true";

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
    $line =~ s/^# [^<].*//;
    $line =~ s/^# //;
    print $line;

}
