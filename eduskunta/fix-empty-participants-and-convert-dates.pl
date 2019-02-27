#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

foreach my $line ( <STDIN> ) {

    # remove empty participants in utterances
    $line =~ s/<utterance participant="" /<utterance /;
    # convert dates to YYYY-MM-DD format
    $line =~ s/date="([0-9]{2})\.([0-9]{2})\.([0-9]{4})"/date="$3\-$2\-$1"/;
    print $line;
}
