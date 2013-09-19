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

$num_tests += test_abundanceprofile_instance($client);

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
		       'M5NR' => {
				  allowed => ['organism'],
				  not_allowed => ['feature', 'function']
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
		       'KEGG' => {
				  allowed => ['organism', 'feature'],
				  not_allowed => ['function']
				 },
		       'M5RNA' => {
				   allowed => ['organism'],
				   not_allowed => ['feature', 'function']
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
		       'Subsystems' => {
					allowed => ['function'],
					not_allowed => ['organism', 'feature'],
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
			       }
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
		$num_tests += ReturnTests::test_method_description($return);
	}

	# 2. no source test (should go to default - M5RNA)
	undef $return;
	eval { $return = $client->get_abundanceprofile_instance({ id => $test_id, verbosity => 'minimal', type => 'organism'}); };
	is($@, '', "\"$test_name\" called with no source succeeded properly");
	$num_tests++;
	unless ($@) { $num_tests += ReturnTests::test_result($return, \%attributes, { id => $test_id, verbosity => 'minimal', type => 'organism'}); }

	# 3. no verbosity test (should go to default - minimal)
	undef $return;
    eval { $return = $client->get_abundanceprofile_instance({ id => $test_id, source => 'M5RNA', type => 'organism'}); };
	is($@, '', "\"$test_name\" called with no verbosity succeeded properly");
    $num_tests++;
	unless ($@) { $num_tests += ReturnTests::test_result($return, \%attributes, { id => $test_id, source => 'M5RNA', type => 'organism'}); }

	# 4. no type test (should go to default - organism)
	undef $return;
    eval { $return = $client->get_abundanceprofile_instance({ id => $test_id, verbosity => 'minimal', source=>'M5RNA'}); };
	is($@, '', "\"$test_name\" called with no type succeeded properly");
    $num_tests++;
	unless ($@) { $num_tests += ReturnTests::test_result($return, \%attributes, { id => $test_id, verbosity => 'minimal', source=>'M5RNA'}); }

	# 5. no parameters test
	eval { $return = $client->get_abundanceprofile_instance(); };
	if (!$@) {
		note "Checking if running with no parameters returns a method description object";
		$num_tests += ReturnTests::test_method_description($return);
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
#					print STDERR "Test for \"$test_name\" failed with valid(?) parameters:\n";
#					print STDERR Dumper($params);
#					print STDERR "Returned structure (if any):\n";
#					print STDERR Dumper($@);
#					print STDERR Dumper($return);
				}
				elsif ($return) {
					is (ref($return), "HASH", "\"$test_name\" returned a HASH");
					$num_tests++;
					$num_tests += ReturnTests::test_result_brief($return, \%attributes, $params);
					
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
            	$num_tests += ReturnTests::test_error_value($error, "Bio::KBase::Exceptions::JSONRPC", 400, qr/Invalid source/);
            }
        }
    }


	return $num_tests;
}

