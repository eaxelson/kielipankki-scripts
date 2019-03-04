#!/usr/bin/perl

use strict;
use warnings;
use open qw(:std :utf8);

foreach my $line ( <STDIN> ) {
    
    # process only paragraph elements
    if ( $line =~ /^<paragraph / )
    {
	# Warning: suspicious participant name, leaving it out: "Ensimmäinen"
	$line =~ s/participant="Ensimm\x{00E4}inen"/participant="Ensimm\x{00E4}inen varapuhemies"/;
	# Warning: suspicious participant name, leaving it out: "Toinen"
	$line =~ s/participant="Toinen"/participant="Toinen varapuhemies"/;

	# Warning: speech type not recognized, leaving it out: "(vastauspuheenvuorro)"
	# Warning: speech type not recognized, leaving it out: "(vastauspuheenvuo- ro)"
	# Warning: speech type not recognized, leaving it out: "(vastauspuheen-vuoro)"
	# Warning: speech type not recognized, leaving it out: "(vastauspuheen- vuoro)"
	# Warning: speech type not recognized, leaving it out: "(vastauspu- heenvuoro)"
	# Warning: speech type not recognized, leaving it out: "(vastauspuheenvuo-ro)"
	$line =~ s/\(vastauspu\-? ?heen\-? ?vuo\-? ?r?ro\)/\(vastauspuheenvuoro\)/;

	# Warning: speech type not recognized, leaving it out: "(ryhmäpuheenvuo- ro)"
	$line =~ s/\(ryhm\x{00E4}puheenvuo\- ro\)/\(ryhm\x{00E4}puheenvuoro\)/;

	# Warning: speech type not recognized, leaving it out: "(esittelypuheenvuo-ro)"
	$line =~ s/\(esittelypuheenvuo\-ro\)/\(esittelypuheenvuoro\)/;

	# Warning: suspicious participant name, leaving it out: "Ensimminen varapuhemies ...
	# Warning: suspicious participant name, leaving it out: "Ensimmainen varapuhemies ...
	$line =~ s/participant="Ensimma?inen varapuhemies/participant="Ensimm\x{00E4}inen varapuhemies/;	
    }

    print $line;
}

