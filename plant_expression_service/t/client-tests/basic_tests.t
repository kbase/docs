use strict; 
use warnings; 
# updated 12/6/2012 landml
 
use Test::More tests => 30; 
use Data::Dumper; 
use Test::Cmd;


use lib "lib";
use lib "t/client-tests";
 
use Bio::KBase::PlantExpressionService::Client;
##########
#NEW VERSION WITH AUTO START / STOP SERVICE
use Server;
my ($pid, $url) = Server::start('PlantExpressionService');
print "-> attempting to connect to:'".$url."' with PID=$pid\n";

#
# Test 1 - Can make object
#
my $obj = Bio::KBase::PlantExpressionService::Client->new($url);
ok( defined $obj, "Did an object get defined" ); 

print "OBJECT: ".$obj . "\n";
 
# 
#  Test 2 - Is the object in the right class?
# 
isa_ok( $obj, 'Bio::KBase::PlantExpressionService::Client', "Is it in the right class" ); 

my @methods = qw(get_experiments_by_seriesid get_eo_sampleidlist get_po_sampleidlist get_all_po get_all_eo get_po_descriptions get_eo_descriptions get_experiments_by_sampleid get_experiments_by_sampleid_geneid get_repid_by_sampleid);
can_ok($obj, @methods);


#print "start\n\n";


#
# Test 3,4,5 - get_all_po
#
my $allPOs ;
eval{
	$allPOs = $obj->get_all_po();
};
ok($@ eq '',"get_all_po test");
#print Dumper($allPOs);
ok(ref($allPOs) eq 'HASH','get_all_po returns a hash');
ok(scalar(keys(%{$allPOs})) > 0, 'get_all_po has entries');

# 
# Test 6,7,8 - get_all_eo
#
my $allEOs ; 
eval{ 
        $allEOs = $obj->get_all_eo();
}; 
ok($@ eq '',"get_all_eo test");
#print Dumper($allEOs);
ok(ref($allEOs) eq 'HASH','get_all_eo returns a hash');
ok(scalar(keys(%{$allEOs})) > 0, 'get_all_eo has entries');

#
# Test 9,10,11 - get_eo_sampleidlist
#

#making EO list
my @eo_keys = keys(%{$allEOs});
my @eo_list = @eo_keys[1..3];
my $eo_series_results;
eval{
	$eo_series_results = $obj->get_eo_sampleidlist(\@eo_keys);
};
ok($@ eq '',"getEOSampleId test");
#print Dumper($eo_series_results); 
ok(ref($eo_series_results) eq 'HASH','get_eo_sampleidlist returns a hash');
ok(scalar(keys(%{$eo_series_results})) > 0, 'get_eo_sampleidlist has entries');
my @eo_series_ids;
foreach my $eo_type(@eo_list)
{
	push(@eo_series_ids,@{$eo_series_results->{$eo_type}});
}

# 
# Test 12,13,14 - get_po_sampleidlist
# 
 
#making PO list 
my @po_keys = keys(%{$allPOs});
my @po_list = @po_keys[1..3];
my $po_series_results;
eval{
        $po_series_results = $obj->get_po_sampleidlist(\@po_keys);
};
ok($@ eq '',"getPOSampleId test");
#print Dumper($po_series_results);
ok(ref($po_series_results) eq 'HASH','get_po_sampleidlist returns a hash');
ok(scalar(keys(%{$po_series_results})) > 0, 'get_po_sampleidlist has entries');
my @po_series_ids;
foreach my $po_type(@po_list)
{
        push(@po_series_ids,@{$po_series_results->{$po_type}});
}
#print Dumper(@po_series_ids);


#
# Test 15,16,17   get_experiments_by_sampleid
#
my @test_series_ids = @po_series_ids[0..2];
my $get_exp_by_series_results;
eval{
	$get_exp_by_series_results = $obj->get_experiments_by_sampleid(\@test_series_ids);
};
print Dumper(@test_series_ids);
ok($@ eq '',"getExperimentsBySampleId test");
#print Dumper($get_exp_by_series_results);
ok(ref($get_exp_by_series_results) eq 'HASH','getExperimentBySampleID returns a hash');
ok(scalar(keys(%{$get_exp_by_series_results})) > 0, 'getExperimentBySampleID has entries');



#test added by Fei
my @sample_ids=("GSM133957","GSM133962");
#my @test_series_ids = @po_series_ids[0..2];
my @gene_id=("kb|g.3899.locus.339","kb|g.3899.locus.421");
my $t_results;
eval{
        $t_results = $obj->get_experiments_by_sampleid_geneid(\@sample_ids,\@gene_id);
};


print Dumper(@sample_ids);
ok($@ eq '',"getExperimentsBySampleIdandGeneID test");
ok(ref($t_results) eq 'HASH','getExperimentBySampleIDandGeneID returns a hash');
ok(scalar(keys(%{$t_results})) > 0, 'getExperimentBySampleIDandGeneID has entries');

eval{
	$t_results = $obj->get_repid_by_sampleid(\@sample_ids);
};
ok($@ eq '',"get_repid_by_sampleid test");
ok(ref($t_results) eq 'HASH','get_repid_by_sampleid returns a hash');
ok(scalar(keys(%{$t_results})) > 0, 'get_repid_by_sampleid has entries');







#
# Test 18,19,20 get_po_descriptions
#
my $get_po_descriptions;
eval{
	$get_po_descriptions  = $obj->get_po_descriptions(\@po_list);	
};
ok($@ eq '',"get_po_descriptions test");
#print "ARRAY: ".Dumper(@po_list);
#print "RESULTS: ".Dumper($get_po_descriptions);
ok(ref($get_po_descriptions) eq 'HASH','get_po_descriptions returns a hash');
ok(scalar(keys(%{$get_po_descriptions})) == scalar(@po_list), 'get_po_descriptions has entries');


# 
# Test 21,22,23 get_eo_descriptions
# 
my $get_eo_descriptions;

eval{
        $get_eo_descriptions  = $obj->get_eo_descriptions(\@eo_list);
}; 
ok($@ eq '',"get_eo_descriptions test");
#print "ARRAY: ".Dumper(@eo_list);
#print "RESULTS: ".Dumper($get_eo_descriptions);
ok(ref($get_eo_descriptions) eq 'HASH','get_eo_descriptions returns a hash');
ok(scalar(keys(%{$get_eo_descriptions})) == scalar(@eo_list), 'get_eo_descriptions has entries');



#making PO list

Server::stop($pid);

done_testing();
