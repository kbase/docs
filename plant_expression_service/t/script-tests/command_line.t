#!/usr/bin/perl
#This is a command line testing script, wrote by Fei He 1/19/2013

use strict;
use warnings;
use lib "lib";
use lib "t/script-tests";

use Test::More tests => 33;
use Test::Cmd;
use String::Random qw(random_regex random_string);
use JSON;

# 
#  Test - Use the auto start/stop service
#
 use Server;
note("Create new service");
my ($pid, $host) = Server::start('PlantExpressionService');
note("Test use:'".$host."' with PID=$pid");

my $bin  = "scripts";


my $getallpo=Test::Cmd->new(prog => "$bin/get_all_po.pl", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($getallpo, "creating Test::Cmd object for get_all_po.pl");
$getallpo->run(args => "--url=$host");
ok($? == 0, "Running get_all_po");
my @tem=$getallpo->stdout;
my $num=@tem;
ok($num>5, "Number of PO term:\t$num\n");


my $getalleo=Test::Cmd->new(prog => "$bin/get_all_eo.pl", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($getalleo, "creating Test::Cmd object for get_all_eo.pl");
$getalleo->run(args => "--url=$host");
ok($? == 0, "Running get_all_eo");
 @tem=$getalleo->stdout;
 $num=@tem;
ok($num>5,"Number of EO term:\t$num\n");


my $eoid="EO:0007049";

my $geteodes=Test::Cmd->new(prog => "$bin/get_eo_descriptions.pl", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($geteodes, "creating Test::Cmd object for get_eo_descriptions.pl");
$geteodes->run(args => "--url=$host", stdin => "$eoid");
ok($? == 0, "Running get_eo_descriptions");
ok($geteodes->stdout =~ /soil/, "Sucessfully got EO description");

my $tes=Test::Cmd->new(prog => "$bin/get_eo_sampleidlist.pl", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($tes, "creating Test::Cmd object for get_eo_sampleidlist.pl");
$tes->run(args => "--url=$host", stdin => "$eoid");
ok($? == 0, "Running get_eo_sampleidlist");
$num = @tem=$tes->stdout;
ok($num>5,"NUmber of samples:\t$num\n");

my $poid="PO:0000003";

my $getpodes=Test::Cmd->new(prog => "$bin/get_po_descriptions.pl", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($getpodes, "creating Test::Cmd object for get_po_descriptions.pl");
$getpodes->run(args => "--url=$host", stdin => "$poid");
ok($? == 0, "Running get_po_descriptions");
ok($getpodes->stdout =~ /whole/, "Sucessfully got PO description");

$tes=Test::Cmd->new(prog => "$bin/get_po_sampleidlist.pl", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($tes, "creating Test::Cmd object for get_po_sampleidlist.pl");
$tes->run(args => "--url=$host", stdin => "$poid");
ok($? == 0, "Running get_po_sampleidlist");
$num = @tem=$tes->stdout;
ok($num>5,"Number of samples:\t$num\n");

#my $genelist='kb|g.3899.locus.2366 kb|g.3899.locus.1892 kb|g.3899.locus.2354 kb|g.3899.locus.2549 kb|g.3899.locus.2420 kb|g.3899.locus.2253 kb|g.3899.locus.2229';
my $samplelist="GSM106833,GSM106827,GSM106908";
 $tes=Test::Cmd->new(prog => "$bin/get_experiments_by_sampleid_geneid.pl", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($tes, "creating Test::Cmd object for get_experiments_by_sampleid_geneid.pl");
$tes->run(args => " --url=$host  'kb|g.3899.locus.2366,kb|g.3899.locus.1892,kb|g.3899.locus.2354,kb|g.3899.locus.2549,kb|g.3899.locus.2420,kb|g.3899.locus.2253,kb|g.3899.locus.2229' ", stdin => "$samplelist");
ok($? == 0, "Running get_po_sampleidlist");
@tem=$tes->stdout;
#print join"\n",@tem;
ok(@tem>5, "Got the experiments!");
my $t_col= $tem[1]=~s/,//g;
ok($t_col == 3, "Got three samples.");


$tes=Test::Cmd->new(prog => "$bin/get_experiments_by_sampleid.pl", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($tes, "creating Test::Cmd object for get_experiments_by_sampleid.pl");
$tes->run(args => "--url=$host", stdin => "$samplelist");
@tem=$tes->stdout;
#print "Number of genes in the output:\t$#tem\n";
ok($#tem>10000,"Output $#tem genes");

my $ttm= $tem[1]=~s/,//g;
#print "Number of samples in the output:\t$ttm\n";
ok($ttm == 3 , "Output 3 samples");




$tes=Test::Cmd->new(prog => "$bin/coex_cluster.r", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($tes, "creating Test::Cmd object for coex_cluster.r");
$tes->run(args => "--help");
@tem=$tes->stdout;
ok($#tem>50,"Return with help information");




$tes=Test::Cmd->new(prog => "$bin/coex_cluster2.r", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($tes, "creating Test::Cmd object for coex_cluster2.r");
$tes->run(args => "--help");
@tem=$tes->stdout;
ok($#tem>50,"Return with help information");



$tes=Test::Cmd->new(prog => "$bin/coex_filter.r", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($tes, "creating Test::Cmd object for coex_filter.r");
$tes->run(args => "--help");
@tem=$tes->stdout;
ok($#tem>50,"Return with help information");


$tes=Test::Cmd->new(prog => "$bin/coex_net.r", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($tes, "creating Test::Cmd object for coex_net.r");
$tes->run(args => "--help");
@tem=$tes->stdout;
ok($#tem>50,"Return with help information");

Server::stop($pid);

done_testing();
