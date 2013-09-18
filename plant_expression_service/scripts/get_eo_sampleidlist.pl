use strict;
use Data::Dumper;
use Carp;

=head1 NAME

get_eo_sampleidlist

=head1 SYNOPSIS

get_eo_sampleidlist [--url=http://kbase.us/services/plant_expression_service]  < eoIDs

=head1 DESCRIPTION

Find out the samples from those expression experiments that have been performed for one or more environmental conditions (EO) of interest.


=head2 Documentation for underlying call

Retrieve the list of expression samples (GSM#s) that correspond to one or more of the environmental conditions of interest. for example if the input is:
 EO:0007107

 then the output looks like:
 EO:0007107      Arabidopsis thaliana    GSM131147
 EO:0007107      Arabidopsis thaliana    GSM131148
 EO:0007107      Arabidopsis thaliana    GSM131149
 EO:0007107      Populus trichocarpa     GSM431198
 EO:0007107      Populus trichocarpa     GSM431199
 EO:0007107      Populus trichocarpa     GSM431200



=head1 OPTIONS

=over 6

=item B<-u> I<[http://kbase.us/services/plant_expression_service]> B<--url>=I<[http://kbase.us/services/plant_expression_service]>
hostname of the server

=item B<--species>
species of interest e.g Ara for Arabidopsis and Pop for Poplar

=item B<--help>
prints help information

=item B<--version>
print version information

=back

=head1 EXAMPLE

 echo 'EO:0007107' | get_eo_sampleidlist --species=Ara
 get_eo_sampleidlist --help
 get_eo_sampleidlis --version

=head1 VERSION

0.1

=cut

use Getopt::Long;
use Bio::KBase::PlantExpressionService::Client;

my $usage = "Usage: $0 [--url=http://kbase.us/services/plant_expression_service] < eoIDs\n";

my $url       = "http://kbase.us/services/plant_expression_service";
my $help       = 0;
my $version    = 0;
my $sname=0;


GetOptions("help"       => \$help,
           "version"    => \$version,
           "url=s"     => \$url,
		"species=s" => \$sname) or die $usage;

if($help)
{
    print <<MAN;
    DESCRIPTION
	Retrieve the list of expression samples (GSM#s) that correspond to one or more of the environmental conditions of interest. for example if the input is:
	 EO:0007107

	 then the output looks like:
	 EO:0007107      Arabidopsis thaliana    GSM131147
         EO:0007107      Arabidopsis thaliana    GSM131148
         EO:0007107      Arabidopsis thaliana    GSM131149
         EO:0007107      Populus trichocarpa     GSM431198
         EO:0007107      Populus trichocarpa     GSM431199
         EO:0007107      Populus trichocarpa     GSM431200
MAN

	print "$usage\n";
	print "\n";
	print "General options\n";
	print "\t--url=[http://kbase.us/services/plant_expression_service]\t\turlname of the server\n";
	print "\t--help\t\tprint help information\n";
	print "\t--version\t\tprint version information\n";
	print "\n";
	print "Examples: \n";

print "\necho EO:0007049 | get_eo_sampleidlist  --species=Ara\n\n";

print "\necho EO:0007049 |get_eo_sampleidlist  --species=Pop\n\n";

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


$sname="thaliana" if $sname=~/^A/;
$sname="trichocarpa" if $sname =~/^P/;

my $oc = Bio::KBase::PlantExpressionService::Client->new($url);
my @input = <STDIN>;
my $istr = join(" ", @input);
$istr =~ s/[,|]/ /g;
@input = split /\s+/, $istr;
my $results = $oc->get_eo_sampleidlist(\@input);
foreach my $poID (keys %{$results}) {
  foreach my $sidr (@{$results->{"$poID"}}) {
    my $lsname = $$sidr[0];
    my $sid = $$sidr[1];
    if($sname eq "0"){
      print "$poID\t$lsname\t$sid\n" ;
    }else{
      print "$poID\t$lsname\t$sid\n" if $lsname =~ /$sname/ ;
    }

  }
}
