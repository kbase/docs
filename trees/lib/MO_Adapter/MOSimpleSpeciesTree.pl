#!/usr/bin/perl

# This is a poorly commented hack to get a species tree into kbase with nodes labeled with
# kbase genome ids.  In the (hopefully) not too distant future, species trees will be built
# directly from kbase genomes and loaded directly to the CDS.

use lib "../KBTree_cpp_lib/lib/perl_interface";
use KBTreeUtil;
use DBI;


# CODE TO GO TO MO AND GRAB TREE
#my $dbh = DBI->connect('dbi:mysql:genomics:pub.microbesonline.org','guest','guest') or die "Connection Error: $DBI::errstr\n";
#my $sql = "select newick from Tree where name=\"MOSpeciesTree\"";
#my $sth = $dbh->prepare($sql);
#$sth->execute or die "SQL Error: $DBI::errstr\n";
#my $speciesTreeString = "";
#f (@row = $sth->fetchrow_array) { $speciesTreeString = $row[0]; } 

#CODE TO USE KEITH'S FILE
open(INTREE, "</Users/msneddon/Desktop/stree-map/speciesTree.pub.nonames");
my $speciesTreeString = ""; 
while(<INTREE>) {
    my($line) = $_;
    chomp($line);
    if($line) {
        $speciesTreeString=$line;
    }
}
close(INTREE);

#FROM A MAPPING FILE, GET THE KB ID TO TAXONOMY ID MAPPINGS
my %taxId_2_kbId_map = ();
my $replacementList="";
open(IN, "</Users/msneddon/Desktop/stree-map/kbGenomeTaxIdMap.edit");
while(<IN>)
{
    my($line) = $_; chomp($line);
    my @tokens = split("\t",$line);
    my $kb_genome_id = $tokens[0];
    my @id_components = split("\\.",$tokens[1]);
    my $tax_id = $id_components[0];  # NOTE: WHEN WE GET THE TAX ID, WE DROP THE VERSION NUMBER
    my $scientific_name = $tokens[2];
    #print "$line\n";
    #print "$kb_genome_id\n";
    #print "$tax_id\n";
    #print "$scientific_name\n";
    
    if (exists $taxId_2_kbId_map{$tax_id}) {
        #print "not adding duplicate taxonomy id: $tax_id\n";
    }
    else {
        $taxId_2_kbId_map{$tax_id} = $kb_genome_id;
        #print "adding: ".$tax_id.";".$kb_genome_id.";\n";
        $replacementList = $replacementList.$tax_id.";".$kb_genome_id.";";
    }
}
close(IN);
#print "\n".$replacementList."\n";


# REPLACE THE TAXONOMY IDS WITH KBASE GENOME IDS
my $speciesTree = new KBTreeUtil::KBTree($speciesTreeString,0,1);
$speciesTree->replaceNodeNames($replacementList);
#print $speciesTree->getNodeCount()."\n";
#print $speciesTree->getLeafCount()."\n";

# list of leaf nodes that did not get assigned (save this to a file if we want)
#open (LIST_OUT, '>/Users/msneddon/Desktop/leaf_list.txt');
my @leaf_names = split(";",$speciesTree->getAllLeafNames());
my $leafNodesToRemove = "";
my $counter = 0;
foreach (@leaf_names) {
    my $label=$_;
    #print LIST_OUT $label."\n";
    if(!($label =~ m/kb/)) {
        #print $label."\n";
        $leafNodesToRemove = $leafNodesToRemove.$label.";";
        $counter=$counter+1;
    }
}
#close (LIST_OUT); 
#print $leafNodesToRemove."\n";
#print $counter."\n";

# REMOVE THE LABELS THAT WE COULD NOT MAP
#print $speciesTree->getLeafCount()."\n";
$speciesTree->removeNodesByNameAndSimplify($leafNodesToRemove);
#print $speciesTree->getLeafCount()."\n";

# WRITE THE TREE TO FILE
my $kb_id = "kb|tree.986920";
open (NEWICK_OUT, ">/Users/msneddon/Desktop/stree-map/mo_species_tree/Raw_Tree_Files/$kb_id.newick");
print NEWICK_OUT $speciesTree->toNewick(1);
close NEWICK_OUT;

# WRITE THE OTHER FILES - CAREFUL- THIS IS HARD CODED (remember that we said this is a hack)
open (TREE_OUT, '>/Users/msneddon/Desktop/stree-map/mo_species_tree/Tree.tab');
print TREE_OUT "$kb_id\t";  # kb_tree_id     M	 unique kbase id reserved for the tree from ID server: 'kb|tree.XXXXX'
print TREE_OUT "\t";  # kb_aln_id      M	 the kbase id of the alignment from which this tree was built
print TREE_OUT "active\t"; # status	 M	 string indicating if the tree is "active", "superseded" or "bad"
print TREE_OUT "genome\t"; # data_type	 M	 lowercase string indicating the type of data this tree is built from; we set this to "sequence_alignment" for all alignment-based trees, but we may support "taxonomy", "gene_content" trees and more in the future
print TREE_OUT time()."\t"; # timestamp	 M	 the time at which this alignment was loaded into KBase. Other timestamps can be added to AlignmentAttribute?; the time format is an integer indicating seconds since epoch
print TREE_OUT "FastTree2\t";  # method	 R	 string that either maps to another object that captures workflows, or is simple alignment method name, e.g. "MOPipeline"
print TREE_OUT "-fastest\t";   # parameters	 R	 free form string that might be a hash to provide additional alignment parameters e.g., the program option values used
print TREE_OUT "MO_Pipeline(species)\t"; # protocol	 O	 human readable description of the alignment, if needed
print TREE_OUT "MOL:Tree\t";              # source_db	 M	 the database where this alignment originated, eg MO, SEED
print TREE_OUT "5962795";    # source_db_aln_id	 M	 the id of this alignment in the original database   
print TREE_OUT "\n";
close TREE_OUT;

open (TREE_ATTRIBUTE_OUT, '>/Users/msneddon/Desktop/stree-map/mo_species_tree/TreeAttribute.tab');
print TREE_ATTRIBUTE_OUT "$kb_id\tseeded_by_src\tMOL\n";
print TREE_ATTRIBUTE_OUT "$kb_id\tseeded_by_id\t5962795\n";
print TREE_ATTRIBUTE_OUT "$kb_id\tstyle\tphylogram\n";
print TREE_ATTRIBUTE_OUT "$kb_id\tbootstrap_type\tShimodaira-Hasegawa Test\n";
close (TREE_ATTRIBUTE_OUT);

# OUTPUT LEAF LABELS FOR DEBUG
#@leaf_names = split(";",$speciesTree->getAllLeafNames());
#foreach (@leaf_names) {
#    my $label=$_;
#    print $label."\n";
#}
