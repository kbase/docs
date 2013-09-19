#!/usr/bin/perl
# This script tests the set of functions that retrieve records from kbase.  Because it currently
# connects to the CDM, it is difficult to test results for exact matches because this will change
# as data gets loaded or new trees are built.  So to 
#
# TODO: CHECK THAT OUTPUT IS ACTUALLY CORRECT
#
#  author:  msneddon
#  created: 10/25/2012
#  last updated: 10/28/2012
#  last updated: 11/29/2012  landml

use strict;
use warnings;

use Test::More tests => 3;
use Data::Dumper;

use lib "lib";
use lib "t/test-deploy";
use TreeTestConfig qw(getHost getPort getURL);

# MAKE SURE WE LOCALLY HAVE JSON RPC LIBS INSTALLED
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

my $tree_ids=[];
######### TEST SET 1 ######### 
# TRY TO RETRIEVE TREES BASED ON FEATURE ID
my $listOfFeatureIds = ['kb|g.9988.peg.1744','kb|g.9988.peg.1741'];
$tree_ids=$client->get_tree_ids_by_feature($listOfFeatureIds);
print Dumper($tree_ids);

######### TEST SET 2 ######### 
# TRY TO RETRIEVE TREES BASED ON PROTEIN SEQUENCE ID
my $listOfProtSeqIds = ['b3421022c78785ebfd349762870e9fef','2845879451b5c84036e9284018669922'];
$tree_ids=$client->get_tree_ids_by_protein_sequence($listOfProtSeqIds);
#print Dumper($tree_ids);

######### TEST SET 3 ######### 
# TRY TO RETRIEVE ALIGNMENTS BASED ON FEATURE ID
$listOfFeatureIds = ['kb|g.9988.peg.1744','kb|g.9988.peg.1741'];
$tree_ids=$client->get_alignment_ids_by_feature($listOfFeatureIds);
#print Dumper($tree_ids);

######### TEST SET 4 ######### 
# TRY TO RETRIEVE ALIGNMENTS BASED ON PROTEIN SEQUENCE ID
$listOfProtSeqIds = ['b3421022c78785ebfd349762870e9fef','2845879451b5c84036e9284018669922'];
$tree_ids=$client->get_alignment_ids_by_protein_sequence($listOfProtSeqIds);
#print Dumper($tree_ids);

######### TEST SET 5 ######### 
# TRY TO GET THE ACTUAL TREE FROM A TREE ID
my $tree_id = 'kb|tree.41'; #36363;
my $options = {format=>"newick",
               newick_label=>"none",
               newick_bootstrap=>"none",
               newick_distance=>"none"};
#these options should return just the tree structure without any labels, distances, or bootstrap values.
my $tree=$client->get_tree($tree_id, $options);
#print Dumper($tree);


$tree_id = 'kb|tree.51469'; #36363;
$options = {format=>"newick",
               newick_label=>"protein_sequence_id",
               newick_bootstrap=>"none",
               newick_distance=>"raw"};

$tree=$client->get_tree($tree_id, $options);
#print Dumper($tree);

#Server::stop($pid);
done_testing();
