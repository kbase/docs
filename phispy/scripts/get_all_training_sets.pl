use strict;
use Bio::KBase::Phispy::Client;
use Getopt::Long;
use JSON;

use Pod::Usage;

=head1 NAME

get_all_training_sets

=head1 SYNOPSIS

get_all_training_sets > set-list

=head1 DESCRIPTION

Lists the available training sets for use in L<find_prophages>.

=head1 COMMAND-LINE OPTIONS

Usage: get_all_training_sets > set-list

=over

=item	--help or -h this page.

=back

=head1 AUTHORS

Phispy service by Sajia Akhter of the Rob Edwards lab. Wrapper by Robert Olson at Argonne National Laboratory.

=cut


my $url;
my $port;
my $help;

my $usage = "Usage: get_all_training_sets [--port port] [--url url]\n";

my $rc = GetOptions("port=s" => \$port,
		    "url=s"  => \$url,
		    "h",     => \$help,
		    "help",  => \$help,
		    ) or pod2usage(0);
pod2usage(-exitstatus => 0,
	  -output => \*STDOUT,
	  -verbose => 2,
	  -noperldoc => 1,
	 ) if $help;

if (!$rc || @ARGV != 0)
{
    die "$usage";
}

if (!$url)
{
    if ($port)
    {
	$url = "http://localhost:$port/";
    }
#     else
#     {
# 	die "No URL or port specified\n";
#     }
}
elsif ($url && $port)
{
    $url = $url . ":$port";
}
my $client = Bio::KBase::Phispy::Client->new($url);

my $set_list = $client->get_all_training_sets(@ARGV);

for my $set (@$set_list)
{
	print "$set->{training_set_id}\t$set->{genome_name}\n";
}
