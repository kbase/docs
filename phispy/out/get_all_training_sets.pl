use strict;
use PhispyClient;
use Getopt::Long;
use JSON;

my $url;
my $port;

my $usage = "Usage: get_all_training_sets [--port port] [--url url]\n";

my $rc = GetOptions("port=s" => \$port,
		    "url=s"  => \$url,
		    );
if (!$rc || @ARGV != 0)
{
    die $usage;
}

if (!$url)
{
    if ($port)
    {
	$url = "http://localhost:$port/";
    }
    else
    {
	die "No URL or port specified\n";
    }
}
my $client = PhispyClient->new($url);

my $set_list = $client->get_all_training_sets(@ARGV);

for my $set (@$set_list)
{
	print "$set->{training_set_id}\t$set->{genome_name}\n";
}
