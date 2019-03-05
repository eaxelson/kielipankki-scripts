#!/usr/bin/perl

# Read vrt from standard input and perform the following substitutions:
#
# * remove empty participant attributes from utterances
# * convert date attributes from DD.MM.YYYY to YYYY-MM-DD
# * fix some misspelled words in paragraph elements
#
# Output vrt to standard output.

use strict;
use warnings;
use open qw(:std :utf8);

foreach my $line ( <STDIN> ) {

    # remove empty participants in utterances
    $line =~ s/^<utterance participant="" /<utterance /;
    # convert dates to YYYY-MM-DD format in text elements
    if ( $line =~ /^<text / )
    {
	$line =~ s/date="([0-9]{2})\.([0-9]{2})\.([0-9]{4})"/date="$3\-$2\-$1"/;
    }
    # fix some misspelled or words in paragraph elements
    if ( $line =~ /^<paragraph / )
    {
	# "varapuhemies" left out
	$line =~ s/participant="Ensimm\x{00E4}inen"/participant="Ensimm\x{00E4}inen varapuhemies"/;
	$line =~ s/participant="Toinen"/participant="Toinen varapuhemies"/;
	# misspelled "vastauspuheenvuoro",
	$line =~ s/\(vastauspu\-? ?heen\-? ?vuo\-? ?r?ro\)/\(vastauspuheenvuoro\)/;
	# "ryhmäpuheenvuoro",
	$line =~ s/\(ryhm\x{00E4}puheenvuo\- ro\)/\(ryhm\x{00E4}puheenvuoro\)/;
	# "esittelypuheenvuoro",
	$line =~ s/\(esittelypuheenvuo\-ro\)/\(esittelypuheenvuoro\)/;
	# and "ensimmäinen varapuhemies"
	$line =~ s/participant="Ensimma?inen varapuhemies/participant="Ensimm\x{00E4}inen varapuhemies/;	
    }

    print $line;
}

