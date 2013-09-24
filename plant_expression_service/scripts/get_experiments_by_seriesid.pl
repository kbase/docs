use strict;
use Data::Dumper;
use Carp;

=head1 NAME

get_experiments_by_seriesid

=head1 SYNOPSIS

get_experiments_by_seriesid [--url=http://kbase.us/services/plant_expression_service] < seriesIDs

=head1 DESCRIPTION

This function provides the expression values, samples (GSM#) for the corresponding experiment (GSE series). 

=head2 Documentation for underlying call

    This function provides the expression data for each experiment corresponding to the given list of series (GSE#s). It first retrieves the experiments sample ids (GSM#s) for each series and subsequently, it extracts the expressed genes and their corresponding expression values for each experiment. It then returns a table of data containing GSE#, GSM#, Expressed Gene ID, and Expression Value.*/

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

 echo 'GSE5684' | get_experiments_by_seriesid
 get_experiments_by_seriesid --help
 get_experiments_by_seriesid --version

=head1 VERSION

0.1

=cut

use Getopt::Long;
use Bio::KBase::PlantExpressionService::Client;

my $usage = "Usage: $0 [--url=http://kbase.us/services/plant_expression_service] < seriesIDs\n";

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
	This function provides the expression data for each experiment corresponding to the given list of series (GSE#s). It first retrieves the experiments sample ids (GSM#s) for each series and subsequently, it extracts the expressed genes and their corresponding expression values for each experiment. It then returns a table of data containing GSE#, GSM#, Expressed Gene ID, and Expression Value.*/
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
my $results = $oc->get_experiments_by_seriesid(\@input);
my @genes = @{$results->{"genes"}};
my $rh_sid2values = $results->{"series"};
my @sids = sort keys %{$rh_sid2values};

#print header
print "\"\"";
foreach my $sid (@sids) {
  print ",\"$sid\"";
}
print "\n";

#print values
for(my $i = 0; $i <= $#genes; $i = $i+1) {
  print "\"$genes[$i]\"";
  foreach my $sid (@sids) {
    print ",".${$rh_sid2values->{$sid}}[$i];
  }
  print "\n";
}
