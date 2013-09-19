#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

use Bio::KBase::Tree::Client;
use Bio::KBase::Tree::Util qw(getTreeURL);

my $DESCRIPTION =
"
NAME
      tree-url -- update/view url of the tree service endpoint

SYNOPSIS
      tree-url [OPTIONS] [NEW_URL]

DESCRIPTION
      Display or set the URL endpoint for the tree service.  If run with no
      arguments or options, then the current URL is displayed. If run with
      a single argument, the current URL will be switched to the specified
      URL.  If the specified URL is named default, then the URL is reset to
      the default production URL
      
      -h, --help         diplay this help message, ignore all arguments

EXAMPLES
      Display the current URL:
      > tree-url
      http://kbase.us/services/trees
      
      Reset to the default URL:
      > tree-url default
      changed to: http://kbase.us/services/trees
      
      Use a new URL:
      > tree-url http://localhost:8080/trees
      changed to: http://localhost:8080/trees
      
AUTHORS
      Michael Sneddon (mwsneddon\@lbl.gov)
      
";

# first parse options; only one here is help
my $help = '';
my $default = '';
my $opt = GetOptions (
        "help" => \$help,
        );
if($help) {
     print $DESCRIPTION;
     exit 0;
}

#retrieve or update the URL
my $n_args = $#ARGV+1;
if($n_args==0) {
     print getTreeURL()."\n";
     exit 0;
} elsif($n_args==1) {
     my $url = getTreeURL($ARGV[0]);
     print "changed to: $url\n";
     exit 0;
}

print "Invalid number of arguments.  Run with --help for usage.\n";
exit 1;

