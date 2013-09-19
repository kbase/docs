use strict;
use Data::Dumper;
use Carp;

=head1 NAME

get_eo_descriptions

=head1 SYNOPSIS

get_eo_descriptions [--url=http://kbase.us/services/plant_expression_service] < eoIDs

=head1 DESCRIPTION

This function provides the list of selected plant environment ontology IDs description.

=head2 Documentation for underlying call

Retrieve the list of selected plant environment ontology IDs (EOIDs) description corresponding to an input list of EOIDs.
 For example for an input list of EOIDs: EO:0007041,EO:0007049 the output is:
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

 echo 'EO:0007041' | get_eo_descriptions
 get_eo_descriptions --help
 get_eo_descriptions --version

=head1 VERSION

0.1

=cut

use Getopt::Long;
use Bio::KBase::PlantExpressionService::Client;

my $usage = "Usage: $0 [--url=http://kbase.us/services/plant_expression_service] < eoIDs\n";

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
	 Retrieve the list of selected plant environment ontology IDs (EOIDs) description corresponding to an input list of EOIDs.
	 For example for an input list of EOIDs: EO:0007041,EO:0007049 the output is:
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
	print "echo EO:0007049 | $0 --url=http://kbase.us/services/plant_expression_service \n";
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
my @input = <STDIN>;
my $istr = join(" ", @input);
$istr =~ s/[,|]/ /g;
@input = split /\s+/, $istr;
my $results = $oc->get_eo_descriptions(\@input);
foreach my $poID (keys %{$results}) {
  print "$poID\t".$results->{"$poID"}."\n";
}
