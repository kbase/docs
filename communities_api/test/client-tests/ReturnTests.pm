#  Helper routines to check the return from the tests
#  Used by all of the scripts

package ReturnTests;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(test_method_description test_result test_result_brief test_error test_error_value);

use Test::More;


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
		note("Verbosity=FULL, Were all Attributes returned?");
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

sub test_result_brief
{
	my ($return,$attribute,$test) = @_;
	my $data;

	my $num_tests = 0;
	is (ref($return), 'HASH', 'Is the return a hash?');
	$num_tests++;
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

1;
