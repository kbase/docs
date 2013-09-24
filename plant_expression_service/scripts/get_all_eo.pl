use strict;
use Data::Dumper;
use Carp;

=head1 NAME

get_all_eo

=head1 SYNOPSIS

get_all_eo [--url=http://kbase.us/services/plant_expression_service]

=head1 DESCRIPTION

Retrieve all environment ontology terms.

=head2 Documentation for underlying call

Retrieve the list of all plant environment ontology IDs (EOIDs) currently available in the database.
 For example: 
 EO:0007001	UV-B light regimen
 EO:0007002	UV-A light regimen
 EO:0007041	antibiotic regimen
 EO:0007049	soil environment

=head1 OPTIONS

=over 6

=item B<-u> I<[http://kbase.us/services/plant_expression_service]> B<--url>=I<[http://kbase.us/services/plant_expression_service]>
hostname of the server

=item B<--help>
prints help information

=item B<--version>
print version information

=back

=head1 EXAMPLE

get_all_eo

=head1 VERSION

0.1

=cut

use Getopt::Long;
use Bio::KBase::PlantExpressionService::Client;

my $usage = "Usage: $0 [--url=http://kbase.us/services/plant_expression_service]\n";

my $url       = "http://kbase.us/services/plant_expression_service";
my $help       = 0;
my $version    = 0;

GetOptions("help"       => \$help,
           "version"    => \$version,
           "url=s"     => \$url) or die $usage;

if($help)
{
    print <<MAN;
    DESCRIPTION
	Retrieve the list of all plant environment ontology IDs (EOIDs) currently available in the database.
	For example:
        EO:0007001	UV-B light regimen
        EO:0007002	UV-A light regimen
        EO:0007041	antibiotic regimen
        EO:0007049	soil environment
MAN

	print "$usage\n";
	print "\n";
	print "General options\n";
	print "\t--url=[http://kbase.us/services/plant_expression_service]\t\turlname of the server\n";
	print "\t--help\t\tprint help information\n";
	print "\t--version\t\tprint version information\n";
	print "\n";
	print "Examples: \n";
	print "$0 --url=http://kbase.us/services/plant_expression_service \n";
	print "\n";
	print "$0 --help\tprint out help\n";
	print "\n";
	print "$0 --version\tprint out version information\n";
	print "\n";
	print "Report bugs to Shinjae Yoo at sjyoo\@bnl.gov\n";
	exit(0);
}

if($version)
{
	print "$0 version 0.1\n";
	print "Copyright (C) 2012 Shinjae Yoo\n";
	print "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n";
	print "This is free software: you are free to change and redistribute it.\n";
	print "There is NO WARRANTY, to the extent permitted by law.\n";
	print "\n";
	print "Written by Shinjae Yoo and Sunita Kumari\n";
	exit(0);
}

die $usage unless @ARGV == 0;

my $oc = Bio::KBase::PlantExpressionService::Client->new($url);
my $results = $oc->get_all_eo();
foreach my $poID (keys %{$results}) {
    print "$poID\t".$results->{"$poID"}."\n";
}
