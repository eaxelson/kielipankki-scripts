#!/usr/bin/perl

# Add attribute '(parliamentary) group' to paragraph elements,
# if it can be extracted from attribute 'participant' of paragraph.

use strict;
use warnings;
use open qw(:std :utf8);

# if parliamentary group is found, remove it from value of attribute 'participant'
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

	# get rid of extra space and use only ordinary space
	$line =~ s/\h/ /g;
	$line =~ s/ +/ /g;
	$line =~ s/ "/"/g;

	# extract value of participant and modify it to get additional attributes
	my $participant = $line;
	$participant =~ s/.*participant="([^"]+)".*/$1/;

	# group given after slash, e.g. "/kesk", "/kok", "/sd" etc.
	my $group = $participant;
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
	# and append it to attribute 'remark'
	if ( defined $2 )
	{
	    my $remark = $2;
	    $remark =~ s/\((.*)\)/$1/;
	    $line =~ s/>/ remark="$remark">/;
	}

	# exctract possible role in participant
	# and append it to attribute 'role', but do not remove it
	my $possible_role = $participant;
	if ( $possible_role =~ /[A-Ö][a-ö]+(\- ja [a-ö]+)?ministeri/ ||
	     $possible_role =~ /Eduskunnan oikeusasiamies/ ||
	     $possible_role =~ /Ensimm\x{00E4}inen puhemies/ ||
	     $possible_role =~ /Ensimm\x{00E4}inen varapuhemies/ ||
	     $possible_role =~ /Ik\x{00E4}puhemies/ ||
	     $possible_role =~ /Puhemies/ ||
	     $possible_role =~ /Puhuja/ ||
	     $possible_role =~ /Toinen varapuhemies/ ||
	     $possible_role =~ /Valtioneuvoston apulaisoikeuskansleri/ ||
	     $possible_role =~ /Valtioneuvoston oikeuskansleri/ ||
	     $possible_role =~ /varaj\x{00E4}senenään( kansanedustaja)/ )
	{
	    print $possible_role;
	    if ( defined $& )
	    {
		my $role = $&;
		$line =~ s/>/ role="$role">/;
	    }
	}
	elsif ( $possible_role =~ /Ensimm\x{00E4}inen/ ||
		$possible_role =~ /Toinen/ )
	{
	    if ( defined $& )
	    {
		my $role = $&;
		$line =~ s/>/ role="$role \(vara\)puhemies">/;
	    }
	}
	elsif ( $possible_role =~ /Ensimma?inen varapuhemies/ )
	{
	    $line =~ s/>/ role="Ensimm\x{00E4}inen varapuhemies">/;
	}

	# Remove ordinal before participant name
	$line =~ s/participant="[0-9]+\. /participant="/g;
    }

    print $line;
}

