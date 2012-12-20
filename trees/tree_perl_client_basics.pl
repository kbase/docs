#!/usr/bin/perl
# This script illustrates the usage of some of the basic features of the Tree Services API
#
use strict;
use warnings;

use Data::Dumper;

# EX. 1 - use cdmi to get a tree
use Bio::KBase::CDMI::CDMIClient;
my $cdmi = Bio::KBase::CDMI::CDMIClient->new_for_script();
my $tree_data = $cdmi->get_entity_Tree(["kb|tree.41"], ["status", "method", "parameters", "newick"]);
print Dumper($tree_data);

#my $md5H = $cdmi->fids_to_proteins(["kb|g.371.peg.4539"]);
#my $md5H = $cdmi->fids_to_proteins(["kb|g.371.peg.3636"]);
#my $md5H = $cdmi->proteins_to_fids(['cf3c6b5c1f4f24f69866333d4daeb3c8']);
#print Dumper($md5H);

# EX. 2 - use the tree service to get a tree by protein sequence
use Bio::KBase::Tree::Client;
my $TreeService = Bio::KBase::Tree::Client->new("http://localhost:7047");
my $tree_ids = $TreeService->get_tree_ids_by_protein_sequence(['582562ea961a7644b3a8aa8e4f3fafce']);
#my $tree_ids=$TreeService->get_tree_ids_by_protein_sequence(['cf3c6b5c1f4f24f69866333d4daeb3c8']);
print Dumper($tree_ids);

# EX 3 - use the tree service to get a tree by feature id
$tree_ids = $TreeService->get_tree_ids_by_feature(["kb|g.371.peg.4539"]);
#$tree_ids=$TreeService->get_tree_ids_by_feature(["kb|g.2931.peg.3636"]);
print Dumper($tree_ids);

# EX 4 - use the tree service to extract tree data
$tree_data = $TreeService->get_tree_data($tree_ids);
print Dumper($tree_data);

# EX 5 - use the tree service to extract alignment data (about a particular tree that was found)
my $alignment_data = $TreeService->get_alignment_data([$tree_data->{'kb|tree.15024'}->{'alignment_id'}]);
#my $alignment_data = $TreeService->get_alignment_data([$tree_data->{'kb|tree.249'}->{'alignment_id'}]);
print Dumper($alignment_data);


# EX 5 - get a tree structure with node ids replaced with protein sequence ids
my $tree_id = 'kb|tree.15024';
#my $tree_id = 'kb|tree.41';
my $options = {
               newick_label=>"protein_sequence_id",
               newick_bootstrap=>"none",
               newick_distance=>"raw"};
my $tree = $TreeService->get_tree($tree_id, $options);


# EX 6 - get node and leaf counts of a tree structure
my $node_count = $TreeService->get_node_count($tree);
my $leaf_count = $TreeService->get_leaf_count($tree);
print "Node Count: ".$node_count."\n";
print "Leaf Count: ".$leaf_count."\n";

# EX 7 - get all the leaf names
my $leaf_labels = $TreeService->extract_leaf_node_names($tree);

# EX 8 - display the tree structure as an html file
my $display_options = {};
my $tree_in_html = $TreeService->draw_html_tree($tree,$display_options);
open (TREE_HTML_FILE, '>tree.html');
print TREE_HTML_FILE $tree_in_html;
close (TREE_HTML_FILE);

# EX 9 - display a tree structure as an html file with non-standard leaf labels

# get all the leaf labels and use the CDMI to find what features they map to
my $fid_map = $cdmi->proteins_to_fids($leaf_labels);

# multiple features may be mapped to the same sequence, so extract just the first one arbitrarily
my @list_of_first_features = ();
foreach my $leaf ( keys %{$fid_map} ) {
    push @list_of_first_features, %{$fid_map}->{$leaf}[0];
}

# for each feature, let's also use the CDMI to find the set of roles that the feature is assigned
my $fid_to_role_map = $cdmi->fids_to_roles(\@list_of_first_features);

# replace the fid list for a single role
my $md5_to_new_label_map = {};
foreach my $leaf ( keys %{$fid_map} ) {
    my $fid = %{$fid_map}->{$leaf}[0];
    my $role = $fid_to_role_map->{$fid}[0];
    if($role) { $md5_to_new_label_map->{$leaf} = $fid.'---'.$role; }
    else { $md5_to_new_label_map->{$leaf} = $fid.'---NONE_FOUND'; }
}

# relabel the node names in the tree with the new inforation
my $updated_tree = $TreeService->replace_node_names($tree, $md5_to_new_label_map);

# dislay the tree with the updated leaves
my $display_options = {};
my $tree_in_html = $TreeService->draw_html_tree($updated_tree,$display_options);
open (TREE_HTML_FILE, '>updated_tree.html');
print TREE_HTML_FILE $tree_in_html;
close (TREE_HTML_FILE);



print "\n...done.\n";


