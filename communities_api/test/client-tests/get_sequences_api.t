#!/usr/bin/perl -w
use strict;

use Data::Dumper;
use Test::More 'no_plan';
use lib "test/client-tests";
use ReturnTests;

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

$num_tests += test_sequences_md5($client); 
$num_tests += test_sequences_annotation($client);	# incomplete
$num_tests += test_sequenceset_instance($client);
$num_tests += test_sequenceset_list($client);

done_testing($num_tests);

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
			$num_tests += ReturnTests::test_result($return, \%attributes, $params);
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
   		$num_tests += ReturnTests::test_result($return, \%attributes, $params);
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
		$num_tests += ReturnTests::test_error_value($error, "Bio::KBase::Exceptions::ArgumentValidationError", 400, qr/Invalid/i);
	}

	undef $return;
	undef $error;
	eval { $return = $client->$test_name({}); };
	ok($return, "Calling '$test_name' with empty parameters returns something.");
	$num_tests++;
	if ($return) {
		note"Checking if calling '$test_name' with no parameters returns a method description object";
		$num_tests += ReturnTests::test_method_description($return);
#		print Dumper($return);
	}


	# 2. No id
	undef $return;
	undef $error;
	eval { $return = $client->$test_name({ sequence_type=>'dna' }); };
	ok($return, "Calling '$test_name' with no id returns something.");
	$num_tests++;

	# 3. Invalid sequence type
	undef $return;
	undef $error;
	eval { $return = $client->$test_name({ id=>$test_id, sequence_type=>'blah' }); };
	isnt($@, '', "Calling '$test_name' with an invalid sequence_type gives an error");
	$error = $@;
	$num_tests++;
	if ($error) {
		$num_tests += ReturnTests::test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid/i);
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
					$num_tests += ReturnTests::test_result($return, \%attributes, $params);
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
		$num_tests += ReturnTests::test_result($return, \%attributes, $params);
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
            	$num_tests += ReturnTests::test_error_value($error, 400, qr/Invalid source/);
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

	# 2. no source test (should go to default - M5RNA)
	undef $return;
	eval { $return = $client->$test_name({ id => $test_id, data_type => 'organism', sequence_type => 'dna'}); };
	is($@, '', "\"$test_name\" called with no source succeeded properly");
	$num_tests++;
	unless ($@) { $num_tests += ReturnTests::test_result($return, \%attributes, { id => $test_id, data_type => 'organism', sequence_type => 'dna'}); }

	# 3. no sequence_type test (should go to default - dna)
	undef $return;
    eval { $return = $client->$test_name({ id => $test_id, source => 'M5RNA', data_type => 'organism' }); };
	is($@, '', "\"$test_name\" called with no sequence_type succeeded properly");
    $num_tests++;
	unless ($@) { $num_tests += ReturnTests::test_result($return, \%attributes, { id => $test_id, source => 'M5RNA', data_type => 'organism' }); }

	# 4. no type test (should go to default - organism)
	undef $return;
    eval { $return = $client->$test_name({ id => $test_id, source => 'M5RNA', sequence_type => 'dna' }); };
	is($@, '', "\"$test_name\" called with no data_type succeeded properly");
    $num_tests++;
	unless ($@) { $num_tests += ReturnTests::test_result($return, \%attributes, { id => $test_id, source => 'M5RNA', sequence_type => 'dna' }); }

	# 5. no parameters test - should throw an error.
	undef $return;
	undef $error;
	eval { $return = $client->$test_name(); };
	ok($@, "Calling '$test_name' with no parameters returns an error.");
	$num_tests++;
	$error = $@;
	if ($error) {
		$num_tests += ReturnTests::test_error_value($error, "Bio::KBase::Exceptions::ArgumentValidationError", 400, qr/Invalid/i);
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
		$num_tests += ReturnTests::test_method_description($return);
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
		$num_tests += ReturnTests::test_result($result, \%attributes, $params);
	}

	# unhappy test (no id)
    eval{ $result = $client->$test_name({}); };
    $error = $@;
	ok(!$error, "Calling '$test_name' with no id returns something valid.");
	$num_tests++;
	if (!$error) {
		note "Checking if calling '$test_name' with no parameters returns a method description object";
		$num_tests += ReturnTests::test_method_description($result);
	} else {
		note "Found an error instead!";
		ReturnTests::test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/invalid/i);
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
		$num_tests += ReturnTests::test_result($result, \%attributes, $params);
	}

	# unhappy test (no id)
    eval{ $result = $client->$test_name({}); };
    $error = $@;
	ok(!$error, "Calling '$test_name' with no id returns something valid.");
	$num_tests++;
	if (!$error) {
		note "Checking if calling '$test_name' with no parameters returns a method description object";
		$num_tests += ReturnTests::test_method_description($result);
	} else {
		note "Found an error instead!";
		ReturnTests::test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/invalid/i);
	}

    return $num_tests;
}

