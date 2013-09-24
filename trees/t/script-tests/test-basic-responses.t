#!/usr/bin/perl
# This script tests the Tree scripts by calling each one
#
#  author:  msneddon
#  created: jan 2013
use strict;
use warnings;

use Test::More;
use Data::Dumper;

use lib "lib";
use lib "t/script-tests";

#my $url = "http://localhost:7047";
use Server;
my ($pid, $test_url) = Server::start('Tree');
print "-> attempting to use :'".$test_url."' with PID=$pid\n";

# declare some variables we use over and over 
my ($out,$exit_code);

#######################################################
# [tree-url] script tests
$out = `tree-url`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-url with no parameters returns exit code 0');
ok($out,'tree-url with no parameters returns a url');
my $original_url = $out;

$out = `tree-url --help`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-url with long help flag returns exit code 0');
ok($out,'tree-url with long help flag returns some text');

$out = `tree-url $test_url`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-url with update URL returns exit code 0');
ok($out=~m/$test_url/g,'tree-url with update URL includes expected return string');

#######################################################
# [tree-get-tree] script tests
$out = `tree-get-tree -h`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-get-tree with help returns error exit code 0');
ok($out,'tree-get-tree with help returns a message');

$out = `tree-get-tree madeUpID`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-get-tree with bogus treeId still exits with error code 0');
ok($out eq '','tree-get-tree with bogus treeId returns nothing');

$out = `tree-get-tree 'kb|tree.0'`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-get-tree with real treeId  exits with error code 0');
ok($out,'tree-get-tree with real treeId returns something');

$out = `tree-get-tree -m 'kb|tree.0'`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-get-tree with real treeId and -m flag exits with error code 0');
ok($out=~m/\[leaf_count\]/g,'tree-get-tree with real treeId and -m flag returns with string indicating meta data was returned');


#######################################################
# [tree-get-leaf-nodes] script tests
$out = `echo '' | tree-get-leaf-nodes`;
$exit_code = ($? >> 8);
ok($exit_code!=0,'tree-get-leaf-nodes with no parameters returns error exit code that is not 0');
ok($out,'tree-get-tree with no parameters returns a message');

$out = `tree-get-leaf-nodes '(a,b,c,d,e,f,g)root;'`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-get-leaf-nodes with a tree returned with error code 0');
ok($out eq "a\nb\nc\nd\ne\nf\ng\n",'tree-get-leaf-nodes with a tree returns proper output');


#######################################################
# [tree-find-tree-ids] script tests
$out = `tree-find-tree-ids --help`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-find-tree-ids with long help flag returns exit code 0');
ok($out,'tree-find-tree-ids with long help flag returns some text');


#######################################################
# [tree-find-alignment-ids] script tests
$out = `tree-find-alignment-ids --help`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-find-alignment-ids with long help flag returns exit code 0');
ok($out,'tree-find-alignment-ids with long help flag returns some text');


#######################################################
# [tree-relabel-node-names] script tests
$out = `tree-relabel-node-names --help`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-relabel-node-names with long help flag returns exit code 0');
ok($out,'tree-relabel-node-names with long help flag returns some text');


#######################################################
# [tree-compute-abundance-profile] script tests
$out = `tree-compute-abundance-profile --help`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-compute-abundance-profile with long help flag returns exit code 0');
ok($out,'tree-compute-abundance-profile with long help flag returns some text');


#######################################################
# [tree-filter-abundance-profile] script tests
$out = `tree-filter-abundance-profile-column --help`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-filter-abundance-profile-column with long help flag returns exit code 0');
ok($out,'tree-filter-abundance-profile with long help flag returns some text');


#######################################################
# [tree-normalize-abundance-profile] script tests
$out = `tree-normalize-abundance-profile --help`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-normalize-abundance-profile with long help flag returns exit code 0');
ok($out,'tree-normalize-abundance-profile with long help flag returns some text');



#######################################################
# [tree-remove-nodes] script tests
$out = `tree-remove-nodes --help`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-remove-nodes with long help flag returns exit code 0');
ok($out,'tree-remove-nodes with long help flag returns some text');


#######################################################
# [tree-html-add-boxes] script tests
$out = `tree-html-add-boxes --help`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-html-add-boxes with long help flag returns exit code 0');
ok($out,'tree-html-add-boxes with long help flag returns some text');


#######################################################
# [tree-html-relabel-leaves] script tests
$out = `tree-html-relabel-leaves --help`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-html-relabel-leaves with long help flag returns exit code 0');
ok($out,'tree-html-relabel-leaves with long help flag returns some text');


#######################################################
# be nice and reset the url
$out = `tree-url $original_url`;
$exit_code = ($? >> 8);
ok($exit_code==0,'tree-url trying to reset to original returns exit code 0');
ok($out,'tree-url trying to reset to original returns a url');
#print $out."\n";
#print $exit_code."\n";







Server::stop($pid);
done_testing();
