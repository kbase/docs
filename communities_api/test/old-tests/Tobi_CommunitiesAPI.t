#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 11;

use CommunitiesAPIClient;
#use rpc_client;

=pod

=head1 Testing Plan

=head2 Three initial tests

=over

=item Create new object

=back

=cut

my $HOST='http://kbase.us/services/communities';
   $HOST='http://api.metagenomics.anl.gov/api2.cgi/';
#
#  Test 1 - Can a new object be created?
#

#my $object = rpc_client->new({ "url" => $HOST });
my $object = CommunitiesAPIClient->new(); # create a new object
ok( defined $object, "Did an object get defined for Communities" );

#
#  Test 2 - Is the object in the right class?
#
isa_ok( $object, 'CommunitiesAPIClient', "Is it in the right class (Communities)" );   
#isa_ok( $object, 'rpc_client', "Is it in the right class (Communities)" );

$object = CommunitiesAPIClient->new($HOST); # create a new object with the URL
#$object = rpc_client->new({ "url" => $HOST }); # create a new object with the URL

#
#  Test 3 - Are the methods valid?
#

can_ok($object, qw[get_abundanceprofile_instance get_library_query get_library_instance get_metagenome_query get_metagenome_instance get_project_query  get_project_instance get_sample_query get_sample_instance get_sequences_md5 get_sequences_annotation version]);

my $return;
my $test_value;

#----------------------------------------------------------------------------
#
#  METHOD get_metagenome_instance
#
note("TEST get_metagenome_instance");

my $options = {} ;
eval { $return = $object->get_metagenome_instance($options) };
isnt($@, undef, "Call with no parameters failed properly $@");

$options = {'id' => 'mgm4440026.3'};
$return = $object->get_metagenome_instance($options);
ok( !($@) , 'No error for mgm4440026.3');
is(ref $return, "HASH" , "Got HASH");
ok( $return->{id} = $options->{id} , "Got data for mgm4440026.3");

#----------------------------------------------------------------------------
#
#  METHOD get_abundanceprofile_instance
#
note("TEST get_abundanceprofile_instance");

my %test_value ;
eval { $return = $object->get_abundanceprofile_instance(\%test_value) };
isnt($@, undef, "Call with no parameters failed properly $@");

$test_value{'id'} = 'mgm4440026.3';
$test_value{'type'} = 'organism';
$test_value{'source'} = 'M5NR';
$test_value{'limit'}  = 3;
$test_value{'offset'} = 56;
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is(ref $return, "HASH" , "Call with valid parameter works ");

$test_value{'verbosity'} = 'full';
$test_value{'type'} = 'function';
$test_value{'source'} = 'SwissProt';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is(ref $return, "HASH", "Call with valid parameter works ");

$test_value{'verbosity'} = 'verbose';
$test_value{'type'} = 'feature';
$test_value{'source'} = 'GenBank';
eval { $return = $object->get_abundanceprofile_instance(\%test_value)  };
is(ref $return, "HASH" , "Call with valid parameter works ");
exit;

#----------------------------------------------------------------------------
#
#  METHOD get_library_query
#
note("TEST get_library_query");

eval { $return = $object->get_library_query(\%test_value)  };
is($@, undef, "Call with no parameters did not fail $@");

my @library_options = (
	"verbosity='minimal'", 
	"order='created'",
	"order='id'",
	"order='name'",
	"order='version'",
	"limit=2",
	"offset=56"
	);
$test_value{id} = 'mgm4440026.3';
eval { $return = $object->get_library_query(\%test_value)  };
is($@, undef, "Call with no parameters failed properly $@");

exit;
#----------------------------------------------------------------------------
#
#  METHOD get_library_instance
#
note("TEST get_library_instance");

eval { $return = $object->get_library_instance(\%test_value)  };
is($@, undef, "Call with no parameters failed properly $@");

$test_value{id} = 'mgm4440026.3';
eval { $return = $object->get_library_instance(\%test_value)  };
is($@, undef, "Call with valid parameters works $@");

exit;

$return = $object->base_url("$test_value");
is($object->{base_url}, $test_value, "base_url - Pass $test_value and return = $test_value");

$return = $object->base_url("");
is($object->{base_url}, $test_value, "base_url - Pass null value again and return of last set value");

#
#  Set it back to initial value to continue testing
#
$return = $object->base_url("$HOST");

#----------------------------------------------------------------------------
#
#  METHOD json - A getter only
#	Return json object handler
#

$test_value = '';
$return = $object->json("$test_value");
is(ref($object->{json}), 'JSON', "json -  Pass null string and object return is JSON reference");

$test_value = 'test_value';
$return = $object->json("$test_value");
is(ref($return), 'JSON', "json -  Pass non-null string and return is JSON reference");

$test_value = '{ "attribute":"value" }';
$return = $object->json("$test_value");
is(ref($return), 'JSON', "json -  Pass JSON string and return is JSON reference");

#----------------------------------------------------------------------------
#
#  METHOD method
#	Return method - getter but not a setter
#	Take a string that is in JSON and convert to Perl data structure

$test_value = '';
$return = $object->method("$test_value");
is($object->{method}, '', "method - Pass null string return is null");

$test_value = '{ "attribute":"value" }';
$return = $object->method("$test_value");
is($object->{method}, '', "method - Pass non-null string return is null");

#----------------------------------------------------------------------------
#
#  METHOD request
#  Input - Takes resource id query and params as inputs in this order
#	resource is a string that will be appended to the base URL
#	id is a string and will be validated as input the the query
#	query is a string and is appended to the URL
#	params is a reference to an array
#  Return
#	returns a hash with nothing in it if there is a bad ID (produces error message)
#	otherwise returns data from request query
#	returns Perl structure

$return = $object->request();
is(ref($return), 'HASH', "request - Pass no parameters and return reference is a hash");
is(scalar keys(%$return), 0, "request - Pass no parameters and hash is empty");

my $resource = '';
my @param    = ();
my $id       = '';
my $query    = '';
$return = $object->request($resource,$id,$query,\@param);
is(ref($return), 'HASH', "request - Pass empty parameters and return reference is a hash");
is(scalar keys(%$return), 0, "request - Pass empty parameters and hash is empty");

$resource = 'project_not_right';
@param    = ('test');  # nothing IS being done with this now
$id       = 'mgp127';
$query    = 'type=ontology&source=Subsystems';
$return = $object->request($resource,$id,$query,\@param);
is(ref($return), 'HASH', "request - Pass BAD resource and return reference is a hash");

$resource = 'project';
@param    = ('test');  # nothing IS being done with this now
$id       = 'mgp127_not_right';
$query    = 'type=ontology&source=Subsystems';
$return = $object->request($resource,$id,$query,\@param);
is(ref($return), 'HASH', "request - Pass BAD ID and return reference is a hash");
is(scalar keys(%$return), 0, "request - Pass BAD ID and hash is empty");
print "DEBUG: ID=$return->{'id'} and RESOURCE=$return->{'type'}\n";;

$resource = 'project';
@param    = ('test');  # nothing IS being done with this now
$id       = 'mgp127';
$query    = 'type=ontol&source=Subsystems';
$return = $object->request($resource,$id,$query,\@param);
is(ref($return), 'HASH', "request - Pass BAD query parameter and return reference is a hash");
is(scalar keys(%$return), 0, "request - Pass BAD query parameter and hash is empty");
print "DEBUG: ID=$return->{'id'} and RESOURCE=$return->{'type'}\n";;


$resource = 'project';
@param    = ('test');  # nothing IS being done with this now
$id       = 'mgp127';
$query    = 'type=ontology&source=Subsystems';
$return = $object->request($resource,$id,$query,\@param);
is(ref($return), 'HASH', "request - Pass valid parameters and return reference is a hash");

is ($return->{'id'}, $id, 'request - Valid data, key id has requested id ');
is ($return->{'type'}, $resource, 'request - Valid data, key type has requested resouce');
print "DEBUG: ID=$return->{'id'} and RESOURCE=$return->{'type'}\n";
$resource = '';
@param    = ();
$id       = '';
$query    = '';
$return = $object->request($resource,$id,$query,\@param);
is(ref($return), 'HASH', "request - Pass empty parameters and return reference is a hash");
is(scalar keys(%$return), 0, "request - Pass empty parameters and hash is empty");

 
#--------------------------------------------------------------------------t;-
#
#  METHOD query
#  Input - resource type (e.g., project), hash of key value pairs which are
#     attributes of the resource (e.g., public = 0 or 1 )
#  Return - A list of resources of this type  that have these attributes
#	The list is a hash 
#

$test_value = '';
$return = $object->query();
is(ref($return), 'HASH', "query - No input parameters returns a HASH");
is(scalar keys(%$return), 0, "query - No input parameters returns an empty HASH");

my $rt = '';
my %att = (  );
$return = $object->query($rt,\%att);
is(ref($return), 'HASH', "query - Null input parameters returns a HASH");
is(scalar keys(%$return), 0, "query - Null input parameters returns an empty HASH");

$rt = 'project_not_right';
%att = ( 'public' => 1 );
$return = $object->query($rt,\%att);
is(ref($return), 'HASH', "query - Bad resource parameter returns a HASH");

$rt = 'project';
%att = ( 'public' => 'NAN' );
$return = $object->query($rt,\%att);
is(ref($return), 'ARRAY', "query - Valid Resource but invalid attributes returns a ARRAY");
is(scalar @$return, 0, "query - Valid Resource but invalid attributes returns an empty ARRAY");

$rt = 'project';
%att = ( 'public' => 1 );
$return = $object->query($rt,\%att);
is(ref($return), 'ARRAY', "query - Valid input parameters returns a ARRAY");
isnt(scalar @$return, 0, "query - Valid input parameters returns a non-empty ARRAY");

foreach my $item (@$return) {
	is(ref($item), 'HASH', "query - ARRAY list contains HASH references");
	last;
}

#----------------------------------------------------------------------------
#
#  METHOD project
#  Input - project id or empty 
#  Return - a Perl object for a project ID
#	With no input parameters, returns a hash with two keys, 
#   key1='metagenomics project' is a list of project IDs, key2 = 'about' 
#	for every key in the  hash should have a method (e.g., ID , version created, everything in the JSON structure (see new)
#
$return = $object->project();
is(ref($return), 'HASH', "project - null input parameters returns a hash");
is(scalar (keys %$return), 2, "project - null input parameters returns a non-empty hash");
is ($return->{'about'}, 'metagenomics project', 'project - key about is metagenomics');
is (ref($return->{'projects'}), 'ARRAY', 'project - key projects is an ARRAY');

my $list = $return->{'projects'};
isnt(scalar @$list, 0, 'project - ARRAY is not empty');

my $one_project_id = '';
foreach  (@$list) {
	$one_project_id = $_;
}

$return = $object->project('Not_a_project_id');
is($return, '0', "project - BAD input parameters returns zero");

$return = $object->project($one_project_id);
is(ref($return), 'Communities::Project', "project - Valid input parameters returns a Communities::Project object");
my $test = $return->id;
is ($test,$one_project_id,"Is the ID that came back the same as the one requested");

#----------------------------------------------------------------------------
#
#  METHOD sample
#  Works the same as project
#
#
$return = $object->sample();
is(ref($return), 'HASH', "sample - null input parameters returns a hash");
is(scalar (keys %$return), 2, "sample - null input parameters returns a non-empty hash");
is ($return->{'about'}, 'sample', 'sample - key about is sample');
is (ref($return->{'samples'}), 'ARRAY', 'sample - key samples is an ARRAY');

$list = $return->{'samples'};
isnt(scalar @$list, 0, 'sample - ARRAY is not empty');

my $one_sample_id = '';
foreach  (@$list) {
	$one_sample_id = $_;
}

$return = $object->sample('Not_a_sample');
is($return, '0', "sample - Bad input parameters returns a zero");

print "DEBUG: MY ONE SAMPLE ID = $one_sample_id\n";
$return = $object->sample($one_sample_id);
is(ref($return), 'Communities::Sample', "sample - Valid input parameters returns a Communities::Sample");
$test = $return->id;
is ($test,$one_sample_id,"Is the ID that came back the same as the one requested");


#----------------------------------------------------------------------------
#
#  METHOD library
#  Works the same as project
#  Input - id and q
#  Return
#	List of available library IDs

$return = $object->library();
is(ref($return), 'HASH', "library - null input parameters returns a hash");
is(scalar (keys %$return), 2, "library - null input parameters returns a non-empty hash");
is ($return->{'about'}, 'metagenomics library', 'library - key about is metagenomics library');
is (ref($return->{'librarys'}), 'ARRAY', 'library - key librarys is an ARRAY');
foreach my $key (keys(%$return)) {
  print "Return for KEY $key = $return->{$key}\n";
}

$list = $return->{'librarys'};
isnt(scalar @$list, 0, 'library - ARRAY is not empty');

my $one_library_id = '';
foreach  (@$list) {
	$one_library_id = $_;
}
print "DEBUG: MY ONE LIBRARY ID = $one_library_id\n";

$return = $object->library('Not_a_library');
is($return, '', "library - Bad input parameters returns nothing");

$return = $object->library($one_library_id);
is(ref($return), 'Communities::Library', "library - Valid input parameters returns a Communities::Library");
$test = $return->id;
is ($test,$one_library_id,"Is the ID that came back the same as the one requested");


#----------------------------------------------------------------------------
#
#  METHOD TO_JSON
#	JSON helper function
