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
#  updated: 11/29/2012  landml

use strict;
use warnings;

use Data::Dumper;
use Test::More;
use lib "lib";
use lib "t/server-tests";
use TreeTestConfig qw(getHost getPort);

#############################################################################
# HERE IS A LIST OF METHODS AND PARAMETERS THAT WE WANT TO TEST
# NOTE THAT THE PARAMETERS ARE JUST MADE UP AT THE MOMENT
my $func_calls = {
                replace_node_names => ["((a,b)c);",{"b"=>"x"}],
                remove_node_names_and_simplify => ["((a,b)c);",["b"]],
                extract_leaf_node_names => ["((a,b)c);"],
                extract_node_names => ["((a,b)c);"],
                get_node_count => ["((a,b)c);"],
                get_leaf_count => ["((a,b)c);"],
                get_tree => ["kb|tree.123", {format=>'newick'}],
                get_tree_ids_by_feature => [ ["kb|g.fake"] ],
                get_tree_ids_by_protein_sequence => [ ["madeUpMD5"] ],
                get_alignment_ids_by_feature => [ ["kb|g.fake"]],
                get_alignment_ids_by_protein_sequence => [ ["madeUpMD5"] ],
                draw_html_tree => ["((a,b)c);",{option=>"value"}],
                get_tree_data => [ ["kb|tree.0","kb|tree.1"] ],
                get_alignment_data => [ ["kb|aln.0","kb|aln.1"] ],
                 };
#############################################################################
my $n_tests = (scalar(keys %$func_calls)+3); # set this to be the number of function calls + 3

# MAKE SURE WE LOCALLY HAVE JSON RPC LIBS
#  NOTE: for initial testing, you may have to modify TreesClient.pm to also
#        point to the legacy interface
use_ok("JSON::RPC::Client");
use_ok("Bio::KBase::Tree::Client");

# MAKE A CONNECTION (DETERMINE THE URL TO USE BASED ON THE CONFIG MODULE)
my $host=getHost(); my $port=getPort();
print "-> attempting to connect to:'".$host.":".$port."'\n";
my $client = Bio::KBase::Tree::Client->new($host.":".$port);

#NEW VERSION WITH AUTO START / STOP SERVICE
#use Server;
#my ($pid, $url) = Server::start('Tree');
#print "-> attempting to connect to:'".$url."' with PID=$pid\n";
#my $client = Bio::KBase::Tree::Client->new($url);

ok(defined($client),"instantiating tree client");




# LOOP THROUGH ALL THE REMOTE CALLS AND MAKE SURE WE GOT SOMETHING
my $method_name;
for $method_name (keys %$func_calls) {
        #print "==========\n$method_name => @{ $func_calls->{$method_name}}\n";
        #my $n_args = scalar @{ $func_calls->{$method_name}};
        my $result;
        print "calling function: \"$method_name\"\n";
        {
            no strict "refs";
            $result = $client->$method_name(@{ $func_calls->{$method_name}});
        }
        ok($result,"looking for a response from \"$method_name\"");
}

#Server::stop($pid);

done_testing($n_tests);
