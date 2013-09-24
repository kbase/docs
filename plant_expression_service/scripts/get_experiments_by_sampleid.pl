use strict;
use Data::Dumper;
use Carp;

=head1 NAME

 get_experiments_by_sampleid

=head1 SYNOPSIS

 get_experiments_by_sampleid [--url=http://kbase.us/services/plant_expression_service] < sampleIDs

=head1 DESCRIPTION

 This function provides the expression values for given experiment sample IDs (GSM#s).

=head2 Documentation for underlying call

This function provides the expression values  corresponding to each given experiment sample in the input list of sample ids (GSM#s).For each sample in the input list of samples, it extracts the expressed genes (kbase gene identifier) and their corresponding expression values.  e.g.for samples:"GSM128731","GSM131686"
 Output looks like this:
 "","GSM128731","GSM131686"
 "kb|g.3899.locus.23281",4.19051374151256,4.81544532287956
 "kb|g.3899.locus.23342",8.0461118314498,7.75470811901751
 "kb|g.3899.locus.23319",8.95008412287335,8.0937520447078
 "kb|g.3899.locus.23295",6.70090411599666,7.42720023331292
 "kb|g.3899.locus.23378",8.79308438662897,8.23643301305399

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

 echo GSM128731 | get_experiments_by_sampleid
 get_experiments_by_sampleid --help
 get_experiments_by_sampleid --version

=head1 VERSION

0.1

=cut

use Getopt::Long;
use Bio::KBase::PlantExpressionService::Client;

my $usage = "Usage: $0 [--url=http://kbase.us/services/plant_expression_service] < sampleIDs\n";

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
	This function provides the expression values  corresponding to each given experiment sample in the input list of sample ids (GSM#s).For each sample in the input list of samples, it extracts the expressed genes (kbase gene identifier) and their corresponding expression values. e.g.for samples:"GSM128731","GSM131686"
 Output looks like this:
 "","GSM128731","GSM131686"
 "kb|g.3899.locus.23281",4.19051374151256,4.81544532287956
 "kb|g.3899.locus.23342",8.0461118314498,7.75470811901751
 "kb|g.3899.locus.23319",8.95008412287335,8.0937520447078
 "kb|g.3899.locus.23295",6.70090411599666,7.42720023331292
 "kb|g.3899.locus.23378",8.79308438662897,8.23643301305399

MAN

        print "$usage\n";
	print "\n";
	print "General options\n";
	print "\t--url=[http://kbase.us/services/plant_expression_service]\t\turlname of the server\n";
	print "\t--help\t\tprint help information\n";
	print "\t--version\t\tprint version information\n";
	print "\n";
	print "Examples: \n";
	print "echo GSM128731,GSM131686,GSM131687 | get_experiments_by_sampleid\n";
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
my @iinput;
foreach (@input){
push @iinput,$_ if $_ =~ /GSM/;
}

#print "@iinput\n";
#die;

my $results = $oc->get_experiments_by_sampleid(\@iinput);
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
