#!/usr/bin/perl
#  
#  The purpose of this test is to make sure we recieve some response from the server for the list of functions
#  given.  Each of these functions listed should return some value, but the actual value is not checked here.
#  Thus, this test is ideal for making sure you are actually recieving something from a service call even if
#  that service is not yet implemented yet.
#
#  If you add functionality to the Tree service API, you should add an appropriate test here.
#
#  author:  msneddon
#  created: 5/21/2012
#  updated: 11/29/2012 landml

use strict;
use warnings;

use Data::Dumper;
use Test::More tests=>7;
use lib "lib";
use lib "t/test-deploy";
use TreeTestConfig qw(getHost getPort getURL);

#############################################################################
# HERE IS A LIST OF METHODS AND PARAMETERS THAT WE WANT TO TEST
# NOTE THAT THE PARAMETERS ARE JUST MADE UP AT THE MOMENT
my @tree_methods = qw (extract_leaf_node_names extract_node_names get_node_count get_leaf_count );
#############################################################################

# MAKE SURE WE LOCALLY HAVE JSON RPC LIBS
#  NOTE: for initial testing, you may have to modify TreesClient.pm to also
#        point to the legacy interface
use_ok("JSON::RPC::Client");
use_ok("Bio::KBase::Tree::Client");

# MAKE A CONNECTION (DETERMINE THE URL TO USE BASED ON THE CONFIG MODULE)
my $host=getHost(); my $port=getPort();  my $url = getURL();
#print "-> attempting to connect to:'".$host.":".$port."'\n";
#my $client = Bio::KBase::Tree::Client->new($host.":".$port);
print "-> attempting to connect to:'".$url."'\n";
my $client = Bio::KBase::Tree::Client->new($url);

#NEW VERSION WITH AUTO START / STOP SERVICE
#use Server;
#my ($pid, $url) = Server::start('Tree');
#print "-> attempting to connect to:'".$url."' with PID=$pid\n";
#my $client = Bio::KBase::Tree::Client->new($url);

ok(defined($client),"instantiating tree client");

my $tree = "(Bovine:0.69395,(Hylobates:0.36079,(Pongo:0.33636,(G._Gorilla:0.17147, (P._paniscus:0.19268,H._sapiens:0.11927):0.08386):0.06124):0.15057):0.54939, Rodent:1.21460);";

my $result;

$result = $client->get_leaf_count($tree);
is($result,7,'Verify the leaf count');

$result = $client->get_node_count($tree);
is($result,12,'Verify the node count');

my $replace = {'Rodent' => 'Rat'};
$result = $client->replace_node_names($tree,$replace);
$tree = "(Bovine:0.69395,(Hylobates:0.36079,(Pongo:0.33636,(G._Gorilla:0.17147,(P._paniscus:0.19268,H._sapiens:0.11927):0.08386):0.06124):0.15057):0.54939,Rat:1.2146);";

is($result,$tree,"Did replacement take place");

my $remove = ['Rat'];
$result = $client->remove_node_names_and_simplify($tree,$remove);
$tree = "(Bovine:0.69395,(Hylobates:0.36079,(Pongo:0.33636,(G._Gorilla:0.17147,(P._paniscus:0.19268,H._sapiens:0.11927):0.08386):0.06124):0.15057):0.54939);";
is($result,$tree,"Did removal take place");


#Server::stop($pid);

done_testing();
