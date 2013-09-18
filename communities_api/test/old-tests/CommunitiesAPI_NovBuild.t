#!/usr/bin/perl -w
use strict;

use Data::Dumper;
use Test::More 'no_plan';

my $num_tests = 0;
#my $host = "http://www.kbase.us/services/communities";
my $host = "http://api.metagenomics.anl.gov/api2.cgi";

###############################################################################
# Test the module initialization process
# (5 tests)
use_ok("CommunitiesAPIClient");
use_ok("Bio::KBase::Exceptions");
my $client = new_ok("CommunitiesAPIClient", [$host]);
ok(defined $client, "Did we get a client object?");
isa_ok($client, 'CommunitiesAPIClient', "Is it the right class?");

$num_tests += 5;

$num_tests += test_abundanceprofile_instance($client);
$num_tests += test_library_query($client);
$num_tests += test_library_instance($client);
$num_tests += test_metagenome_query($client);
$num_tests += test_metagenome_instance($client);
$num_tests += test_project_query($client);
$num_tests += test_project_instance($client);
$num_tests += test_sample_query($client);
$num_tests += test_sample_instance($client);
$num_tests += test_sequences_md5($client); 
$num_tests += test_sequences_annotation($client);	# incomplete
$num_tests += test_sequenceset_instance($client);
$num_tests += test_sequenceset_list($client);

done_testing($num_tests);

# Tests the command "get_abundanceprofile_instance"
sub test_abundanceprofile_instance {
	my $client = shift;
	my $num_tests = 0;
	my $test_name = "get_abundanceprofile_instance";

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

	my $test_id = "mgm4440286.3";
	my @verbosities = ( 'minimal', 'verbose', 'full' );
	my $sources = {
		'M5RNA' => {
			allowed => ['organism', 'feature'],
			not_allowed => ['function']
		},
		'RDP' => {
			allowed => ['organism', 'feature'],
			not_allowed => ['function']
		},
		'Greengenes' => {
			allowed => ['organism', 'feature'],
			not_allowed => ['function']
		},
		'LSU' => {
                        allowed => ['organism', 'feature'],
                        not_allowed => ['function']
                },
		'SSU' => {
                        allowed => ['organism', 'feature'],
                        not_allowed => ['function']
                },
		'M5NR' => {
                        allowed => ['organism', 'feature'],
                        not_allowed => ['function']
                },
		'SwissProt' => {
                        allowed => ['organism', 'feature'],
                        not_allowed => ['function']
                },
		'GenBank' => {
                        allowed => ['organism', 'feature'],
                        not_allowed => ['function']
                },
		'IMG' => {
                        allowed => ['organism', 'feature'],
                        not_allowed => ['function']
                },
		'KEGG' => {
                        allowed => ['organism', 'feature'],
                        not_allowed => ['function']
                },
		'SEED' => {
                        allowed => ['organism', 'feature'],
                        not_allowed => ['function']
                },
		'TrEMBL' => {
                        allowed => ['organism', 'feature'],
                        not_allowed => ['function']
                },
		'RefSeq' => {
                        allowed => ['organism', 'feature'],
                        not_allowed => ['function']
                },
		'PATRIC' => {
                        allowed => ['organism', 'feature'],
                        not_allowed => ['function']
                },
		'eggNOG' => {
                        allowed => ['organism', 'feature'],
                        not_allowed => ['function']
                },
		'NOG' => {
			allowed => ['function'],
			not_allowed => ['organism', 'feature'],
		},
		'COG' => {
                        allowed => ['function'],
                        not_allowed => ['organism', 'feature'],
                },
		'KO' => {
                        allowed => ['function'],
                        not_allowed => ['organism', 'feature'],
                },
		'GO' => {
                        allowed => ['function'],
                        not_allowed => ['organism', 'feature'],
                },
		'Subsystems' => {
                        allowed => ['function'],
                        not_allowed => ['organism', 'feature'],
                },
	};

	# major variable for return values
	my $return;

	#######################################################################
	# invalid data tests
	# ------------------
	# 1. bad id test
	
	# 2. bad source db test
	
	# 3. bad type test
	
	# 4. bad verbosity test

	#######################################################################
	# missing parameter tests
	# -----------------------
	# 1. no id test
	eval { $return = $client->get_abundanceprofile_instance({ source => 'M5RNA', verbosity => 'minimal', type => 'organism'}); };
	#like($@, qr/Invalid argument count/, "\"$test_name\" called with no id failed properly");
	if (!$@) {
		note "Checking if running with no id returns a method description object";
		$num_tests += test_method_description($return);
	}

	# 2. no source test (should go to default - M5RNA)
	undef $return;
	eval { $return = $client->get_abundanceprofile_instance({ id => $test_id, verbosity => 'minimal', type => 'organism'}); };
	is($@, '', "\"$test_name\" called with no source succeeded properly");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { id => $test_id, verbosity => 'minimal', type => 'organism'}); }

	# 3. no verbosity test (should go to default - minimal)
	undef $return;
    eval { $return = $client->get_abundanceprofile_instance({ id => $test_id, source => 'M5RNA', type => 'organism'}); };
	is($@, '', "\"$test_name\" called with no verbosity succeeded properly");
    $num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { id => $test_id, source => 'M5RNA', type => 'organism'}); }

	# 4. no type test (should go to default - organism)
	undef $return;
    eval { $return = $client->get_abundanceprofile_instance({ id => $test_id, verbosity => 'minimal', source=>'M5RNA'}); };
	is($@, '', "\"$test_name\" called with no type succeeded properly");
    $num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { id => $test_id, verbosity => 'minimal', source=>'M5RNA'}); }

	# 5. no parameters test
	eval { $return = $client->get_abundanceprofile_instance(); };
	if (!$@) {
		note "Checking if running with no parameters returns a method description object";
		$num_tests += test_method_description($return);
	}
#	like($@, qr/Invalid argument count/, "\"$test_name\" called with no parameters failed properly");

	#######################################################################
	# valid parameter tests
	# ---------------------
	foreach my $verbosity (@verbosities) {
		foreach my $source (keys %{ $sources }) {
			foreach my $type (@{ $sources->{$source}->{allowed} }) {
				undef $return;
				my $params = { 
						id => $test_id,
						source => $source,
						verbosity => $verbosity,
						type => $type
				};
                print "Testing \"get_abundanceprofile_instance\" with valid parameters:\nid = $test_id\nsource = $source\nverbosity = $verbosity\ntype = $type\n";
				eval { $return = $client->get_abundanceprofile_instance( $params ); };
				is ($@, '', "\"$test_name\" call with valid parameters did not return an error.");
				$num_tests++;
				if ($@) {
					print STDERR "Test for \"$test_name\" failed with valid(?) parameters:\n";
					print STDERR Dumper($params);
					print STDERR "Returned structure (if any):\n";
					print STDERR Dumper($@);
					print STDERR Dumper($return);
				}
				elsif ($return) {
					is (ref($return), "HASH", "\"$test_name\" returned a HASH");
					$num_tests++;
					$num_tests += test_result($return, \%attributes, $params);
					
				}
			}
		}
	}

    #######################################################################
    # Incorrect parameter tests - test whether searching a database with an invalid type fail properly
    # E.g. looking up a 'function' in 'M5RNA' should fail.
    # ----------------------------------------------------
    foreach my $source (keys %{ $sources }) {
        foreach my $type (@{ $sources->{$source}->{not_allowed} }) {
            undef $return;
            my $params = {
                            id => $test_id,
                            source => $source,
                            verbosity => 'minimal',
                            type => $type
            };
            eval { $return = $client->get_abundanceprofile_instance( $params ); };
            my $error = $@;
            # print Dumper($error->message());
            # print $error->message()->{data}->{ERROR} . "\n";
            ok($error, "Calling 'get_abundanceprofile_instance' with source='$source' and type='$type' properly returns an error.");
            $num_tests++;

            if ($error) {
            	$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid source/);
            }
        }
    }


	return $num_tests;
}

sub test_library_query {
	my $client = shift;
    my $num_tests = 0;
    my $test_name = "get_library_query";

	my %attributes = (
					'next' => 'S',
					'prev' => 'S',
					'order' => 'S',
					'limit' => 'S',
					'data' => 'L',
					'offset' => 'S',
					'total_count' => 'S'
					);

	# valid parameters for the call =
	# verbosity (def. minimal) minimal
	# order (def id) id, name
	# limit (no default) 1...?
	# offset (no default) 0...?

	my $return;
	my $error;

	#######################################################################
	# happy path tests
	# ----------------
	# 1. verbosity = minimal, order = id, limit = 10, offset = 0
	undef $return;
	undef $error;
	eval { $return = $client->get_library_query({ verbosity => 'minimal', order => 'id', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with valid data passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', limit => 10, offset => 0 }); }

	# 2. Let order = "name"
	undef $return;
	undef $error;
	eval { $return = $client->get_library_query({ verbosity => 'minimal', order => 'name', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with valid data passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'name', limit => 10, offset => 0 }); }

	# 3. Let verbosity = default
	undef $return;
	undef $error;
	eval { $return = $client->get_library_query({ order => 'id', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with default verbosity passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { order => 'id', limit => 10, offset => 0 }); }

	# 4. Let order = default
	undef $return;
	undef $error;
	eval { $return = $client->get_library_query({ verbosity => 'minimal', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with default order passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', limit => 10, offset => 0 }); }

	# 5. Let limit be default
	undef $return;
	undef $error;
	eval { $return = $client->get_library_query({ verbosity => 'minimal', order => 'id', offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with default limit passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', offset => 0 }); }

	# 6. Let offset be default
	undef $return;
	undef $error;
	eval { $return = $client->get_library_query({ verbosity => 'minimal', order => 'id', limit => 10}); };
	is($@, '', "Calling \"$test_name\" with default offset passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', limit => 10 }); }

	# 7. Let offset be nonzero
	undef $return;
	undef $error;
	eval { $return = $client->get_library_query({ verbosity => 'minimal', order => 'id', limit => 10, offset => 10 }); };
	is($@, '', "Calling \"$test_name\" with nonzero offset passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', limit => 10, offset => 10 }); }

	#######################################################################
	# invalid parameter tests - should fail nicely
	# --------------------------------------------
	# 1. verbosity = blah
	undef $return;
	undef $error;
	eval { $return = $client->get_library_query({ verbosity => 'blah', order => 'id', limit => 10, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with verbosity = 'blah' properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid value for option verbosity/i);
	}

	# 2. order = blah
	undef $return;
	undef $error;
	eval { $return = $client->get_library_query({ verbosity => 'minimal', order => 'blah', limit => 10, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with order = 'blah' properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid sort order/i);
	}

	# 3. limit = 0
	undef $return;
	undef $error;
	eval { $return = $client->get_library_query({ verbosity => 'minimal', order => 'id', limit => 0, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with limit = 0 properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid value for option limit/i);
	}

	# 4. limit = -10
	undef $return;
	undef $error;
	eval { $return = $client->get_library_query({ verbosity => 'minimal', order => 'id', limit => -10, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with limit = -10 properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid value for option limit/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name(); };
	ok($@, "Calling '$test_name' with no parameters returns an error.");
	$num_tests++;
	$error = $@;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::ArgumentValidationError", 400, qr/Invalid/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name({}); };
	ok($return, "Calling '$test_name' with empty parameters returns something.");
	$num_tests++;

	$error = $@;
	if ($return) {
		note"Checking if calling '$test_name' with no parameters returns a method description object";
		$num_tests += test_method_description($return);
	}
    return $num_tests;
}

sub test_library_instance {
	my $client = shift;
    my $num_tests = 0;

    my $test_name = "get_library_instance";
	my $test_id = "mgl52642";
	my @verbosities = ( 'minimal', 'verbose', 'full' );

	my %attributes = (
						'version' => 'S',
						'project' => 'L',
						'name' => 'S',
						'sequence_sets' => 'LM',
						'metagenome' => 'L',
						'created' => 'S',
						'url' => 'S',
						'id' => 'S',
						'sample' => 'L',
						'metadata' => 'M',
						'reads' => 'L' 
					);

	my $return;
	my $error;

	###########################################################################
	# Happy path tests
	# ----------------
	# loop through every verbosity with a single id and make sure they're good.
	foreach my $verbosity (@verbosities) {
		my $params = { 
						'id' => $test_id,
						'verbosity' => $verbosity
					};
		undef $return;
		undef $error;
		eval { $return = $client->$test_name($params); };
		is($@, '', "Calling '$test_name' with verbosity='$verbosity' and id='$test_id' passed successfully.");
		$num_tests++;

		if ($return) {
			$num_tests += test_result($return, \%attributes, $params);
		}
	}

	###########################################################################
	# Invalid param tests
	# -------------------
	# 1. No parameters
	undef $return;
	undef $error;
	eval { $return = $client->$test_name(); };
	$error = $@;
	ok($error, "Calling '$test_name' with no parameters returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::ArgumentValidationError", 400, qr/Invalid/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name({}); };
	ok($return, "Calling '$test_name' with empty parameters returns something.");
	$num_tests++;
	if ($return) {
		note"Checking if calling '$test_name' with no parameters returns a method description object";
		$num_tests += test_method_description($return);
	}


	# 2. No id
	undef $return;
	undef $error;
	eval { $return = $client->$test_name({ verbosity=>'minimal' }); };
	ok($return, "Calling '$test_name' with no id returns something.");
#	isnt($@, '', "Calling '$test_name' with no id gives an error");
	$num_tests++;
	if ($return) {
		note "Checking if calling '$test_name' with no id returns a method description object";
		#print Dumper($return);
		$num_tests += test_method_description($return);
	}

	# 3. Invalid verbosity
	undef $return;
	undef $error;
	eval { $return = $client->$test_name({ id=>$test_id, verbosity=>"blah" }); };
	isnt($@, '', "Calling '$test_name' with an invalid verbosity gives an error");
	$error = $@;
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid/i);
	}

    return $num_tests;
}

sub test_metagenome_query {
	my $client = shift;
    my $num_tests = 0;
    my $test_name = "get_metagenome_query";

	my %attributes = (
					'next' => 'S',
					'prev' => 'S',
					'order' => 'S',
					'limit' => 'S',
					'data' => 'L',
					'offset' => 'S',
					'total_count' => 'S'
					);

	# valid parameters for the call =
	# verbosity (def. minimal) minimal
	# order (def id) id, name
	# limit (no default) 1...?
	# offset (no default) 0...?

	my $return;
	my $error;

	#######################################################################
	# happy path tests
	# ----------------
	# 1. verbosity = minimal, order = id, limit = 10, offset = 0
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with valid data passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', limit => 10, offset => 0 }); }

	# 2. Let order = "name"
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'name', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with valid data passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'name', limit => 10, offset => 0 }); }

	# 3. Let verbosity = default
	eval { $return = $client->$test_name({ order => 'id', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with default verbosity passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { order => 'id', limit => 10, offset => 0 }); }

	# 4. Let order = default
	eval { $return = $client->$test_name({ verbosity => 'minimal', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with default order passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', limit => 10, offset => 0 }); }

	# 5. Let limit be default
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with default limit passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', offset => 0 }); }

	# 6. Let offset be default
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => 10}); };
	is($@, '', "Calling \"$test_name\" with default offset passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', limit => 10 }); }

	# 7. Let offset be nonzero
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => 10, offset => 10 }); };
	is($@, '', "Calling \"$test_name\" with nonzero offset passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', limit => 10, offset => 10 }); }

	#######################################################################
	# invalid parameter tests - should fail nicely
	# --------------------------------------------
	# 1. verbosity = blah
	eval { $return = $client->$test_name({ verbosity => 'blah', order => 'id', limit => 10, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with verbosity = 'blah' properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid value for option verbosity/i);
	}

	# 2. order = blah
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'blah', limit => 10, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with order = 'blah' properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid sort order/i);
	}

	# 3. limit = 0
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => 0, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with limit = 0 properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid value for option limit/i);
	}

	# 4. limit = -10
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => -10, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with limit = -10 properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid value for option limit/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name(); };
	ok($@, "Calling '$test_name' with no parameters returns an error.");
	$num_tests++;
	$error = $@;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::ArgumentValidationError", 400, qr/Invalid/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name({}); };
	ok($return, "Calling '$test_name' with empty parameters returns something.");
	$num_tests++;

	$error = $@;
	if ($return) {
		note"Checking if calling '$test_name' with empty parameters returns a method description object";
		$num_tests += test_method_description($return);
	}

    return $num_tests;
}

sub test_metagenome_instance {
	my $client = shift;
    my $num_tests = 0;

    my $test_name = "get_metagenome_instance";
	my $test_id = "mgm4440286.3";
	my @verbosities = ( 'minimal', 'verbose', 'full' );

	my %attributes = (
						'version' => 'S',
						'project' => 'L',
						'name' => 'S',
						'library' => 'L',
						'sequence_type' => 'S',
						'created' => 'S',
						'url' => 'S',
						'id' => 'S',
						'sample' => 'L',
						'metadata' => 'M',
					);

	my $return;
	my $error;

	###########################################################################
	# Happy path tests
	# ----------------
	# loop through every verbosity with a single id and make sure they're good.
	foreach my $verbosity (@verbosities) {
		my $params = { 
						'id' => $test_id,
						'verbosity' => $verbosity
					};
		eval { $return = $client->$test_name($params); };
		is($@, '', "Calling '$test_name' with verbosity='$verbosity' and id='$test_id' passed successfully.");
		$num_tests++;

		if ($return) {
			$num_tests += test_result($return, \%attributes, $params);
		}
	}

	###########################################################################
	# Invalid param tests
	# -------------------
	# 1. No parameters
	undef $return;
	undef $error;
	eval { $return = $client->$test_name(); };
	$error = $@;
	ok($error, "Calling '$test_name' with no parameters returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::ArgumentValidationError", 400, qr/Invalid/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name({}); };
	ok($return, "Calling '$test_name' with empty parameters returns something.");
	$num_tests++;
	if ($return) {
		note"Checking if calling '$test_name' with no parameters returns a method description object";
		$num_tests += test_method_description($return);
	}

	# 2. No id
	undef $return;
	undef $error;
	eval { $return = $client->$test_name({ verbosity=>'minimal' }); };
	ok($return, "Calling '$test_name' with no id returns something.");
#	isnt($@, '', "Calling '$test_name' with no id gives an error");
	$num_tests++;
	if (!$@) {
		note "Checking if calling '$test_name' with no id returns a method description object";
		$num_tests += test_method_description($return);
	}

	# 3. Invalid verbosity
	eval { $return = $client->$test_name({ id=>$test_id, verbosity=>"blah" }); };
	isnt($@, '', "Calling '$test_name' with an invalid verbosity gives an error");
	$error = $@;
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid/i);
	}

    return $num_tests;
}

sub test_project_query {
	my $client = shift;
    my $num_tests = 0;
    my $test_name = "get_project_query";

	my %attributes = (
					'next' => 'S',
					'prev' => 'S',
					'order' => 'S',
					'limit' => 'S',
					'data' => 'L',
					'offset' => 'S',
					'total_count' => 'S'
					);

	# valid parameters for the call =
	# verbosity (def. minimal) minimal
	# order (def id) id, name
	# limit (no default) 1...?
	# offset (no default) 0...?

	my $return;
	my $error;

	#######################################################################
	# happy path tests
	# ----------------
	# 1. verbosity = minimal, order = id, limit = 10, offset = 0
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with valid data passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', limit => 10, offset => 0 }); }

	# 2. Let order = "name"
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'name', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with valid data passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'name', limit => 10, offset => 0 }); }

	# 3. Let verbosity = default
	eval { $return = $client->$test_name({ order => 'id', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with default verbosity passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { order => 'id', limit => 10, offset => 0 }); }

	# 4. Let order = default
	eval { $return = $client->$test_name({ verbosity => 'minimal', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with default order passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', limit => 10, offset => 0 }); }

	# 5. Let limit be default
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with default limit passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', offset => 0 }); }

	# 6. Let offset be default
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => 10}); };
	is($@, '', "Calling \"$test_name\" with default offset passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', limit => 10 }); }

	# 7. Let offset be nonzero
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => 10, offset => 10 }); };
	is($@, '', "Calling \"$test_name\" with nonzero offset passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', limit => 10, offset => 10 }); }

	#######################################################################
	# invalid parameter tests - should fail nicely
	# --------------------------------------------
	# 1. verbosity = blah
	eval { $return = $client->$test_name({ verbosity => 'blah', order => 'id', limit => 10, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with verbosity = 'blah' properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid value for option verbosity/i);
	}

	# 2. order = blah
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'blah', limit => 10, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with order = 'blah' properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid sort order/i);
	}

	# 3. limit = 0
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => 0, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with limit = 0 properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid value for option limit/i);
	}

	# 4. limit = -10
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => -10, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with limit = -10 properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid value for option limit/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name(); };
	ok($@, "Calling '$test_name' with no parameters returns an error.");
	$num_tests++;
	$error = $@;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::ArgumentValidationError", 400, qr/Invalid/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name({}); };
	ok($return, "Calling '$test_name' with empty parameters returns something.");
	$num_tests++;

	$error = $@;
	if ($return) {
		note"Checking if calling '$test_name' with empty parameters returns a method description object";
		$num_tests += test_method_description($return);
	}

    return $num_tests;
}

sub test_project_instance {
	my $client = shift;
    my $num_tests = 0;

    my $test_name = "get_project_instance";
	my $test_id = "mgp7";
	my @verbosities = ( 'minimal', 'verbose', 'full' );

	my %attributes = (
						'analyzed' => 'LL',
						'version' => 'S',
						'name' => 'S',
						'description' => 'S',
						'libraries' => 'LL',
						'created' => 'S',
						'samples' => 'LL',
						'funding_source' => 'S',
						'url' => 'S',
						'metadata' => 'M',
						'id' => 'S',
						'pi' => 'S'
					);

	my $return;
	my $error;

	###########################################################################
	# Happy path tests
	# ----------------
	# loop through every verbosity with a single id and make sure they're good.
	foreach my $verbosity (@verbosities) {
		my $params = { 
						'id' => $test_id,
						'verbosity' => $verbosity
					};
		eval { $return = $client->$test_name($params); };
		is($@, '', "Calling '$test_name' with verbosity='$verbosity' and id='$test_id' passed successfully.");
		$num_tests++;

		if ($return) {
			$num_tests += test_result($return, \%attributes, $params);
		}
	}

	###########################################################################
	# Invalid param tests
	# -------------------
	# 1. No parameters
	undef $return;
	undef $error;
	eval { $return = $client->$test_name(); };
	$error = $@;
	ok($error, "Calling '$test_name' with no parameters returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::ArgumentValidationError", 400, qr/Invalid/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name({}); };
	ok($return, "Calling '$test_name' with empty parameters returns something.");
	$num_tests++;
	if ($return) {
		note"Checking if calling '$test_name' with no parameters returns a method description object";
		$num_tests += test_method_description($return);
	}


	# 2. No id
	undef $return;
	undef $error;
	eval { $return = $client->$test_name({ verbosity=>'minimal' }); };
	ok($return, "Calling '$test_name' with no id returns something.");
#	isnt($@, '', "Calling '$test_name' with no id gives an error");
	$num_tests++;
	if (!$@) {
		note "Checking if calling '$test_name' with no id returns a method description object";
		$num_tests += test_method_description($return);
	}

	# 3. Invalid verbosity
	eval { $return = $client->$test_name({ id=>$test_id, verbosity=>"blah" }); };
	isnt($@, '', "Calling '$test_name' with an invalid verbosity gives an error");
	$error = $@;
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid/i);
	}

    return $num_tests;
}

sub test_sample_query {
	my $client = shift;
    my $num_tests = 0;
    my $test_name = "get_sample_query";

	my %attributes = (
					'next' => 'S',
					'prev' => 'S',
					'order' => 'S',
					'limit' => 'S',
					'data' => 'L',
					'offset' => 'S',
					'total_count' => 'S'
					);

	# valid parameters for the call =
	# verbosity (def. minimal) minimal
	# order (def id) id, name
	# limit (no default) 1...?
	# offset (no default) 0...?

	my $return;
	my $error;

	#######################################################################
	# happy path tests
	# ----------------
	# 1. verbosity = minimal, order = id, limit = 10, offset = 0
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with valid data passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', limit => 10, offset => 0 }); }

	# 2. Let order = "name"
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'name', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with valid data passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'name', limit => 10, offset => 0 }); }

	# 3. Let verbosity = default
	eval { $return = $client->$test_name({ order => 'id', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with default verbosity passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { order => 'id', limit => 10, offset => 0 }); }

	# 4. Let order = default
	eval { $return = $client->$test_name({ verbosity => 'minimal', limit => 10, offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with default order passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', limit => 10, offset => 0 }); }

	# 5. Let limit be default
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', offset => 0 }); };
	is($@, '', "Calling \"$test_name\" with default limit passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', offset => 0 }); }

	# 6. Let offset be default
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => 10}); };
	is($@, '', "Calling \"$test_name\" with default offset passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', limit => 10 }); }

	# 7. Let offset be nonzero
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => 10, offset => 10 }); };
	is($@, '', "Calling \"$test_name\" with nonzero offset passed successfully.");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { verbosity => 'minimal', order => 'id', limit => 10, offset => 10 }); }

	#######################################################################
	# invalid parameter tests - should fail nicely
	# --------------------------------------------
	# 1. verbosity = blah
	eval { $return = $client->$test_name({ verbosity => 'blah', order => 'id', limit => 10, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with verbosity = 'blah' properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid value for option verbosity/i);
	}

	# 2. order = blah
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'blah', limit => 10, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with order = 'blah' properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid sort order/i);
	}

	# 3. limit = 0
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => 0, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with limit = 0 properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid value for option limit/i);
	}

	# 4. limit = -10
	eval { $return = $client->$test_name({ verbosity => 'minimal', order => 'id', limit => -10, offset => 0 }); };
	$error = $@;
	ok($error, "Calling '$test_name' with limit = -10 properly returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid value for option limit/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name(); };
	ok($@, "Calling '$test_name' with no parameters returns an error.");
	$num_tests++;
	$error = $@;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::ArgumentValidationError", 400, qr/Invalid/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name({}); };
	ok($return, "Calling '$test_name' with empty parameters returns something.");
	$num_tests++;

	$error = $@;
	if ($return) {
		note"Checking if calling '$test_name' with empty parameters returns a method description object";
		$num_tests += test_method_description($return);
	}

    return $num_tests;
}

sub test_sample_instance {
	my $client = shift;
    my $num_tests = 0;

    my $test_name = "get_sample_instance";
	my $test_id = "mgs24887";
	my @verbosities = ( 'minimal', 'verbose', 'full' );

	my %attributes = (
						'version' => 'S',
						'project' => 'L',
						'name' => 'S',
						'metagenomes' => 'LL',
						'libraries' => 'LL',
						'env_package' => 'M',
						'created' => 'S',
						'url' => 'S',
						'id' => 'S',
						'metadata' => 'M',
					);

	my $return;
	my $error;

	###########################################################################
	# Happy path tests
	# ----------------
	# loop through every verbosity with a single id and make sure they're good.
	foreach my $verbosity (@verbosities) {
		my $params = { 
						'id' => $test_id,
						'verbosity' => $verbosity
					};
		eval { $return = $client->$test_name($params); };
		is($@, '', "Calling '$test_name' with verbosity='$verbosity' and id='$test_id' passed successfully.");
		$num_tests++;

		if ($return) {
			$num_tests += test_result($return, \%attributes, $params);
		}
	}

	###########################################################################
	# Invalid param tests
	# -------------------
	# 1. No parameters
	undef $return;
	undef $error;
	eval { $return = $client->$test_name(); };
	$error = $@;
	ok($error, "Calling '$test_name' with no parameters returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::ArgumentValidationError", 400, qr/Invalid/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name({}); };
	ok($return, "Calling '$test_name' with empty parameters returns something.");
	$num_tests++;
	if ($return) {
		note"Checking if calling '$test_name' with no parameters returns a method description object";
		$num_tests += test_method_description($return);
	}


	# 2. No id
	undef $return;
	undef $error;
	eval { $return = $client->$test_name({ verbosity=>'minimal' }); };
	ok($return, "Calling '$test_name' with no id returns something.");
#	isnt($@, '', "Calling '$test_name' with no id gives an error");
	$num_tests++;
	if (!$@) {
		note "Checking if calling '$test_name' with no id returns a method description object";
		$num_tests += test_method_description($return);
	}

	# 3. Invalid verbosity
	undef $return;
	undef $error;
	eval { $return = $client->$test_name({ id=>$test_id, verbosity=>"blah" }); };
	isnt($@, '', "Calling '$test_name' with an invalid verbosity gives an error");
	$error = $@;
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid/i);
	}

    return $num_tests;
}

sub test_sequences_md5 {
	my $client = shift;
    my $num_tests = 0;
    my $test_name = "get_sequences_md5";
    my $test_id = "mgm4456124.3";

    my @types = qw(dna protein);
    my @md5s = qw(95062173176b41c7f1935e976998ec6b); #Proteobacteria); #349187ec8969d0eb15aee1ca593e09b8 a72ba41df2f002009809b40f86a52a34 Proteobacteria);

    my %attributes = (
    					'version' => 'S',
    					'url' => 'S',
    					'data' => 'ML',
    					'id' => 'S'
    					);
    my $return;
    my $error;
    ###########################################################################
    # Happy tests!
    #
    foreach my $type (@types) {
    	my $params = { 
    					id => $test_id,
    					sequence_type => $type 
    				};
    	undef $return;
    	undef $error;
	    eval { $return = $client->$test_name($params); };
		is($@, '', "Calling '$test_name' with sequence_type='$type' and id='$test_id' passed successfully.");
		$num_tests++;

		if ($return) {
			$num_tests += test_result($return, \%attributes, $params);
		}
    }

   	my $params = {
   		id => $test_id,
   		sequence_type => 'dna',
   		md5 => \@md5s
   	};
   	undef $return;
   	undef $error;
   	eval { $return = $client->$test_name($params); };
   	is ($@, '', "Calling '$test_name' with md5s passed successfully.");
   	$num_tests++;
   	if ($return) {
   		$num_tests += test_result($return, \%attributes, $params);
   	}

	###########################################################################
	# Invalid param tests
	# -------------------
	# 1. No parameters
	undef $return;
	undef $error;
	eval { $return = $client->$test_name(); };
	$error = $@;
	ok($error, "Calling '$test_name' with no parameters returns an error.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::ArgumentValidationError", 400, qr/Invalid/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name({}); };
	ok($return, "Calling '$test_name' with empty parameters returns something.");
	$num_tests++;
	if ($return) {
		note"Checking if calling '$test_name' with no parameters returns a method description object";
		$num_tests += test_method_description($return);
#		print Dumper($return);
	}


	# 2. No id
	undef $return;
	undef $error;
	eval { $return = $client->$test_name({ sequence_type=>'dna' }); };
	ok($return, "Calling '$test_name' with no id returns something.");
	$num_tests++;
	if (!$@) {
		note "Checking if calling '$test_name' with no id returns a method description object";
		$num_tests += test_method_description($return);
	}

	# 3. Invalid sequence type
	undef $return;
	undef $error;
	eval { $return = $client->$test_name({ id=>$test_id, sequence_type=>'blah' }); };
	isnt($@, '', "Calling '$test_name' with an invalid sequence_type gives an error");
	$error = $@;
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid/i);
	}
#	print Dumper($return);

	return $num_tests;
}


sub test_sequences_annotation {
	my $client = shift;
    my $num_tests = 0;
    my $test_name = "get_sequences_annotation";

	my $sources = {
		'M5RNA' => {
			allowed => ['organism', 'function'],
			not_allowed => ['ontology']
		},
		'RDP' => {
			allowed => ['organism', 'function'],
			not_allowed => ['ontology']
		},
		'Greengenes' => {
			allowed => ['organism', 'function'],
			not_allowed => ['ontology']
		},
		'LSU' => {
                        allowed => ['organism', 'function'],
                        not_allowed => ['ontology']
                },
		'SSU' => {
                        allowed => ['organism', 'function'],
                        not_allowed => ['ontology']
                },
		'M5NR' => {
                        allowed => ['organism', 'function'],
                        not_allowed => ['ontology']
                },
		'SwissProt' => {
                        allowed => ['organism', 'function'],
                        not_allowed => ['ontology']
                },
		'GenBank' => {
                        allowed => ['organism', 'function'],
                        not_allowed => ['ontology']
                },
		'IMG' => {
                        allowed => ['organism', 'function'],
                        not_allowed => ['ontology']
                },
		'KEGG' => {
                        allowed => ['organism', 'function'],
                        not_allowed => ['ontology']
                },
		'SEED' => {
                        allowed => ['organism', 'function'],
                        not_allowed => ['ontology']
                },
		'TrEMBL' => {
                        allowed => ['organism', 'function'],
                        not_allowed => ['ontology']
                },
		'RefSeq' => {
                        allowed => ['organism', 'function'],
                        not_allowed => ['ontology']
                },
		'PATRIC' => {
                        allowed => ['organism', 'function'],
                        not_allowed => ['ontology']
                },
		'eggNOG' => {
                        allowed => ['organism', 'function'],
                        not_allowed => ['ontology']
                },
		'NOG' => {
						allowed => ['ontology'],
						not_allowed => ['organism', 'function'],
		},
		'COG' => {
                        allowed => ['ontology'],
                        not_allowed => ['organism', 'function'],
                },
		'KO' => {
                        allowed => ['ontology'],
                        not_allowed => ['organism', 'function'],
                },
		'GO' => {
                        allowed => ['ontology'],
                        not_allowed => ['organism', 'function'],
                },
		'Subsystems' => {
                        allowed => ['ontology'],
                        not_allowed => ['organism', 'function'],
                },
	};

	my @data_types = qw( organism function ontology );
	my @functions = qw();
	my $test_id = "mgm4440286.3";
	my @sequence_types = qw(dna protein);
	my $organism;

	my %attributes = (
						'version' => 'S',
						'url' => 'S',
						'data' => 'ML',
						'id' => 'S'
					 );

	my $return;
	my $error;

	# my @functions = ['DNA topoisomerase IV']; #K01409 K12960 K10038);
	# eval { $return = $client->$test_name({ id => 'mgm4440286.3', 
	# 								   source => 'GenBank', 
	# 								   data_type => 'function', 
	# 								   sequence_type => 'dna',
	# 								   function => \@functions
	# 								   }); };
	# print Dumper($return);

	##########################################################################
	# happy path testing
	# ------------------
	foreach my $source (keys %{ $sources }) {
		foreach my $data_type (@{ $sources->{$source}->{allowed} }) {
			foreach my $sequence_type (@sequence_types) {
				my $params = {
					id => $test_id,
					source => $source,
					data_type => $data_type,
					sequence_type => $sequence_type,
				};
				undef $return;
				undef $error;
				eval { $return = $client->$test_name($params); };
				is($@, '', "Calling '$test_name' with valid parameters passed successfully : id = $test_id, source = $source, data_type = $data_type, sequence_type = $sequence_type");
				$num_tests++;
				if ($return) {
					$num_tests += test_result($return, \%attributes, $params);
				}
			}
		}
	}
	# id
	# source
	# data_type
	# sequence_type
	# organism
	# function

	# test with an organism
	my $params = { id => 'mgm4440286.3', 
				   source => 'TrEMBL', 
				   data_type => 'organism', 
				   sequence_type => 'dna',
				   organism => 'Escherichia coli MS 21-1'};
	eval { $return = $client->$test_name($params); };
	is($@, '', "Calling '$test_name' with valid parameters (and an organism) passed successfully : id = 'mgm4440286.3', source = TrEMBL, data_type = organism, sequence_type = dna, organism = 'Escherichia coli MS 21-1'");
	$num_tests++;
	if ($return) {
		$num_tests += test_result($return, \%attributes, $params);
	}

	# test with a function (TODO: couldn't get this working!)
	# my @functions = ['DNA topoisomerase IV'];
	# eval { $return = $client->$test_name({ id => 'mgm4440286.3', 
	# 								   source => 'GenBank', 
	# 								   data_type => 'function', 
	# 								   sequence_type => 'dna',
	# 								   function => \@functions
	# 								   }); };
	# print Dumper($return);


	##########################################################################
	# unhappy path testing
	# ------------------
	foreach my $source (keys %{ $sources }) {
		foreach my $data_type (@{ $sources->{$source}->{not_allowed} }) {
			my $params = {
				id => $test_id,
				source => $source,
				data_type => $data_type,
			};
			undef $return;
			undef $error;
			eval { $return = $client->$test_name($params); };
            my $error = $@;
            # print Dumper($error->message());
            # print $error->message()->{data}->{ERROR} . "\n";
            ok($error, "Calling '$test_name' with invalid source/data_type combo successfully returns an error. source = $source, data_type = $data_type ");
            $num_tests++;

            if ($error) {
            	$num_tests += test_error_value($error, 400, qr/Invalid source/);
            }
		}
	}

	#######################################################################
	# missing parameter tests
	# -----------------------
	# 1. no id test
	eval { $return = $client->$test_name({ source => 'M5RNA', data_type => 'organism', sequence_type => 'dna'}); };
	#like($@, qr/Invalid argument count/, "\"$test_name\" called with no id failed properly");
	ok($return, "Calling '$test_name' with no id returns something.");
	$num_tests++;
	if ($return) {
		note "Checking if running with no id returns a method description object";
		$num_tests += test_method_description($return);
	}

	# 2. no source test (should go to default - M5RNA)
	undef $return;
	eval { $return = $client->$test_name({ id => $test_id, data_type => 'organism', sequence_type => 'dna'}); };
	is($@, '', "\"$test_name\" called with no source succeeded properly");
	$num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { id => $test_id, data_type => 'organism', sequence_type => 'dna'}); }

	# 3. no sequence_type test (should go to default - dna)
	undef $return;
    eval { $return = $client->$test_name({ id => $test_id, source => 'M5RNA', data_type => 'organism' }); };
	is($@, '', "\"$test_name\" called with no sequence_type succeeded properly");
    $num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { id => $test_id, source => 'M5RNA', data_type => 'organism' }); }

	# 4. no type test (should go to default - organism)
	undef $return;
    eval { $return = $client->$test_name({ id => $test_id, source => 'M5RNA', sequence_type => 'dna' }); };
	is($@, '', "\"$test_name\" called with no data_type succeeded properly");
    $num_tests++;
	unless ($@) { $num_tests += test_result($return, \%attributes, { id => $test_id, source => 'M5RNA', sequence_type => 'dna' }); }

	# 5. no parameters test - should throw an error.
	undef $return;
	undef $error;
	eval { $return = $client->$test_name(); };
	ok($@, "Calling '$test_name' with no parameters returns an error.");
	$num_tests++;
	$error = $@;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::ArgumentValidationError", 400, qr/Invalid/i);
	}

	# 6. empty parameter set test - should return usage.
	undef $return;
	undef $error;
	eval { $return = $client->$test_name({}); };
	ok($return, "Calling '$test_name' with empty parameters returns something.");
	$num_tests++;

	$error = $@;
	if ($return) {
		note"Checking if calling '$test_name' with no parameters returns a method description object";
		$num_tests += test_method_description($return);
	}
    return $num_tests;

}


sub test_sequenceset_instance {
	my $client = shift;
    my $num_tests = 0;
    my $test_name = "get_sequenceset_instance";
    my $test_id = "mgm4440286.3";

    my %attributes = (
    					stage_name => 'S',
    					file_name => 'S',
    					url => 'S',
    					id => 'S',
    					stage_type => 'S',
    					stage_id => 'S'
    				);
    my $params = {
    				id => $test_id
    			};

    my $result;
    my $error;

    # happy test (really only one - one parameter, right?)
    eval{ $result = $client->$test_name($params); };
	is($@, '', "Calling '$test_name' with id='$test_id' passed successfully.");
	$num_tests++;
	if ($result) {
		$num_tests += test_result($result, \%attributes, $params);
	}

	# unhappy test (no id)
    eval{ $result = $client->$test_name({}); };
    $error = $@;
	ok(!$error, "Calling '$test_name' with no id returns something valid.");
	$num_tests++;
	if (!$error) {
		note "Checking if calling '$test_name' with no parameters returns a method description object";
		$num_tests += test_method_description($result);
	} else {
		note "Found an error instead!";
		test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/invalid/i);
	}


	# unhappy test (invalid id)
    eval{ $result = $client->$test_name({ id => 'invalid_id' }); };
	ok($error, "Calling '$test_name' with an invalid id failed properly.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC");
	}

    return $num_tests;
}

sub test_sequenceset_list {
	my $client = shift;
    my $num_tests = 0;
    my $test_name = "get_sequenceset_list";
    my $test_id = "mgm4440286.3";

    my %attributes = (
    					stage_name => 'S',
    					file_name => 'S',
    					url => 'S',
    					id => 'S',
    					stage_type => 'S',
    					stage_id => 'S'
    				);
    my $params = {
    				id => $test_id
    			};

    my $result;
    my $error;

    # happy test (really only one - one parameter, right?)
    eval{ $result = $client->$test_name($params); };
	is($@, '', "Calling '$test_name' with id='$test_id' passed successfully.");
	$num_tests++;
	if ($result) {
		$num_tests += test_result($result, \%attributes, $params);
	}

	# unhappy test (no id)
    eval{ $result = $client->$test_name({}); };
    $error = $@;
	ok(!$error, "Calling '$test_name' with no id returns something valid.");
	$num_tests++;
	if (!$error) {
		note "Checking if calling '$test_name' with no parameters returns a method description object";
		$num_tests += test_method_description($result);
	} else {
		note "Found an error instead!";
		test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/invalid/i);
	}

	# unhappy test (invalid id)
    eval{ $result = $client->$test_name({ id => 'invalid_id' }); };
	ok($error, "Calling '$test_name' with an invalid id failed properly.");
	$num_tests++;
	if ($error) {
		$num_tests += test_error_value($error, "Bio::KBase::Exceptions::JSONRPC");
	}

    return $num_tests;
}

sub test_method_description {
	my $result = shift;

	is (ref($result), 'HASH', 'Is the method description a hash?');

	ok (exists($result->{'requests'}), 'Does it have a "requests" element?');
	ok (exists($result->{'name'}), 'Does it have a name element?');
	ok (exists($result->{'url'}), 'Does it have a url element?');
	ok (exists($result->{'documentation'}), 'Does it have a documentation element?');
	ok (exists($result->{'type'}), 'Does it have a type element?');
	ok (exists($result->{'description'}), 'Does it have a description element?');

	return 7;
}

###############################################################################
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

	my $num_tests = 0;
	my $result = $return;
#		print Dumper($result);  

	if (ref($result) eq 'HASH' && exists ($result->{'rows'}) )
	{	#print "DEBUG: Abundanceprofile \n";
		$data->[0] = $result;
	}
	# elsif (ref($result) eq 'HASH' && exists ($result->{'data'}))
	# {   #print "DEBUG: Sample/Library/Metagenome/Project query \n";
	# 	$data->[0] = $result->{data};
	# }  
	elsif (ref($result) eq 'HASH')
	{   #print "DEBUG: Sample/Library/Metagenome/Project instance \n";
		$data->[0] = $result;
	} 
	elsif (ref($result) eq 'ARRAY')
	{	#print "DEBUG: Sample/Library/Metagenome/Project/Sequences_MD5 instance  \n";
#		print Dumper($result);  
		$data = $return;
		die "never should reached this point" ;
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
					#print "\t\t\tKEY=$key4 VALUE=$key3->{$key4} \n";
					#print Dumper \%attributes ;
					ok(exists $attributes{$key4}, "Is Attribute $key4 valid?");
					$num_tests++;
					# M = Map (HASH)
					if (exists $attributes{$key4} && $attributes{$key4} eq 'M'  )
					{
						is (ref($key3->{$key4}),'HASH', "Is Attribute $key4 a hash?");
						$num_tests++;
					}
					# L = List (ARRAY)
					elsif (exists $attributes{$key4} && $attributes{$key4} eq 'L'  )
					{
						is (ref($key3->{$key4}),'ARRAY', "Is Attribute $key4 an array?");
						$num_tests++;
					}
					# LM = List of Maps (ARRAY of HASHes - a list where each element is a key-value pair)
					elsif (exists $attributes{$key4} && $attributes{$key4} eq 'LM' )
					{
						is (ref($key3->{$key4}), 'ARRAY', "Is Attribute $key4 an array?");
						$num_tests++;

						my $num_hashes = 0;
						foreach my $elem (@{ $key3->{$key4} }) {
							$num_hashes++ if (ref($elem) eq "HASH");
						}
						is ($num_hashes, scalar(@{ $key3->{$key4} }), "Is Attribute $key4 an array of hashes?");
						$num_tests++;

					}
					# LL = List of Lists (ARRAY of ARRAYs) - list where each element is a list, itself.
					elsif (exists $attributes{$key4} && $attributes{$key4} eq 'LL')
					{
						is (ref($key3->{$key4}), 'ARRAY', "Is Attribute $key4 an array?");
						$num_tests++;

						my $num_hashes = 0;
						foreach my $elem (@{ $key3->{$key4} }) {
							$num_hashes++ if (ref($elem) eq "ARRAY");
						}
						is ($num_hashes, scalar(@{ $key3->{$key4} }), "Is Attribute $key4 an array of arrays?");
						$num_tests++;
					}
					# ML = Map of Lists (HASH of LISTS) - map where each value is a list (keys are all scalars)
					elsif (exists $attributes{$key4} && $attributes{$key4} eq 'ML')
					{
						is (ref($key3->{$key4}), 'HASH', "Is Attribute $key4 an array?");
						$num_tests++;

						my $num_hashes = 0;
						foreach my $elem (keys %{ $key3->{$key4} }) {
							$num_hashes++ if (ref($key3->{$key4}->{$elem}) eq "ARRAY");
						}
						is ($num_hashes, scalar(keys %{ $key3->{$key4} }), "Is Attribute $key4 a hash of arrays?");
						$num_tests++;

					}
					else
					{
						is (ref($key3->{$key4}),'', "Is Attribute $key4 a scalar?");
						$num_tests++;
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
			$num_tests++;
		}
	}

	return $num_tests if (ref($result) eq 'ARRAY');

	if (exists $test_value{"limit"}) {
		is ($result->{'limit'},$test_value{"limit"}, "Is the returned limit the same as the requested limit?");
		cmp_ok ($count, "<=", $test_value{"limit"}, "Is the returned number of records less than or equal to the requested limit?");
		$num_tests += 2;
	}
	if (exists $test_value{"offset"}) {
		is ($result->{'offset'},$test_value{"offset"}, "Is the returned offset the same as the requested offset?");
		$num_tests++;
	}
	if (exists $test_value{"order"}) {
		is ($result->{'order'},$test_value{"order"}, "Is the returned order the same as the requested order?");
		$num_tests++;
	}

#	is ($return->{'result'}->{'limit'},$test_value{"limit"}, "Is the returned limit the same as the requested limit?") if (exists $test_value{"limit"});
#	is ($count, $test_value{"limit"}, "Is the returned number of records the same as the requested limit?") if (exists $test_value{"limit"});
#	is ($return->{'result'}->{'offset'},$test_value{"offset"}, "Is the returned offset the same as the requested offset?") if (exists $test_value{"offset"});
#	is ($return->{'result'}->{'order'},$test_value{"order"}, "Is the returned order the same as the requested order?") if (exists $test_value{"order"});

	return $num_tests;
}

sub test_error
{
	my ($return,$test) = @_;
	my %test_value = %$test;

	my $num_tests = 0;

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
		$num_tests++;
	}
	else
	{
		ok( ! exists ($return->{'error'}->{'data'}),"Is the HASH free of errors");
		$num_tests++;
	}
	return $num_tests;

}

sub test_error_value {
	my ($error, $exp_class, $exp_code, $exp_message_regex) = @_;
	my $num_tests = 0;
	if (!defined $error) {
		diag("Tried to test an error value, but got an undef error to test!");
		return 0;
	}

	isa_ok($error, $exp_class, "Is the error of the expected class?");
	$num_tests++;

	if ($error->isa("Bio::KBase::Exceptions::ArgumentValidationError")) {
		like($error->message(), $exp_message_regex, "Returns expected error message");
		$num_tests++;
	}
	elsif ($error->isa("Bio::KBase::Exceptions::JSONRPC")) {
		is ($error->message()->{code}, $exp_code, "Returns expected error code $exp_code");
		like($error->message()->{data}->{ERROR}, $exp_message_regex, "Returns expected error message");
		$num_tests += 2;
	}
	elsif ($error->isa("Bio::KBase::Exceptions::HTTP")) {
#		print Dumper($error);
	}

	return $num_tests;
}