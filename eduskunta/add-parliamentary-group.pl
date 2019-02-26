#!/usr/bin/perl

# Add attribute '(parliamentary) group' to paragraph elements,
# if it can be extracted from attribute 'participant' of paragraph.

use strict;
use warnings;
use open qw(:std :utf8);

my $remove_group_from_participant = "true";

foreach my $line ( <STDIN> ) {

    # process only paragraph elements
    if ( $line =~ /^<paragraph / )
    {
	# exit if participant is not given
	unless ( $line =~ /participant="/ )
	{
	    print "Error: no participant given for paragraph: ";
	    print $line;
	    print "\n";
	    exit 1;
	}
	# extract value of participant and modify it to get group
	my $group = $line;
	$group =~ s/.*participant="([^"]+)".*/$1/;

	# group given after slash, e.g. "/kesk", "/kok", "/sd" etc.
	if ( $group =~ /\// )
	{
	    $group =~ s/.*\/([a-öA-Ö0-9]*).*/$1/;
	    $group =~ s/^\s+|\s+$//g;
	    if ( $remove_group_from_participant eq "true" )
	    {
		$line =~ s/\s\/[a-öA-Ö0-9]*//;
	    }
	}
	# group given inside first parentheses, e.g. "(vas)", "(kd)", "(ps)" etc.
	elsif ( $group =~ /\([^\)]/ )
	{
	    $group =~ s/[^\(]*\(([^\)]+)\).*/$1/;
	    $group =~ s/^\s+|\s+$//g;
	    # "(koputtaa)" is a remark, not a group 
	    if ( $group eq "koputtaa" )
	    {
		$group = "";
	    }
	    else
	    {
		if ( $remove_group_from_participant eq "true" )
		{
		    $line =~ s/\s?\([^\)]+\)//;
		}
	    }
	}
	# no group given
	else
	{
	    $group = "";
	}

	# append group attribute, if group was found
	unless ( $group eq "" )
	{
	    $line =~ s/>/ group="$group">/;
	}

	# remove content in parentheses in participant
	$line =~ s/(participant="[^"\(]+)(\([^"\)]+\))/$1/g;

	# and append it to attribute 'extra'
	if ( defined $2 )
	{
	    my $extra = $2;
	    $extra =~ s/\((.*)\)/$1/;
	    $line =~ s/>/ extra="$extra">/;
	}

	# Remove ordinal before participant name
	$line =~ s/participant="[0-9]+\. /participant="/g;

	# get rid of extra space and use only ordinary space
	$line =~ s/\h/ /g;
	$line =~ s/ +/ /g;
	$line =~ s/ "/"/g;
    }

    print $line;
}
