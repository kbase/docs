use strict;
use Data::Dumper;
use Carp;

=head1 NAME

get_repid_by_sampleid

=head1 SYNOPSIS

get_repid_by_sampleid [--url=http://kbase.us/services/plant_expression_service] < sampleIDs

=head1 DESCRIPTION

This function finds out the replicate information for expression samples of the experiments. 


=head2 Documentation for underlying call

For a given list of expression experiment samples (GSM#s):GSM131288,GSM131291,GSM131292
find out the replicate ids. e.g  output looks like:
1605,1605,1604
All replicates have same identifier. e.g GSM131288 and GSM131291 are sample replicates as identified by replicate id 1605.

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

 get_repid_by_sampleid --url=http://kbase.us/services/plant_expression_service
 get_repid_by_sampleid --help
 get_repid_by_sampleid --version

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
	For a given list of expression experiment samples (GSM#s):GSM131288,GSM131291,GSM131292 find out the replicate ids. e.g  output looks like: 1605,1605,1604. All replicates have same identifier. e.g GSM131288 and GSM131291 are sample replicates as identified by replicate id 1605.
MAN

	print "$usage\n";
	print "\n";
	print "General options\n";
	print "\t--url=[http://kbase.us/services/plant_expression_service]\t\turlname of the server\n";
	print "\t--help\t\tprint help information\n";
	print "\t--version\t\tprint version information\n";
	print "\n";
	print "Examples: \n";
	print "echo GSM131288,GSM131291,GSM131292| $0 --url=http://kbase.us/services/plant_expression_service \n";
	print "\n";
	print "$0 --help\tprint out help\n";
	print "\n";
	print "$0 --version\tprint out version information\n";
	print "\n";
	print "Report bugs to Fei He at feihe\@bnl.gov\n";
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
	print "Written by Fei He, Shinjae Yoo and Sunita Kumari\n";
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



my $results = $oc->get_repid_by_sampleid(\@iinput);
my %hash = %$results;
my @a_tem;

foreach my $repID (@iinput) {
push @a_tem,$hash{$repID};
}

print  join ",", @a_tem;
print  "\n";
