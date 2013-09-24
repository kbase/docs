#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

# point to where the ERDB documentation package lives, should be in kb_seed repo
# note: requires that HTML::Template is installed
# note: requires GD library installed (http://www.boutell.com/gd/http/gd-2.0.34.tar.gz) and cpan GD
# see http://toddharris.net/blog/2005/01/14/building-gdpm-and-libgd/
use lib "/Users/msneddon/Desktop/work/kbase_git/kb_seed/lib/";
use ERDB;
use ERDBPDocPage;


my $dbh = "Trees";
my $metaFileName = "/Users/msneddon/Desktop/trees/git_repo/spec/ERDB_Model/trees_er.xml";
my %db_options = (name => 'Trees');
my $database = ERDB->new($dbh, $metaFileName, %db_options);


#my %options = ( name => 'Trees', idString => 'TR' );
#my $html = ERDBPDocPage->new(%options);