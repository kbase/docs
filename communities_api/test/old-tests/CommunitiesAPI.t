
use strict;
use warnings;

use lib "../client/";
use Test::More tests => 378;
use CommunitiesAPIClient;
#use rpc_client;
use Data::Dumper;

=pod

=head1 Testing Plan

=head2 Three initial tests

=over

=item Create new object

=back

=cut

my $HOST='http://kbase.us/services/communities';
	$HOST='http://api.metagenomics.anl.gov/api2.cgi';
#
#  Test 1 - Can a new object be created?
#

#my $object = CommunitiesAPIClient->new(); # create a new object
#my $object = rpc_client->new(); # create a new object with the URL
my $object = CommunitiesAPIClient->new($HOST); # create a new object with the URL
#my $object = rpc_client->new({"url"=>$HOST}); # create a new object with the URL
ok( defined $object, "Did an object get defined for Communities" );               
#
#  Test 2 - Is the object in the right class?
#
isa_ok( $object, 'CommunitiesAPIClient', "Is it in the right class (Communities)" );   
#isa_ok( $object, 'rpc_client', "Is it in the right class (rpc_client)" );   

#$object = CommunitiesAPIClient->new($HOST); # create a new object with the URL

#
#  Test 3 - Are the methods valid?
#

can_ok($object, qw[get_abundanceprofile_instance get_library_query get_library_instance get_metagenome_query get_metagenome_instance get_project_query  get_project_instance get_sample_query get_sample_instance get_sequences_md5 get_sequences_annotation ]);

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
my %attributes = (
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
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

undef $return;
$test_value{'verbosity'} = 'full';
$test_value{'id'} = 'mgm4440026.3';
$test_value{'type'} = 'organism';
$test_value{'source'} = 'M5NR';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return an ARRAY?") if ($return); 
&test_result($return,\%attributes,\%test_value) if ($return);

undef $return;
$test_value{'verbosity'} = 'minimal';
$test_value{'type'} = 'feature';
$test_value{'source'} = 'SwissProt';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return an ARRAY?") if ($return); 
#&test_result($return,\%attributes,\%test_value) if ($return);

undef $return;
$test_value{'verbosity'} = 'verbose';
$test_value{'source'} = 'GenBank';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with GenBank?") if ($return); 

undef $return;
$test_value{'source'} = 'IMG';
$test_value{'type'} = 'organism';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with IMG?") if ($return); 

undef $return;
$test_value{'source'} = 'SEED';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with SEED?") if ($return); 

undef $return;
$test_value{'source'} = 'TrEMBL';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with TrEMBL?") if ($return); 

undef $return;
$test_value{'source'} = 'RefSeq';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with RefSeq?") if ($return); 

undef $return;
$test_value{'source'} = 'PATRIC';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with PATRIC?") if ($return); 

undef $return;
$test_value{'source'} = 'eggNOG';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with eggNOG?") if ($return); 

undef $return;
$test_value{'source'} = 'KEGG';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with KEGG?") if ($return); 

undef $return;
$test_value{'source'} = 'NOG';
$test_value{'type'} = 'function';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with NOG?") if ($return); 

undef $return;
$test_value{'source'} = 'COG';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with COG?") if ($return); 

undef $return;
$test_value{'source'} = 'KO';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with KO?") if ($return); 

undef $return;
$test_value{'source'} = 'GO';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with GO?") if ($return); 

undef $return;
$test_value{'source'} = 'Subsystems';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with Subsystems?") if ($return); 

undef $return;
$test_value{'source'} = 'M5RNA';
$test_value{'type'} = 'organism';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with M5RNA?") if ($return); 

undef $return;
$test_value{'source'} = 'RDP';
$test_value{'type'} = 'feature';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with RDP?") if ($return); 

undef $return;
$test_value{'source'} = 'Greengenes';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with Greengenes?") if ($return); 

undef $return;
$test_value{'source'} = 'LSU';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with LSU?") if ($return); 

undef $return;
$test_value{'source'} = 'SSU';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return a ARRAY with SSU?") if ($return); 

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
undef %test_value;
undef $return;

$test_value{"verbosity"} = 'minimal';
$test_value{"limit"} = 1;
$test_value{"offset"} = 56;

eval { $return = $object->get_library_query()  };
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

undef $return;
$test_value{"order"}='created'; 
eval { $return = $object->get_library_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?") if ($return); 
&test_result($return,\%attributes,\%test_value)  if ($return);

undef $return;
$test_value{"order"}='id';
eval { $return = $object->get_library_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?") if ($return); 
&test_result($return,\%attributes,\%test_value)  if ($return);

undef $return;
$test_value{"order"}='name';
eval { $return = $object->get_library_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?") if ($return); 
&test_result($return,\%attributes,\%test_value) if ($return) ;

undef $return;
$test_value{"order"}='version';
eval { $return = $object->get_library_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?") if ($return); 
&test_result($return,\%attributes,\%test_value) if ($return) ;

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
undef %test_value;
undef $return;

eval { $return = $object->get_library_instance()  };
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

$test_value{"verbosity"}='full'; 
$test_value{"id"}='mgl5589'; 
eval { $return = $object->get_library_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return an ARRAY?") if ($return); 
&test_result($return,\%attributes,\%test_value)  if ($return);

undef $return;
$test_value{"verbosity"}='minimal'; 
eval { $return = $object->get_library_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return an ARRAY?") if ($return); 

undef $return;
$test_value{"verbosity"}='verbose'; 
eval { $return = $object->get_library_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return an ARRAY?") if ($return); 

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
undef %test_value ;
undef $return;

eval { $return = $object->get_metagenome_query()  };
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

undef $return;
$test_value{"verbosity"}='minimal'; 
$test_value{"limit"} = 1;
$test_value{"offset"} = 56;
$test_value{"order"}='created'; 
eval { $return = $object->get_metagenome_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with created?") if ($return); 
&test_result($return,\%attributes,\%test_value) ;

undef $return;
$test_value{"order"}='id'; 
eval { $return = $object->get_metagenome_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with id?") if ($return); 

undef $return;
$test_value{"order"}='name'; 
eval { $return = $object->get_metagenome_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with name?") if ($return); 

undef $return;
$test_value{"order"}='sequence_type'; 
eval { $return = $object->get_metagenome_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with sequence_type?") if ($return); 

undef $return;
$test_value{"order"}='file_size'; 
eval { $return = $object->get_metagenome_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with file_size?") if ($return); 

undef $return;
$test_value{"order"}='version'; 
eval { $return = $object->get_metagenome_query(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH with version?") if ($return); 

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
undef %test_value ;
undef $return;

eval { $return = $object->get_metagenome_instance()  };
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

$test_value{"verbosity"}='full'; 
$test_value{id} = 'mgm4440026.3';
eval { $return = $object->get_metagenome_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return an ARRAY?") if ($return); 
&test_result($return,\%attributes,\%test_value) ;

undef $return;
$test_value{"verbosity"}='verbose'; 
eval { $return = $object->get_metagenome_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return an ARRAY?") if ($return); 

undef $return;
$test_value{"verbosity"}='minimal'; 
eval { $return = $object->get_metagenome_instance(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'ARRAY', "$test_name was the return an ARRAY?") if ($return); 

}

#----------------------------------------------------------------------------
#
#  METHOD get_project_query
#	For some reason, projects are nested in an extra array
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
undef %test_value ;
undef $return;

eval { $return = $object->get_project_query()  };
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

undef $return;
$test_value{"limit"} = 1;
$test_value{"offset"} = 56;
$test_value{"order"}='created'; 
eval { $return = $object->get_project_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
$return = pop($return) if ($return);
is(ref $return, "HASH", "Call with valid parameters returns a HASH wiht created") if ($return);
&test_result(pop($return),\%attributes,\%test_value)  if ($return);

undef $return;
$test_value{"order"}='id'; 
eval { $return = $object->get_project_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
$return = pop($return) if ($return);
is(ref $return, "HASH", "Call with valid parameters returns a HASH with id") if ($return);
&test_result($return,\%attributes,\%test_value)  if ($return);

undef $return;
$test_value{"order"}='name'; 
eval { $return = $object->get_project_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
$return = pop($return) if ($return);
is(ref $return, "HASH", "Call with valid parameters returns a HASH with name") if ($return);

undef $return;
$test_value{"order"}='funding_source'; 
eval { $return = $object->get_project_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
$return = pop($return) if ($return);
is(ref $return, "HASH", "Call with valid parameters returns a HASH with funding_source") if ($return);

undef $return;
$test_value{"order"}='pi'; 
eval { $return = $object->get_project_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
$return = pop($return) if ($return);
is(ref $return, "HASH", "Call with valid parameters returns a HASH with pi") if ($return);

undef $return;
$test_value{"order"}='version'; 
eval { $return = $object->get_project_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
$return = pop($return) if ($return);
is(ref $return, "HASH", "Call with valid parameters returns a HASH with version") if ($return);

}

#----------------------------------------------------------------------------
#
#  METHOD get_project_instance
#	For some reason, projects are nested in an extra array
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

eval { $return = $object->get_project_instance()  };
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

undef $return;
$test_value{"verbosity"}='full'; 
$test_value{"id"}='mgp60'; 
eval { $return = $object->get_project_instance(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
$return = pop($return) if ($return);
is(ref($return), "ARRAY", "Call with valid parameters returns an ARRAY") if ($return);
&test_result($return,\%attributes,\%test_value)  if ($return);

}

#----------------------------------------------------------------------------
#
#  METHOD get_sample_query
#
if ($do{'get_sample_query'} eq 'Y')
{
$test_name = "get_sample_query";
note"TEST get_sample_instance";
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
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

undef $return;
$test_value{"limit"} = 1;
$test_value{"offset"} = 56;
$test_value{"order"}='created'; 
eval { $return = $object->get_sample_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a hash") if ($return);
&test_result($return,\%attributes,\%test_value)  if ($return);

undef $return;
$test_value{"order"}='id'; 
eval { $return = $object->get_sample_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a hash") if ($return);

undef $return;
$test_value{"order"}='name'; 
eval { $return = $object->get_sample_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a hash") if ($return);

undef $return;
$test_value{"order"}='version'; 
eval { $return = $object->get_sample_query(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a hash") if ($return);

}

#----------------------------------------------------------------------------
#
#  METHOD get_sample_instance
#
if ($do{'get_sample_instance'} eq 'Y')
{
$test_name = "get_sample_instance";
note("TEST $test_name");

undef %test_value ;
undef $return;

eval { $return = $object->get_sample_instance()  };
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

undef $return;
$test_value{"verbosity"}='full'; 
$test_value{"id"}='mgs73470'; 
eval { $return = $object->get_sample_instance(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "ARRAY", "Call with valid parameters returns a ARRAY") if ($return);
&test_result($return,\%attributes,\%test_value)  if ($return);

undef $return;
$test_value{"verbosity"}='verbose'; 
$test_value{"id"}='mgs73470'; 
eval { $return = $object->get_sample_instance(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "ARRAY", "Call with valid parameters returns a ARRAY") if ($return);

undef $return;
$test_value{"verbosity"}='minimal'; 
$test_value{"id"}='mgs73470'; 
eval { $return = $object->get_sample_instance(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "ARRAY", "Call with valid parameters returns a ARRAY") if ($return);

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
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

undef $return;
$test_value{id} = 'mgm4440026.3';
$test_value{"sequence_type"} = 'dna';
$test_value{"md5"} = ['960128629b9182b2a2dc54f26c94b692','3a50a86ac9665da473b0a6f3525ee2bd'];
eval { $return = $object->get_sequences_md5(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a hash") if ($return);
&test_result($return,\%attributes,\%test_value) ;

undef $return;
$test_value{"sequence_type"} = 'protein';
eval { $return = $object->get_sequences_md5(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a hash") if ($return);

}

#----------------------------------------------------------------------------
#
#  METHOD get_sequences_annotation
#
if ($do{'get_sequences_annotation'} eq 'Y')
{
$test_name = "get_sequences_annotation";
note("TEST $test_name");

undef %test_value ;
undef $return;

eval { $return = $object->get_sequences_annotation()  };
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

undef $return;
$test_value{"verbosity"}='minimal'; 
$test_value{"limit"} = 2;
$test_value{"offset"} = 56;
$test_value{id} = 'mgm4440026.3';
eval { $return = $object->get_sequences_annotation(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");
is (ref($return), 'HASH', "$test_name was the return a HASH?") if ($return); 

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
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

undef $return;
$test_value{id} = 'mgm4440026.3';
eval { $return = $object->get_sequenceset_instance(\%test_value)  };
is($@, '', "Call with valid parameters works $@");
is(ref $return, "HASH", "Call with valid parameters returns a hash") if ($return);
&test_result($return,\%attributes,\%test_value)  if ($return);

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
like($@, qr/Invalid argument count/, "$test_name Call with no parameters failed properly");

undef $return;
$test_value{id} = 'mgm4440037.3-100-1"';
eval { $return = $object->version(\%test_value)  };
is($@, '', "$test_name Call with valid parameter works ");

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
	my $data;

	my $result = $return;
#		print Dumper($result);  

	if (ref($result) eq 'HASH' && exists ($result->{'rows'}) )
	{	#print "DEBUG: Abundanceprofile \n";
		$data->[0] = $result;
	}
	elsif (ref($result) eq 'HASH')
	{   #print "DEBUG: Sample/Library/Metagenome/Project query \n";
		$data = $result->{'data'};
	}  
	elsif (ref($result) eq 'ARRAY')
	{	#print "DEBUG: Sample/Library/Metagenome/Project/Sequences_MD5 instance  \n";
#		print Dumper($result);  
		$data = $return;
	}
	else
	{	print "DEBUG: UNKNOWN  \n";
		$data = $return;
	}

#	my $result = $return->{'result'};
#		print Dumper($data);  
#return;

#	if (ref($result) eq 'HASH' && exists ($return->{'result'}->{'rows'}) )
#	{	#print "DEBUG: Abundanceprofile \n";
#		$data->[0] = $return->{'result'};
#	}
#	elsif (ref($result) eq 'HASH')
#	{   #print "DEBUG: Sample/Library/Metagenome/Project query \n";
#		$data = $return->{'result'}->{'data'};
#	}  
#	elsif (ref($result) eq 'ARRAY')
#	{	#print "DEBUG: Sample/Library/Metagenome/Project/Sequences_MD5 instance  \n";
#		$data = $return->{'result'};
#	}
#	else
#	{	print "DEBUG: UNKNOWN  \n";
#		$data = $return;
#	}

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
					if (exists $attributes{$key4} && $attributes{$key4} eq 'M'  )
					{
						is (ref($key3->{$key4}),'HASH', "Is Attribute $key4 a hash?");
					}
					elsif (exists $attributes{$key4} && $attributes{$key4} eq 'L'  )
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

	is ($result->{'limit'},$test_value{"limit"}, "Is the returned limit the same as the requested limit?") if (exists $test_value{"limit"});
	is ($count, $test_value{"limit"}, "Is the returned number of records the same as the requested limit?") if (exists $test_value{"limit"});
	is ($result->{'offset'},$test_value{"offset"}, "Is the returned offset the same as the requested offset?") if (exists $test_value{"offset"});
	is ($result->{'order'},$test_value{"order"}, "Is the returned order the same as the requested order?") if (exists $test_value{"order"});

#	is ($return->{'result'}->{'limit'},$test_value{"limit"}, "Is the returned limit the same as the requested limit?") if (exists $test_value{"limit"});
#	is ($count, $test_value{"limit"}, "Is the returned number of records the same as the requested limit?") if (exists $test_value{"limit"});
#	is ($return->{'result'}->{'offset'},$test_value{"offset"}, "Is the returned offset the same as the requested offset?") if (exists $test_value{"offset"});
#	is ($return->{'result'}->{'order'},$test_value{"order"}, "Is the returned order the same as the requested order?") if (exists $test_value{"order"});


}

sub test_error
{
	my ($return,$test) = @_;
	my %test_value = %$test;

	if (exists $return->{'error'})
	{
		print "\tRETURN ERROR\n";
		foreach my $key (keys(%{$return->{'error'}->{'data'}}))
		{
			print "\t$return->{'error'}->{'data'}->{$key} \n";
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



