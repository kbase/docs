use strict;
use PhispyClient;
use Getopt::Long;
use JSON::XS;
use Data::Dumper;

my $url;
my $port;

my $usage = "Usage: find_prophages [--port port] [--url url] training-set-id < genome > genome.with.prophages \n";

my $rc = GetOptions("port=s" => \$port,
		    "url=s"  => \$url,
		    );
if (!$rc || @ARGV != 1)
{
    die $usage;
}

my $training_set_id = shift;

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

my $json = JSON::XS->new;

my $input_genome;
{
    local $/;
    undef $/;
    my $input_genome_txt = <STDIN>;
    $input_genome = $json->decode($input_genome_txt);
}

my($output_genome, $analysis) = $client->find_prophages($training_set_id, $input_genome);
print Dumper($output_genome, $analysis);
