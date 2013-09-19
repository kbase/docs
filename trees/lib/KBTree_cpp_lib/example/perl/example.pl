#!/usr/bin/perl


#use FindBin;
#use lib "$FindBin::Bin/../../lib/perl_interface";
use Bio::KBase::Tree::TreeCppUtil;

print "Testing KBTreeUtil Interface\n";

my $TreeString = "((A:1[as],C:1)D:1,[hellp]B[adf]:1)E;";
$t = new Bio::KBase::Tree::TreeCppUtil::KBTree($TreeString);
my $nodeCount = $t->getNodeCount();
print $t->getNodeCount()."\n";
$t->printTree();

print $t->toNewick(4)."\n";

print $t->getAllLeafNames()."\n";

# get all the names of the leaves
my $leaf_names = $t->getAllLeafNames();
my @values = split(';', $leaf_names);
foreach my $val (@values) {
    print "$val\n";
}

$t->removeNodesByNameAndSimplify("D");
$nodeCount = $t->getNodeCount();
print $t->getNodeCount()."\n";
$t->printTree();

print $t->toNewick(4)."\n";


print "\ndone.\n";

