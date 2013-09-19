#!/usr/bin/perl

use strict;
use warnings;

use lib "../client/";
use Test::More tests => 394;
#use CommunitiesAPIClient;
use rpc_client;
use Data::Dumper;

=pod

=head1 Testing Plan

=head2 Three initial tests

=over

=item Create new object

=back

=cut

my $HOST='http://kbase.us/services/communities';
#   $HOST='http://dunkirk.mcs.anl.gov/~wilke/MG-RAST/site/CGI/api2.cgi/';
	$HOST='http://api.metagenomics.anl.gov/api2.cgi';
#
#  Test 1 - Can a new object be created?
#

#my $object = CommunitiesAPIClient->new(); # create a new object
#my $object = rpc_client->new(); # create a new object with the URL
my $object = rpc_client->new({"url"=>$HOST}); # create a new object with the URL
ok( defined $object, "Did an object get defined for Communities" );               
#
#  Test 2 - Is the object in the right class?
#
#isa_ok( $object, 'CommunitiesAPIClient', "Is it in the right class (Communities)" );   
isa_ok( $object, 'rpc_client', "Is it in the right class (rpc_client)" );   

#$object = CommunitiesAPIClient->new($HOST); # create a new object with the URL

#
#  Test 3 - Are the methods valid?
#

can_ok($object, qw[get_abundanceprofile_instance get_library_query get_library_instance get_metagenome_query get_metagenome_instance get_project_query  get_project_instance get_sample_query get_sample_instance get_sequences_md5 get_sequences_annotation get_sequenceset_instance get_sequenceset_setlist]);

my $return;
my %test_value;
my $test_value;
my @attributes;
my %attributes;
my $test_name;

my %do = (
	'get_abundanceprofile_instance' => 'Y',
	'get_library_query' => 'Y',
	'get_library_instance' => 'Y',
	'get_metagenome_query' => 'Y',
	'get_metagenome_instance' => 'Y',
	'get_project_query' => 'Y',
	'get_project_instance' => 'Y',
	'get_sample_query' => 'Y',
	'get_sample_instance' => 'Y',
	'get_sequences_md5' => 'Y',
	'get_sequences_annotation' => 'Y',
	'get_sequenceset_instance' => 'N',
	'get_sequenceset_setlist' => 'N',
	'version' => 'N' );


#----------------------------------------------------------------------------
#
#  METHOD get_abundanceprofile_instance
#
if ($do{'get_abundanceprofile_instance'} eq 'Y')
{
$test_name = "get_abundanceprofile_instance";
note("TEST $test_name");
%attributes = (
		'generated_by'=>'S',
		'matrix_type'=>'S',
		'date'=>'S',
		'data'=>'L',
		'rows'=>'L',
		'matrix_element_type'=>'S',
		'format_url'=>'S',
		'format'=>'S',
		'columns'=>'L',
		'id'=>'S',
		'type'=>'S',
		'shape'=>'L'
		);
undef %test_value;
undef $return;

eval { $return = $object->get_abundanceprofile_instance() };
ok(exists $return->{'error'}->{'data'}, "Call with no parameters fails properly");

undef $return;
$test_value{'verbosity'} = 'full';
$test_value{'id'} = 'mgm4440026.3';
$test_value{'type'} = 'organism';
$test_value{'source'} = 'M5NR';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with M5NR?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');
&test_result($return,\%attributes,\%test_value) ;

$test_value{'verbosity'} = 'minimal';
$test_value{'type'} = 'feature';
$test_value{'source'} = 'SwissProt';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with SwissProt"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'verbosity'} = 'verbose';
$test_value{'source'} = 'GenBank';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with GenBank?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'IMG';
$test_value{'type'} = 'organism';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with IMG?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'SEED';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with SEED?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'TrEMBL';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with TrEMBL?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'RefSeq';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with RefSeq?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'PATRIC';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with PATRIC?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'eggNOG';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with eggNOG?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'KEGG';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with KEGG?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'NOG';
$test_value{'type'} = 'function';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with NOG?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'COG';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with COG?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'KO';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with KO?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'GO';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with GO?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'Subsystems';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with Subsystems?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'M5RNA';
$test_value{'type'} = 'organism';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with M5RNA?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'RDP';
$test_value{'type'} = 'feature';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with RDP?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'Greengenes';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with Greengenes?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'LSU';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with LSU?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{'source'} = 'SSU';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with SSU?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

}



#----------------------------------------------------------------------------
#
#  METHOD get_library_query
#
if ($do{'get_library_query'} eq 'Y')
{
$test_name = "get_library_query";
note("TEST $test_name");
%attributes = (
		'version'=>'S',
		'project'=>'S',
		'name'=>'S',
		'sequencesets'=>'L',
		'metagenome'=>'S',
		'created'=>'S',
		'url'=>'S',
		'id'=>'S',
		'sample'=>'S',
		'metadata'=>'M'
		);
undef %test_value ;
undef $return;

$test_value{"verbosity"} = 'minimal';
$test_value{"limit"} = 1;
$test_value{"offset"} = 56;

eval { $return = $object->get_library_query()  };
isnt($@, '', "$test_name Call with no parameter fails properly ");

$test_value{"order"}='created'; 
eval { $return = $object->get_library_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');
&test_result($return,\%attributes,\%test_value) ;

$test_value{"order"}='id';
eval { $return = $object->get_library_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"order"}='name';
eval { $return = $object->get_library_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"order"}='version';
eval { $return = $object->get_library_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

}

#----------------------------------------------------------------------------
#
#  METHOD get_library_instance
#
if ($do{'get_library_instance'} eq 'Y')
{
$test_name = "get_library_instance";
note("TEST $test_name");
%attributes = (
		'version'=>'S',
		'project'=>'S',
		'name'=>'S',
		'sequencesets'=>'L',
		'metagenome'=>'S',
		'created'=>'S',
		'url'=>'S',
		'id'=>'S',
		'sample'=>'S',
		'metadata'=>'M'
		);
undef %test_value ;
undef $return;

eval { $return = $object->get_library_instance()  };
isnt($@,'', "Call with no parameters failed properly");

$test_value{"verbosity"}='full'; 
$test_value{"id"}='mgl5589'; 
eval { $return = $object->get_library_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');
&test_result($return,\%attributes,\%test_value) ;

$test_value{"verbosity"}='minimal'; 
eval { $return = $object->get_library_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"verbosity"}='verbose'; 
eval { $return = $object->get_library_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

}

#----------------------------------------------------------------------------
#
#  METHOD get_metagenome_query
#
if ($do{'get_metagenome_query'} eq 'Y')
{
$test_name = "get_metagenome_query";
note("TEST $test_name");
%attributes = (
		'file_size'=>'S',
		'version'=>'S',
		'name'=>'S',
		'library'=>'S',
		'sequence_type'=>'S',
		'created'=>'S',
		'url'=>'S',
		'primary_project'=>'S',
		'id'=>'S',
		'sample'=>'S',
		'metadata'=>'M'
		);
undef %test_value;
undef $return;

eval { $return = $object->get_metagenome_query()  };
isnt($@, undef, "$test_name Call with no parameters failed properly $@");

$test_value{"verbosity"}='minimal'; 
$test_value{"limit"} = 1;
$test_value{"offset"} = 56;
$test_value{"order"}='created'; 
eval { $return = $object->get_metagenome_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

&test_result($return,\%attributes,\%test_value) ;

$test_value{"order"}='id'; 
eval { $return = $object->get_metagenome_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"order"}='name'; 
eval { $return = $object->get_metagenome_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"order"}='sequence_type'; 
eval { $return = $object->get_metagenome_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"order"}='file_size'; 
eval { $return = $object->get_metagenome_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"order"}='version'; 
eval { $return = $object->get_metagenome_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

}

#----------------------------------------------------------------------------
#
#  METHOD get_metagenome_instance
#
if ($do{'get_metagenome_instance'} eq 'Y')
{
$test_name = "get_metagenome_instance";
note("TEST $test_name");
%attributes = (
		'file_size'=>'S',
		'version'=>'S',
		'name'=>'S',
		'library'=>'S',
		'sequence_type'=>'S',
		'created'=>'S',
		'url'=>'S',
		'primary_project'=>'S',
		'id'=>'S',
		'sample'=>'S',
		'metadata'=>'M'
		);
undef %test_value;
undef $return;

eval { $return = $object->get_metagenome_instance()  };
isnt($@, undef, "$test_name Call with no parameters failed properly $@");

$test_value{"verbosity"}='full'; 
$test_value{id} = 'mgm4440026.3';
eval { $return = $object->get_metagenome_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

&test_result($return,\%attributes,\%test_value) ;

$test_value{"verbosity"}='verbose'; 
eval { $return = $object->get_metagenome_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"verbosity"}='minimal'; 
eval { $return = $object->get_metagenome_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

}

#----------------------------------------------------------------------------
#
#  METHOD get_project_query
#
if ($do{'get_project_query'} eq 'Y')
{
$test_name = "get_project_query";
note("TEST $test_name");
%attributes = (
		'analyzed'=>'L',
		'version'=>'S',
		'name'=>'S',
		'description'=>'S',
		'libraries'=>'L',
		'created'=>'S',
		'samples'=>'L',
		'funding_source'=>'S',
		'url'=>'S',
		'id'=>'S',
		'pi'=>'S',
		'metadata'=>'M'
		);
undef %test_value;
undef $return;

eval { $return = $object->get_project_query()  };
ok(exists $return->{'error'}->{'data'}, "Call with no parameters fails properly");

undef $return;
$test_value{"limit"} = 1;
$test_value{"offset"} = 56;
$test_value{"order"}='created'; 
eval { $return = $object->get_project_query(\%test_value)  };
isnt($return, undef, "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH with created");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');
&test_result($return,\%attributes,\%test_value) if (exists $return->{'result'}) ;

$test_value{"order"}='id'; 
eval { $return = $object->get_project_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH with id");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');
&test_result($return,\%attributes,\%test_value) ;

$test_value{"order"}='name'; 
eval { $return = $object->get_project_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH with name");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"order"}='funding_source'; 
eval { $return = $object->get_project_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH with funding_source");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"order"}='pi'; 
eval { $return = $object->get_project_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH with pi");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"order"}='version'; 
eval { $return = $object->get_project_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH with version");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

}

#----------------------------------------------------------------------------
#
#  METHOD get_project_instance
#
if ($do{'get_project_instance'} eq 'Y')
{
$test_name = "get_project_instance";
note("TEST $test_name");
%attributes = (
		'analyzed'=>'L',
		'version'=>'S',
		'name'=>'S',
		'description'=>'S',
		'libraries'=>'L',
		'created'=>'S',
		'samples'=>'L',
		'funding_source'=>'S',
		'url'=>'S',
		'id'=>'S',
		'pi'=>'S',
		'metadata'=>'M'
		);
undef %test_value ;
undef $return;

$test_value{"verbosity"}='full'; 
$test_value{"id"}='mgp60'; 
eval { $return = $object->get_project_instance()  };
ok(exists $return->{'error'}->{'data'}, "Call with no parameters fails properly");

undef $return;
eval { $return = $object->get_project_instance(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref($return), "HASH", "Call with valid parameters returns a hash");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

&test_result($return,\%attributes,\%test_value) ;

}

#----------------------------------------------------------------------------
#
#  METHOD get_sample_query
#
if ($do{'get_sample_query'} eq 'Y')
{
$test_name = "get_sample_query";
note"TEST $test_name";
%attributes = (
		'version'=>'S',
		'project'=>'S',
		'name'=>'S',
		'metagenomes'=>'L',
		'libraries'=>'L',
		'created'=>'S',
		'env_package'=>'M',
		'url'=>'S',
		'id'=>'S',
		'metadata'=>'M'
		);
undef %test_value;
undef $return;

eval { $return = $object->get_sample_query()  };
ok(exists $return->{'error'}->{'data'}, "Call with no parameters fails properly");

undef $return;
$test_value{"limit"} = 1;
$test_value{"offset"} = 56;
$test_value{"order"}='created'; 
eval { $return = $object->get_sample_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH with created");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

&test_result($return,\%attributes,\%test_value) ;

$test_value{"order"}='id'; 
eval { $return = $object->get_sample_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH with id");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"order"}='name'; 
eval { $return = $object->get_sample_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH with name");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"order"}='version'; 
eval { $return = $object->get_sample_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH with version");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

}

#----------------------------------------------------------------------------
#
#  METHOD get_sample_instance
#
if ($do{'get_sample_instance'} eq 'Y')
{
$test_name = "get_sample_instance";
note("TEST $test_name");
%attributes = (
		'version'=>'S',
		'project'=>'S',
		'name'=>'S',
		'metagenomes'=>'L',
		'libraries'=>'L',
		'created'=>'S',
		'env_package'=>'M',
		'url'=>'S',
		'id'=>'S',
		'metadata'=>'M'
		);
undef %test_value;
undef $return;

eval { $return = $object->get_sample_instance()  };
ok(exists $return->{'error'}->{'data'}, "Call with no parameters fails properly");

undef $return;
$test_value{"verbosity"}='full'; 
$test_value{"id"}='mgs73470'; 
eval { $return = $object->get_sample_instance(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

&test_result($return,\%attributes,\%test_value) ;

$test_value{"verbosity"}='verbose'; 
$test_value{"id"}='mgs73470'; 
eval { $return = $object->get_sample_instance(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH with verbose");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

$test_value{"verbosity"}='minimal'; 
$test_value{"id"}='mgs73470'; 
eval { $return = $object->get_sample_instance(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a HASH with minimal");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

}

#----------------------------------------------------------------------------
#
#  METHOD get_sequences_md5
#
if ($do{'get_sequences_md5'} eq 'Y')
{
$test_name = "get_sequences_md5";
note("TEST $test_name");
%attributes = (
		'version'=>'S',
		'url'=>'S',
		'id'=>'S',
		);
undef %test_value ;
undef $return;

eval { $return = $object->get_sequences_md5()  };
ok(exists $return->{'error'}->{'data'}, "Call with no parameters fails properly");

undef $return;
$test_value{id} = 'mgm4440026.3';
$test_value{"sequence_type"} = 'dna';
$test_value{"source"} = 'Greengenes';
#$test_value{"md5"} = ['960128629b9182b2a2dc54f26c94b692','3a50a86ac9665da473b0a6f3525ee2bd'];
eval { $return = $object->get_sequences_md5(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a hash");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

&test_result($return,\%attributes,\%test_value) ;

$test_value{"sequence_type"} = 'protein';
eval { $return = $object->get_sequences_md5(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a hash");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

}

#----------------------------------------------------------------------------
#
#  METHOD get_sequences_annotation
#
if ($do{'get_sequences_annotation'} eq 'Y')
{
$test_name = "get_sequences_annotation";
note("TEST $test_name");
%attributes = (
		'version'=>'S',
		'url'=>'S',
		'id'=>'S',
		);
undef %test_value ;
undef $return;

eval { $return = $object->get_sequences_annotation()  };
ok(exists $return->{'error'}->{'data'}, "Call with no parameters fails properly");

undef $return;
$test_value{"verbosity"}='minimal'; 
$test_value{id} = 'mgm4440026.3';
$test_value{"source"} = 'Greengenes';
eval { $return = $object->get_sequences_annotation(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?"); 
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

}

#----------------------------------------------------------------------------
#
#  METHOD get_sequenceset_instance
#
if ($do{'get_sequenceset_instance'} eq 'Y')
{
$test_name = " get_sequenceset_instance";
note("TEST $test_name");
%attributes = (
		'stage_name'=>'S',
		'file_name'=>'S',
		'url'=>'S',
		'id'=>'S',
		'stage_type'=>'S',
		'stage_id'=>'S',
		'id'=>'S',
		'id'=>'S',
		'id'=>'S',
		'id'=>'S',
		);
undef %test_value ;
undef $return;

eval { $return = $object->get_sequenceset_instance()  };
ok(exists $return->{'error'}->{'data'}, "Call with no parameters fails properly");

undef $return;
$test_value{id} = 'mgm4440026.3';
eval { $return = $object->get_sequenceset_instance(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a hash");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');
&test_result($return,\%attributes,\%test_value) ;

}

#----------------------------------------------------------------------------
#
#  METHOD get_sequenceset_setlist
#	WARNING: RETURN is a gzip file and not a HASH

if ($do{'get_sequenceset_setlist'} eq 'Y')
{
$test_name = "get_sequenceset_setlist";
note("TEST $test_name");

undef %test_value ;
undef $return;

eval { $return = $object->version()  };
ok(exists $return->{'error'}->{'data'}, "Call with no parameters fails properly");

undef $return;
$test_value{id} = 'mgm4440037.3-100-1"';
eval { $return = $object->version(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
&test_error($return,\%test_value) if (ref($return) eq 'HASH');

}

#----------------------------------------------------------------------------
#
#  Test the returned results
#	1.	Test for an error
#	2.	Test that the returned attribute is expected
#	3.	Test that the returned attribute is the right type
#	4.	If verbosity is 'full' make sure that all of them returned
#

sub test_result
{
	my ($return,$attribute,$test) = @_;

	return unless (ref($return) eq 'HASH' && exists $return->{'result'} && ref($return->{'result'}) eq 'ARRAY');

	my $result = pop($return->{'result'});
	my $data;

	if (ref($result) eq 'HASH' && exists $result->{'data'} && ref($result->{'data'}) eq 'ARRAY')
	{
		if (exists $result->{'rows'} )
		{	#print "Abundance Profile\n";
			$data->[0] = $result;
		}
		else
		{	#print "Most Query requests\n";
			$data = $result->{'data'};
		}
	}
	elsif (ref($result) eq 'HASH' && exists $result->{'data'} )
	{	#print "Sequences MD5 and Annotation\n";
		$data->[0] = $result->{'data'};
	}
	elsif (ref($result) eq 'HASH')
	{	#print "Most Instance requests\n";
		$data->[0] = $result;
	}
	elsif (ref($result) eq 'ARRAY' && ref($result->[0]) eq 'HASH' && exists $result->[0]->{'data'})
	{	#print "Project Query\n";
		$data = $result->[0]->{'data'};
		$result = $result->[0];
	}
	elsif (ref($result) eq 'ARRAY' && ref($result->[0])  eq 'HASH' )
	{	#print "Project Instance\n";
		$data = $result;
	}
#	print Dumper($data);
#	return;


	my %attributes = %$attribute;
	my %test_value = %$test;
	my %found_att;
	my $count = 0;

	if (ref($data) eq 'ARRAY')
	{
		foreach my $key3 (@$data)
		{
			if (ref($key3) eq 'HASH')
			{
				foreach my $key4 (keys(%$key3))
				{
#					print "\t\t\tKEY=$key4 VALUE=$key3->{$key4} \n";
					ok(exists $attributes{$key4}, "Is Attribute $key4 valid?");
					if (exists $attributes{$key4} && $attributes{$key4} eq 'M')
					{
						is (ref($key3->{$key4}),'HASH', "Is Attribute $key4 a hash?");
					}
					elsif (exists $attributes{$key4} && $attributes{$key4} eq 'L' )
					{
						is (ref($key3->{$key4}),'ARRAY', "Is Attribute $key4 an array?");
					}
					else
					{
						is (ref($key3->{$key4}),'', "Is Attribute $key4 a scalar?");
					}
					$found_att{$key4} = 'Y';
				}
			}
			$count++;
		}
	}

	if (exists $test_value{'verbosity'} && $test_value{'verbosity'} eq 'full')
	{
		note"Verbosity=FULL, Were all Attributes returned?";
		foreach my $key(keys(%attributes))
		{
			ok(exists $found_att{$key}, "Was attribute $key found?");
		}
	}

	return if (ref($result) eq 'ARRAY');

	is ($result->{'limit'},$test_value{"limit"}, "Is the returned limit the same as the requested limit?") if (exists $test_value{"limit"} && exists ($result->{'limit'}) );
	is ($count, $test_value{"limit"}, "Is the returned number of records the same as the requested limit?") if (exists $test_value{"limit"});
	is ($result->{'offset'},$test_value{"offset"}, "Is the returned offset the same as the requested offset?") if (exists $test_value{"offset"} && exists ($result->{'offset'}) );
	is ($result->{'order'},$test_value{"order"}, "Is the returned order the same as the requested order?") if (exists $test_value{"order"} && exists ($result->{'offset'}) );
}

sub test_error
{
	my ($return,$test) = @_;
	my %test_value = %$test;

	if (exists $return->{'error'})
	{
		print "\tRETURN ERROR\n";
		my $error = {};
		if (ref $return->{'error'}->{'data'} eq 'ARRAY')
		{
			$error = pop($return->{'error'}->{'data'});
		}
		else
		{
			$error =  $return->{'error'}->{'data'};
		}
		foreach my $key (keys(%$error))
		{
#			print "\t$return->{'error'}->{'data'}->{$key} \n";
			print "\t$error->{$key} \n";
		}
 		print "\tRETURN PARAMETERS: ";
		foreach my $key (keys(%test_value))
		{
			print "$key=$test_value{$key}  ";
		}
		print "\n";
		print "\tCODE=".$return->{'error'}->{'code'}."\n";
		print "\tMESSAGE=".$return->{'error'}->{'message'}."\n";
#		print Dumper($return);  
		ok( ! exists ($return->{'error'}->{'data'}),"Is the HASH free of errors");
		return;
	}
	else
	{
		ok( ! exists ($return->{'error'}->{'data'}),"Is the HASH free of errors");
	}

}



