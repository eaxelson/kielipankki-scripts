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
	    print STDERR "Error: no participant given for paragraph: ";
	    print STDERR $line;
	    print STDERR "\n";
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
	    $group =~ s/.*\/([a-z\x{00E4}\x{00F6}A-Z\x{00C4}\x{00D6}0-9]*).*/$1/;
	    $group =~ s/^\s+|\s+$//g;
	    if ( $remove_group_from_participant eq "true" )
	    {
		$line =~ s/\s\/[a-z\x{00E4}\x{00F6}A-Z\x{00C4}\x{00D6}0-9]*//;
	    }
	}
	# group given inside first parentheses, e.g. "(vas)", "(kd)", "(ps)" etc.
	elsif ( $group =~ /\([^\)]/ )
	{
	    $group =~ s/[^\(]*\(([^\)]+)\).*/$1/;
	    $group =~ s/^\s+|\s+$//g;

	    # "(koputtaa)" is speech type, not a group
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
	    if( $group =~ /^(kd|kesk|kok|m11|ps|r|sd|vas|vihr|vr)$/ )
	    {
		$line =~ s/>/ group="$group">/;
	    }
	    else
	    {
		print STDERR "Warning: parliamentary group not recognized: ";
		print STDERR $group;
		print STDERR ", leaving it out.";
		print STDERR "\n";
	    }
	}

	# remove content in parentheses in participant
	$line =~ s/(participant="[^"\(]+)(\([^"\)]+\))/$1/g;
	# and append it to attribute 'type'
	if ( defined $2 )
	{
	    my $type = $2;
	    $type =~ s/\((.*)\)/$1/;
	    $type =~ s/(vastaus|ryhm\x{00E4}|esittely)pu\-? ?heen\-? ?vuo\-? ?rr?o/$1puheenvuoro/;
	    $type =~ s/Vastauspuheenvuoro/vastauspuheenvuoro/;
	    $type =~ s/\x{00E4}/a/g;

	    if ( $type eq "vastauspuheenvuoro" ||
		 $type eq "ryhmapuheenvuoro" ||
		 $type eq "esittelypuheenvuoro" ||
		 $type eq "koputtaa" )
	    {
		$line =~ s/>/ type="$type">/;
	    }
	    else
	    {
		print STDERR "Warning: speech type not recognized: ";
		print STDERR $type;
		print STDERR ", leaving it out.";
		print STDERR "\n";
	    }
	}

	# exctract possible role in participant
	# and append it to attribute 'role', but do not remove it
	my $possible_role = $participant;
	if ( $possible_role =~ /[A-Z\x{00C4}\x{00D6}][a-z\x{00E4}\x{00F6}]+(\- ja [a-z\x{00E4}\x{00F6}]+)?ministeri/ ||
	     $possible_role =~ /Eduskunnan oikeusasiamies/ ||
	     $possible_role =~ /Ensimm\x{00E4}inen puhemies/ ||
	     $possible_role =~ /Ensimm\x{00E4}inen varapuhemies/ ||
	     $possible_role =~ /Ik\x{00E4}puhemies/ ||
	     $possible_role =~ /Puhemies/ ||
	     $possible_role =~ /Puhuja/ ||
	     $possible_role =~ /Toinen varapuhemies/ ||
	     $possible_role =~ /Valtioneuvoston apulaisoikeuskansleri/ ||
	     $possible_role =~ /Valtioneuvoston oikeuskansleri/ ||
	     $possible_role =~ /varaj\x{00E4}senen\x{00E4}\x{00E4}n( kansanedustaja)?/ )
	{
	    print $possible_role;
	    if ( defined $& )
	    {
		my $role = $&;
		$role = lc $role;
		$role =~ s/\-//g;
		$role =~ s/ /_/g;
		$role =~ s/\x{00E4}/a/g;
		$role =~ s/\x{00F6}/o/g;
		$role =~ s/^ensimmainen_puhemies$/puhemies/g;
		$role =~ s/^varajasenenaan(_kansanedustaja)?$/varajasen/g;
		$line =~ s/>/ role="$role">/;
	    }
	}
	elsif ( $possible_role =~ /Ensimm\x{00E4}inen/ ||
		$possible_role =~ /Toinen/ )
	{
	    if ( defined $& )
	    {
		my $role = $&;
		$role = lc $role;
		$role =~ s/\x{00E4}/a/g;
		$line =~ s/>/ role="${role}_varapuhemies">/;
	    }
	}
	elsif ( $possible_role =~ /Ensimma?inen varapuhemies/ )
	{
	    $line =~ s/>/ role="ensimmainen_varapuhemies">/;
	}

	# Remove ordinal before participant name
	$line =~ s/participant="[0-9]+\. /participant="/g;
    }

    print $line;
}

