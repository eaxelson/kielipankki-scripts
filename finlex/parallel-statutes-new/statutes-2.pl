#!/usr/bin/perl


use strict;
use warnings;
use open qw(:std :utf8);

my $table = 0;
my $te = 0;

foreach my $line ( <STDIN> ) {

    # skip tables
    if ($table eq 1)
    {
	if ($line =~ /<\/tau:table>/) { $table = 0; }
	next;
    }
    if ( $line =~ /<tau:table[^>]*>/ )
    {
	$table = 1;
	next;
    }
    # skip table entries
    if ($te eq 1)
    {
	if ($line =~ /<\/te>/) { $te = 0; }
	next;
    }
    if ( $line =~ /<te>/ )
    {
	$te = 1;
	next;
    }
    
    # Replace <br/> with space
    $line =~ s/<br\/>/ /g;
    
    # Get rid of extra whitespace
    $line =~ s/\t//g;
    $line =~ s/ +/ /g;
    $line =~ s/^ //g;
    $line =~ s/ $//g;
    
    print $line;

}
